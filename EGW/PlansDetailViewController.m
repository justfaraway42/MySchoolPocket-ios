//
//  TimetablesDetailViewController.m
//  Timetables
//
//  Created by Justus Dög on 23.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "PlansDetailViewController.h"

@implementation PlansDetailViewController

@synthesize percentLabel;
@synthesize sizeLabel;

@synthesize pushRefresh;

@synthesize currentName, currentURL, currentDate, webView, toolbar, saveurl, lastUpdate, responseData, URLConnection, overlayView, interactionController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    /*
     REMEMBER: the upper left corner is 0.0 [x], 0.0 [y]
     
     → [x max. 320]
     ↓
     [y max. 480]
     
     X-Koordinate: X=60 (60 points vom Rand der NavigationBar entfernt entfernt)
     Y-Koordinate: Y=10 (10 points vom oberen Rand der NavigationBar entfernt)
     Breite: aktuelle Breite des Bildschirmes (je nachPosition) - 100 (160-20)
     Höhe: 0 (ist unwichtig)
     
     Titel ändert sich noch! **FIX_LATER
     
     */
    
    self.overlayView = [[OverlayView alloc] init];
    
    // in InterfaceBuilder: webView.opaque = NO;
    webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    
    
    //[toolbar setFrame:CGRectMake(0, 400, 320, 20)];
    /*
     (CGFloat x, CGFloat y, CGFloat width, CGFloat height)
     (x-Achse, y-Achse, Breite, Höhe)
     Breite = 420-Höhe
     */
    
	// Titel des navigationControllers und Button werden initialisiert
    
	self.navigationItem.title = self.currentName;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(selectOptions)];
    
    // der Pfad zum lokal gespeicherten PDF Dokument wird erstellt (savepath)
    
    NSArray *arrayPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    /*
     "/Users/USER/Library/Application Support/iPhone Simulator/4.3.2/Applications/B4685690-B979-4D4E-985D-C61A4A8365C0/Documents"
     
     KEINE METHODE; SONDERN EINE FUNKTION ([Methode], (Funktion))
     Funktion ist global, kann man immer direkt aufrufen, ohne vorher ein Objekt zu erstellen, was man initialisieren und releasen muss (logelöst von Objekten und Klassen)
     vor der OOP gab es auch nur Funktionen (GUI und CoreGraphics sind auch viel in Funktionen)
     
     OOP ist Weiterentwicklung von Funktionen in Methoden geschrieben, die sich auf Objekte und Klassen beziehen
     
     
     
     FUNKTION mit 3 Parametern
     
     1. NSSearchPathDirectory
     SCHLÜSSELBEZEICHNER NSDocumentDirectory
     beim Mac der DokumentenOrdner "/Users/USER/Documents")
     beim iPhone: App == Sandbox: KEIN Zugriff auf die anderen Applikationen (hat nur das System)
     Jede App hat ihren eigenen Dokumenten-Ordner => NSDocumentDirectory (alt. z. B.: NSLibraryDirectory, NSApplicationDirectory, ...)
     
     2. NSSearchPathDomainMask
     Aus welcher Domain benötigen wir das Verzeichnis (bei Library gibt es ja mehrere)
     -> Dokumentenordner des Benutzers (der Ordner, der der App zugeordnet ist)
     -> wird nur gelöscht, wenn die App vom Device gelöscht wird, bei Updates nicht; wird automatisch in iTunes gebackupt
     
     3. BOOL (expandTilde)
     Im Falle des Userverzeichnisses (welches wir ja Benutzen), schreibt das Programm ein Tilde-Symbol "∼"
     "∼JustPod" Home-Ordner eines Benutzers ist in UNIX-Systemen fast immer die Tilde (relative Angabe zum kompletten Verzeichnisbaum des aktuellen Nutzers)
     
     ARRAY, da er mehrere z. B. DocumentDirectorys zurückgeben kann
     
     in iOS sind Dateien stark an die Applikation geknüpft, der Dateipfad ändert sich ständig - man kann KEINEN Eindeutigen konstanten Dateipfad angeben
     dafür kann man Standard Verzeichnisse wie z.B. die Libary, die Preferences unter Mac OS benutzen (entweder die auf der System Platte "/Library", bzw. "/System/Library", oder die unter User "/Benutzer/USER/Library")
     
     
     da Pfade nichts weiter als Strings sind, wird dieser hier umgewandelt
     */
    NSString *documentDirectory = [arrayPaths objectAtIndex:0];
    /*
     documentDirectory, von dem 1. Wert aus dem Array (ist /Users/JustPod/Library/Application Support/iPhone Simulator/4.3.2/Applications/SANDBOX/Documents) -- SANDBOX ist hier "B4685690-B979-4D4E-985D-C61A4A8365C0"
     hier also der Pfad zum Documents Ordner der App
     */
    
    UIViewController *selectedViewController = [self.tabBarController.viewControllers objectAtIndex:self.tabBarController.selectedIndex];
    // mit viewControllers bekommen wir alle verfügbaren Controller des tabBarControllers geliefert - mit selectedIndex wählen wir den aktuellen Controller aus
    
    NSInteger selectedItemTag = selectedViewController.tabBarItem.tag;
    
    NSString *currentPath;
    
    if (selectedItemTag == 1) {
        currentPath = [documentDirectory stringByAppendingPathComponent:@"timetables"];
        // currentPath: ~/Documents/Timetables
        
    } else if (selectedItemTag == 2) {
        currentPath = [documentDirectory stringByAppendingPathComponent:@"representation"];
        // currentPath: ~/Documents/Representation
    }
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    BOOL folderIsExisting = [fileManager fileExistsAtPath:currentPath];
    
    if (!folderIsExisting) {
        // wenn der Ordner NICHT existiert...
        BOOL success = [fileManager createDirectoryAtPath:currentPath withIntermediateDirectories:NO attributes:nil error:nil];
        // ...wird der Ordner erstellt (bei dem Pfad currentPath, OHNE Zwischenverzeichnisse zu erstellen und OHNE Atribute)
        
        if (!success) {
            // Wenn KEIN Ordner da war, und das erstellen des Ordners FEHLSCHLÄGT, dann muss eine Exception geworfen werden
            NSLog(@"Exception!");
        }
    }
    
    savepath = [currentPath stringByAppendingPathComponent:[self.currentURL lastPathComponent]];
    self.saveurl = [NSURL fileURLWithPath:savepath];
    
    //wir wandeln den aktuellen Pfad in eine NSURL um und hängen den namen des aktuellen PDFs an
    
    /*
     [currentURL lastPathComponent] ist die letzten Komponente der vollständigen URL (also z. B. "stdplan11.pdf")
     diese wird dann an den Pfad angehängt (also ~/Documents/stdplan11.pdf)
     mit fileURLWithPath wird dieser Pfad in eine Art Pfad-URL umgewandelt (also file://~/Documents/stdplan11.pdf)
     */
    
    [self updateDate];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self.saveurl path]];
    
    /*
     der FileManager geht nur mit localen Pfaden um - deshalb entnehmen wir der NSURL savepath nur den Pfad (path) welcher ein NSString ist (also /~/Documents/stdplan11.pdf)
     testet, ob eine Datei mit dem jeweiligen Namen (*.pdf) schon existiert -> gibt einen BOOL-Wert (YES or NO) zurück
     */
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
	if (!fileExists || (selectedItemTag == 1 && ![defaults boolForKey:@"loadTimetablesManually"]) || (selectedItemTag == 2 && ![defaults boolForKey:@"loadRepresentationManually"])) {
        // die Datei existiert noch nicht und muss heruntergeladen werden
        
        [self loadData];
        
    } else {
        // die Datei existiert bereits und muss nur in die webView geladen werden
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.saveurl]];
    }
}

