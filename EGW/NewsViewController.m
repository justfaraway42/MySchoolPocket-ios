//
//  RootViewController.m
//  News
//
//  Created by Justus D√∂g on 05.07.11.
//  Copyright 2011 Europ√§isches Gymnasium Waldenburg. All rights reserved.
//

#import "NewsViewController.h"
#import "Parser.h"
#import "NewsTableCellView.h"
#import "NewsDetailViewController.h"
#import "AppDelegate.h"
#import "SchoolsViewController.h"
#import "UINavigationControllerPortrait.h"

@implementation NewsViewController

@synthesize entityArray;
@synthesize fetchedResultsController=_fetchedResultsController;
@synthesize managedObjectContext=_managedObjectContext;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:@"classLevel"] == nil) {
        NSURL *xmlURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"xml"]];
        
        NSError *parseError = nil;
        
        // Parse the xml and store the results in our object model
        LocationsParser *xmlParse = [[LocationsParser alloc] init];
        [xmlParse parseXMLFileAtURL:xmlURL parseError:&parseError];
        
        SchoolsViewController *addController = [[SchoolsViewController alloc] initWithNibName:@"SchoolsView" bundle:nil];
        
        [defaults setBool:YES forKey:@"initSchoolViewController"];
        [defaults synchronize]; // save state
        
        // This is where you wrap the view up nicely in a navigation controller
        UINavigationController *navigationController = [[UINavigationControllerPortrait alloc] initWithRootViewController:addController];
        
        // And now you want to present the view in a modal fashion all nice and animated
        [self presentModalViewController:navigationController animated:YES];
        
    } else if ([defaults boolForKey:@"reloadSwitch"]) {
        [defaults setBool:YES forKey:@"reloadNews"];
        [defaults synchronize];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = NSLocalizedString(@"news", NULL);
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)) {
        //iOS 6+
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    } else {
        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
        self.navigationItem.leftBarButtonItem = refreshButton;
    }
    
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(selectOptions)];
    self.navigationItem.rightBarButtonItem = actionButton;
    
    self.managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if ([mutableFetchResults count] == 0) {
        [self refresh];
    } else if ([defaults boolForKey:@"reloadNews"]) {
        [self refresh];
        [defaults setBool:NO forKey:@"reloadNews"];
        [defaults synchronize];
    }
    
    [self deleteOldArticles];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark Private Methods

- (void)deleteOldArticles {
    
    // delete older news
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
//    // If a sort key was passed, use it for sorting.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];// nicht aufsteigend: das neuste Datum als erstes (und somit das "größte")
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    for (int i = [mutableFetchResults count]; i > [defaults integerForKey:@"maxArticles"]; i--) {
        [self.managedObjectContext deleteObject:[mutableFetchResults objectAtIndex:i-1]];
        //count-1, da ein Array bei 0 beginnt
    }
}

