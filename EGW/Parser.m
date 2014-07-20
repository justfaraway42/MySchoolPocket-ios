//
//  Parser.m
//  News
//
//  Created by Justus Dög on 06.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "Parser.h"
#import "AppDelegate.h"
#import "NewsViewController.h"

@implementation Parser

@synthesize managedObjectContext;
@synthesize responseData;
@synthesize currentTitle;
@synthesize currentDate;
@synthesize currentDescription;
@synthesize currentLink;

- (id)init {
    self = [super init];
    
    managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en-UK"]];
    /*
     Wir benutzen eine englischsprachiche Location (en-UK -> also United Kingdom) um unser Datum mit dem NSDateFormatter in ein NSDate umzuwandeln, da dort die UTC (Coordinated Universal Time) gilt - heute gültige Weltzeit
     Da in Deutschland die Mitteleuropäische Zeit (MEZ, engl. Central European Time, CET) bzw. die die Mitteleuropäische Sommerzeit (MESZ, engl. Central European Summer Time) gilt, würde sonst die Interpretation der Zeitzohne (+0100 bzw. +0200) zu Fehlern führen
     http://developer.apple.com/library/ios/#qa/qa1480/_index.html
    */
    [dateFormatter setDateFormat:@"EEE, d MMM yyyy HH:mm:ss Z"];
    /*
     NSString: Fri, 01 Jan 2010 00:00:00 +0100 (Mitteleuropäische Zeit (MEZ, engl. Central European Time, CET))
     
     NSDate: 2009-12-31 23:00:00 +0000
     */
    
    return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)parseXMLFileAtURL:(NSURL *)URL {
    self.responseData = [NSMutableData data];
    
    // mit NSURLConnection werden die XML-Daten geladen
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)parseXMLFileFrom:(id<NewsParserDelegate>)passedDelegate with:(NSURL *)url {
    delegate = passedDelegate;
    
    self.responseData = [NSMutableData data];
    
    // mit NSURLConnection werden die XML-Daten geladen
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[NSURLConnection connectionWithRequest:request delegate:self];
}

#pragma mark -
#pragma mark NSConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.responseData setLength:0]; // wir setzen unser NSMutableData auf die Länge 0 (wird komplett geleert), da wir so vorherige Antworten löschen
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Recived another block of data. Appending to existing data
    [self.responseData appendData:data];
    
    // vom Server bekommen wir jetzt die Daten zurück - da dies durchaus mehrfach geschieht (also in einzelnen Blocks), hängen wir den aktuellen Block immer an die schon existierenden Daten dran (appendData)
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    
    [delegate endParsingWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Once this method is invoked, "serverresponseData" contains the complete
    // wird erst aufgerufen, wenn die Daten fertig geladen sind (wenn kein appendData mehr erforderlich ist)
	
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:self.responseData];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    /*
     hier benutzen wir nun NSXMLParser um die erhaltenen XML-Daten (responseDataData) zu verarbeiten (zu parsen)
     eigentlich könnte auch NSXMLParser erst die URL aufrufen, downloaden und verarbeiten - dies würde jedoch das UserInterface für die Zeit sperren; außerdem soll das Programm den connectionActivityIndicator in der Menüzeile anzeigen, während die Daten geladen und verarbeitet werden
    */
	[parser setDelegate:self];
	[parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError) {
		NSLog(@"Error while parsing: %@", [parseError userInfo]);
    }
}

#pragma mark -
#pragma mark Parser Methods

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:managedObjectContext];
    [request setEntity:entity];
    
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    
    mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
    
    allArticles = [mutableFetchResults count];
    
    /*
     NSLog(@"-----momentan gespeichert:-----");
     
     for (int i = 0; i < [mutableFetchResults count]; i++) {
     
     NSLog(@"Artikel: %@ vom %@: gelesen %@", [[mutableFetchResults objectAtIndex:i] title], [[mutableFetchResults objectAtIndex:i] date], [[mutableFetchResults objectAtIndex:i] read]);
     // gibt Artikelname, -datum und Lesestatus zurück
     }
    */
    
    if ([mutableFetchResults count] != 0) {
        lastArticleDate = [[mutableFetchResults lastObject] date];
        lastArticleTitle = [[mutableFetchResults lastObject] title];
        NSLog(@"letzter Titel: %@ vom letztes Datum: %@", lastArticleTitle, lastArticleDate);
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
    // attributeDict = version = "2.0"
    
    currentElement = [elementName copy];
    
	// Create a new County
    if ([elementName isEqualToString:@"item"]) {
        
        self.currentTitle = [NSMutableString string];
        self.currentDate = [NSMutableString string];
        self.currentDescription = [NSMutableString string];
        self.currentLink = [NSMutableString string];
        
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([currentElement isEqualToString:@"title"]) { // @"title" wird gesucht -> <title>[…]</title>
        [self.currentTitle appendString:string];
        
        // kommt Blockweise:    1. Der ADAC unterst
        //                      2. ützt unsere Schüler des GK Physik als Fahranfänger
        // desshalb immer an den aktuellen String anhängen (append)
        
    } else if ([currentElement isEqualToString:@"description"]) {
        [self.currentDescription appendString:string];
        
    } else if ([currentElement isEqualToString:@"link"]) {
        [self.currentLink appendString:string];
        
    } else if ([currentElement isEqualToString:@"pubDate"]) {
        
        [self.currentDate appendString:string];
        
        NSString *date;
        
        date = [currentDate stringByReplacingOccurrencesOfString:@" " withString:@""];
        date = [currentDate stringByReplacingOccurrencesOfString:@"	 " withString:@""];
        date = [currentDate stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        [self.currentDate setString:date];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"item"]) {
        
        if (allArticles == 0) {
            
            [self addCurrentItem];
        } else {
            
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            
            [request setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:managedObjectContext]];
            
            // Set the predicate -- much like a WHERE statement in a SQL database
            // **DOKU http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html#//apple_ref/doc/uid/TP40001795-CJBDBHCB
            
            [request setPredicate:[NSPredicate predicateWithFormat:@"(title == %@) AND (date == %@)", currentTitle, [dateFormatter dateFromString:currentDate]]];
            // es wird nach Artikeln gesucht, welche das gleiche Datum und den gleichen Titel haben
            
            NSUInteger count = [managedObjectContext countForFetchRequest:request error:nil];
            if (count == 0) { 
                // neuer Artikel mit dem gleichen Datum
                [self addCurrentItem];
            } else {
                // nur letzter Artikel des XML
                currentTitle = nil;
                currentDate = nil;
                currentDescription = nil;
                currentLink = nil;
            }
            
            // Speichert ALLE neuen Artikel - ab bestimmter Anzahl löschen? **FIX_LATER
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    
    [delegate endParsing];
}

#pragma mark -
#pragma mark Privat Methods

- (void)addCurrentItem {
    currentArticle = (Article *)[NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:managedObjectContext];
    
    // Sanity check
    if (currentArticle != nil) {
        
        currentArticle.title = self.currentTitle;
        currentArticle.message = currentDescription;
        currentArticle.link = currentLink;
        currentArticle.date = [dateFormatter dateFromString:currentDate];
        currentArticle.read = [NSNumber numberWithBool:NO];
        
        NSLog(@"Neuer Artikel eingefügt: %@ vom %@", currentTitle, currentDescription);
        
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext];
    }
}

- (void)dealloc {
    mutableFetchResults = NULL;
	managedObjectContext = NULL;
    
    responseData = NULL;
    currentTitle = NULL;
    currentDate = NULL;
    currentDescription = NULL;
    currentLink = NULL;
    delegate = NULL;
}

@end