#pragma mark -
#pragma mark Download Methods

- (IBAction)pushRefresh:(id)sender {
    [self loadData];
}

#pragma mark - Delegate Methods

- (void)loadData {
    // NSURLConnection erstellen (startet den download)
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    pushRefresh.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self showOverlayView];
    
    self.currentURL = [self.currentURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.currentURL = [self.currentURL stringByReplacingOccurrencesOfString:@"	" withString:@""];
    self.currentURL = [self.currentURL stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.currentURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    
    //request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.currentURL] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:0];
    
    URLConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    self.responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0]; // wir setzen unser NSMutableData auf die Länge 0 (wird komplett geleert), da wir so vorherige Antworten löschen
    
    fileSize = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Recived another block of data. Appending to existing data
    [self.responseData appendData:data];
    
    // vom Server bekommen wir jetzt die Daten zurück - da dies unter anderem mehrfach geschieht (also in einzelnen Blocks), hängen wir den aktuellen Block immer an die schon existierenden Daten dran (appendData)
    
    // Wenn Größe vorhanden ist dann Fortschritt aktualisieren
    if (fileSize > 0) {
        NSInteger currentBytes = [responseData length];
        
        /*
         x        |   currentBytes
         -----------------------------------
         100 %    |     fileSize
         
         current percent (x) = 100 * currentBytes / fileSize
         */
        
        float percent = 100 * currentBytes / fileSize;
        
        [self.overlayView updateMessage:[NSString stringWithFormat:@"%.0f %%", percent]];
        
        if (percent > 100) {
            percent = 100.0;
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // An error occured
	
    UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertWarning", NULL) message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; // @"Fehler beim Laden des Inhalts"
    [errorAlert show];
    [self errorOverlayView];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Once this method is invoked, "serverresponseData" contains the complete
    // wird erst aufgerufen, wenn die Daten fertig geladen sind (wenn kein appendData mehr erforderlich ist)
    
    BOOL success = [responseData writeToURL:self.saveurl atomically:YES];
    
    NSError *error;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:savepath error:&error];
    NSLog(@"%@", [attributes fileCreationDate]);
    
    if (oldDate == [attributes fileCreationDate]) {
        NSLog(@"SAME");
    }
    
    //    if ([responseData isEqualToData:[NSData dataWithContentsOfFile:savepath]]) {
    //        NSLog(@"SAME");
    //    } else {
    //        NSLog(@"other");
    //    }
    
    /*
     1. ein NSData Objekt wird aus dem Inhalt der URL (also dem PDF) erstellt
     2. dieses NSData Objekt wird dann im Documents Ordner gesichert (writeToPath)
     3. atomically:YES -- Backup?!
     4. BOOL - YES = erfolgreich || NO = nicht erfolgreich
     */
    
    if (success) {
        [self.webView loadRequest: [NSURLRequest requestWithURL:self.saveurl]];
        [self successfulOverlayView];
    } else {
        [self errorOverlayView];
    }
    
    self.navigationItem.title = self.currentName;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark -
#pragma mark ActionSheet Delegate Methods

- (void)selectOptions {
	// öffnet einen Dialog mit 3 Knöpfen und einem Chancel knopf
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NULL delegate:self cancelButtonTitle:NSLocalizedString(@"buttonCancel", NULL) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"actionSheetButtonShare", NULL), NSLocalizedString(@"actionSheetButtonOpenIn", NULL), NSLocalizedString(@"actionSheetButtonAirPrint", NULL), nil]; // Was wollen Sie machen? -öffnen in Mobile Safari-||-ausdrucken per AirPrint-||-Abbrechen-
    
	//actionSheet.actionSheetStyle = self.navigationController.navigationBar.barStyle; // Benutzt den selben Style wie der navigationController
    //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
        if (([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)) {
            //iOS 6+
            UIActivityViewController* activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObject:[NSURL URLWithString:self.currentURL]] applicationActivities:nil];
            [self presentViewController:activityViewController animated:YES completion:^{}];
        } else {
            //iOS 5 übergibt die URL an Safari...
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.currentURL]];
        }
	} else if (buttonIndex == 1) {
        // Öfnen in Knopf übergibt PDF an UIPrintInteractionController…
        interactionController = [UIDocumentInteractionController interactionControllerWithURL:self.saveurl];
        interactionController.delegate = self;
        
        if (![interactionController presentOpenInMenuFromBarButtonItem:self.pushRefresh animated:YES]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertWarning", NULL) message:NSLocalizedString(@"alertDeviceNotSupported", NULL) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    } else if (buttonIndex == 2) {
        // AirPrint Knopf übergibt PDF an UIPrintInteractionController…
        if ([UIPrintInteractionController class]) {
            
            UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
            
            if(!controller) {
                // IF-Abfrage ist nötig, da AirPrint erst in iOS 4.2 eingeführt wurde. Eine ältere Version kennt keine UIPrintInteractionController Classe -> wenn der Controller nicht vorhanden ist -> Error
                NSLog(@"Couldn't get shared UIPrintInteractionController!");
                return;
            }
            
            void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) = ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
                
                if (!completed && error) {
                    NSLog(@"FAILED! due to error in domain %@ with error code %u", error.domain, error.code);
                }
            };
            
            if ([UIPrintInfo class]) {
                
                UIPrintInfo *printInfo = [UIPrintInfo printInfo];
                printInfo.outputType = UIPrintInfoOutputGeneral;
                printInfo.jobName = [self.currentURL lastPathComponent];
                printInfo.duplex = UIPrintInfoDuplexLongEdge;
                controller.printInfo = printInfo;
                controller.showsPageRange = YES;
                controller.printingItem = self.saveurl;
                
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [controller presentFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES completionHandler:completionHandler];
            } else
                [controller presentAnimated:YES completionHandler:completionHandler];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertWarning", NULL) message:NSLocalizedString(@"alertDeviceNotSupported", NULL) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
        NSLog(@"print PDF from File: %@", self.saveurl); // protokolliert das gedruckte PDF
    }
}