- (void)refresh {
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSLog(@"%@", [defaults stringForKey:@"school_feed"]);
    
    NSURL *xmlURL = [NSURL URLWithString:[[defaults stringForKey:@"school_feed"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	// Parse the xml and store the results in our object model
    
	Parser *xmlParse = [[Parser alloc] init];
    [xmlParse parseXMLFileFrom:self with:xmlURL];
}

- (void)endParsingWithError:(NSError *)error {
    UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alertWarning", NULL) message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; // @"Fehler beim Laden des Inhalts"
    [errorAlert show];
    
    [self endParsing];
}

- (void)endParsing {
    [self deleteOldArticles];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([self respondsToSelector:@selector(setRefreshControl:)]) {
        [self.refreshControl endRefreshing];
    } else {
        self.navigationItem.leftBarButtonItem.enabled = YES;
    }
}

- (void)selectOptions {
    // öffnet einen Dialog mit 3 Knöpfen und einem Chancel knopf
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"newsActionSheetTitle", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"buttonCancel", NULL) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"newsActionSheetButtonAllRead", NULL), NSLocalizedString(@"newsActionSheetButtonAllUnread", NULL), nil]; // Was wollen Sie machen? -alle als gelesen markieren-||-alle als ungelesen markieren-||-Abbrechen-
    
	//actionSheet.actionSheetStyle = self.navigationController.navigationBar.barStyle; // Benutzt den selben Style wie der navigationController
    //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
	[actionSheet showFromTabBar:self.tabBarController.tabBar]; // zeigt das Menü über der TabBar, verdeckt diese
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    
    NSError *error;
    
    NSMutableArray *mutableFetchResults = [[self.managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    if (buttonIndex == 0){
         
         for (int i = 0; i < [mutableFetchResults count]; i++) {
             [[mutableFetchResults objectAtIndex:i] setRead:[NSNumber numberWithBool:YES]];
         }
    } else if (buttonIndex == 1) {
        
        for (int i = 0; i < [mutableFetchResults count]; i++) {
            [[mutableFetchResults objectAtIndex:i] setRead:[NSNumber numberWithBool:NO]];
        }
    }
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]; // speichert
    
    // neuladen (dank Fetched result delegate) nicht nötig.
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // generiert eine Standard-UITableCell
    static NSString *cellIdentifier = @"NewsTableCellView"; // wir benennen die Zelle auch als CustomFileCell (Identifier = Klassenname)
    
    NewsTableCellView *cell = (NewsTableCellView *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // da dequeueResuableCellWithIdentifier eine UITableView Cell zur√ºckgibt, wird davor (CustomFileCell *) geschrieben, um den R√ºckgabewert so zu definieren, wie wir ihn brauchen (als CustomFileCell)
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NewsTableCellView" owner:self options:nil] lastObject];
        
        // über das NSBundle (mainBundle - Hauptprogramm; also auch die Resources) laden wir die angepasste Zelle (TableCellView)
        // gibt ein Array zur√ºck, mit allen Top-Level-Objekten der XIB-Datei - diese werden mit alloc init und autorelease instantiiert -> wir m√ºssen uns nicht um die Speicherverwaltung k√ºmmern
        // lastObject, da nur eins drin ist
    }
    
    // Configure the cell.
    
    // wir benutzen den aktuellen Article...
    Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // und setzen den title als Label...
    cell.title.text = [article valueForKey:@"title"];
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    cell.date.text = [dateFormatter stringFromDate:[article valueForKey:@"date"]];
    //[dateFormatter release]; -- BAD EXEP
    
    // und den Lesestatus auf gelesen bzw. ungelesen
    if ([[article valueForKey:@"read"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
        cell.unread.image = nil;
    } else {
        if (([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)) {
            // iOS 7+
            cell.unread.image = [UIImage imageNamed: @"unread7.png"];
        } else {
            cell.unread.image = [UIImage imageNamed: @"unread.png"];
        }
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Article *article = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    article.read = [NSNumber numberWithBool:YES];
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    
    NSLog(@"Artikel: %@ - Read:%@", article.title, article.read);
    
    //[self.tableView refresh]; // updatet View, um unschöne änderungen der Custom Cell zu unterbinden
    
    NewsDetailViewController *nextController = [[NewsDetailViewController alloc] init];
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    article.title, @"title",
                                    article.date, @"date",
                                    article.message, @"message",
                                    article.link, @"link",
                                    nil];
    
    nextController.item = [dict copy]; // dictionary wird kopiert (da es ja dann wieder freigegeben wird und so die Speicheradresse nicht mehr mit dem dictionay belegt ist)
    
    //hide tabbar
    nextController.hidesBottomBarWhenPushed = YES;
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:nextController animated:YES];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}

- (void)configureCell:(NewsTableCellView *)cell atIndexPath:(NSIndexPath *)indexPath {
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([[managedObject valueForKey:@"read"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
        cell.unread.image = nil;
        
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    } else {
        if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending) {
            // iOS 7+
            cell.unread.image = [UIImage imageNamed: @"unread7.png"];
        } else {
            cell.unread.image = [UIImage imageNamed: @"unread.png"];
        }
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    /*
     Set up the fetched results controller.
    */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];// nicht aufsteigend, da wir ja das neuste Datum als erstes (und somit das "größte") haben wollen
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.

	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

#pragma mark - Fetched results controller delegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView refresh];
 }
*/

@end