#pragma mark -
#pragma mark self.overlayView Methods

- (void)showOverlayView {
    self.overlayView.delegate = self;
    [self.overlayView showActivity:NSLocalizedString(@"plansDetailsDownload", NULL)];
}

- (void)successfulOverlayView {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.overlayView showSuccess:NSLocalizedString(@"buttonDone", NULL) withIcon:@"✓"];
    [self updateDate];
}

- (void)errorOverlayView {
    [self.overlayView showError:NSLocalizedString(@"alertWarning", NULL) withIcon:@"✕"]; // @"Datei nicht vorhanden"
}

- (void)updateDate {
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.saveurl path] error:nil];
    /*
     Attribute der Datei (wie Größe, Schreibrechte, Änderungsdatum, Typ) als Directory
     */
    
    currentDate = [attributes objectForKey:NSFileModificationDate];
    
    // Format date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
	if (currentDate){
        lastUpdate.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"plansLastUpdated", NULL), [dateFormatter stringFromDate:currentDate]];
        if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedAscending)) {
            // < iOS 7
            lastUpdate.font = [UIFont fontWithName:@"Helvetica" size:13];
            lastUpdate.textColor = [UIColor whiteColor];
            lastUpdate.textAlignment = NSTextAlignmentRight;
        }
    }
}

- (void)removedOverlayView {
    pushRefresh.enabled = YES;
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any stronged subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    currentName = nil;
    currentURL = nil;
    currentDate = nil;
    saveurl = nil;
    webView = nil;
    lastUpdate = nil;
    toolbar = nil;
    
    self.overlayView = nil;
    
    
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    if (URLConnection) {
        
        [URLConnection cancel];
    }
    
    if ([UIApplication sharedApplication].networkActivityIndicatorVisible) {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
    
    if (self.overlayView) {
        [self.overlayView hide];
        [self.overlayView removeFromSuperview];
    }
    
    [super viewWillDisappear:YES];
}

- (void)dealloc {
    
    currentName = nil;
    currentURL = nil;
    currentDate = nil;
    saveurl = nil;
    webView = nil;
    lastUpdate = nil;
    toolbar = nil;
    
    self.overlayView = nil;
}

@end