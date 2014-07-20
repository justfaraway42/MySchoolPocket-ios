//
//  LocationsParser.m
//  EGW
//
//  Created by Justus Dög on 22.09.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "LocationsParser.h"
#import "AppDelegate.h"


@implementation LocationsParser

@synthesize managedObjectContext;

-(id) init {
    
	self = [super init];
	managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
	
	return self;
}


- (BOOL)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error
{
	BOOL result = YES;
	
	// /Applications/MyExample.app/MyFile.xml
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:URL];
    // Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
    [parser setDelegate:self];
    // Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
    [parser setShouldProcessNamespaces:NO];
    [parser setShouldReportNamespacePrefixes:NO];
    [parser setShouldResolveExternalEntities:NO];
    
    [parser parse];
    
    NSError *parseError = [parser parserError];
    if (parseError && error) {
        *error = parseError;
		result = NO;
    }
	
	return result;
}

- (void)emptyDataContext {
    // Get all counties, It's the top level object and the reference cascade deletion downward
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"State" inManagedObjectContext:[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]];
    [request setEntity:entity];
    
    // If a sort key was passed, use it for sorting.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    
    NSMutableArray *mutableFetchResults = [[managedObjectContext executeFetchRequest:request error:&error] mutableCopy];

    // Delete all Counties
    for (int i = 0; i < [mutableFetchResults count]; i++) {
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext] deleteObject:[mutableFetchResults objectAtIndex:i]];
    }

    [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]; // speichert
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if (qName) {
        elementName = qName;
    }
    
    elementName2 = elementName;
	
	// If it's the start of the XML, remove everything we've stored so far
        if([elementName isEqualToString:@"data"])
        {
            [self emptyDataContext];
            return;
        }
    
    if ([elementName isEqualToString:@"state"]) {
        currentState = (State *)[NSEntityDescription insertNewObjectForEntityForName:@"State" inManagedObjectContext:managedObjectContext];
		[currentState setName:[attributeDict objectForKey:@"name"]];
		
        return;
    } else if ([elementName isEqualToString:@"community"]) {
        
		currentCommunity = (Community *)[NSEntityDescription insertNewObjectForEntityForName:@"Community" inManagedObjectContext:managedObjectContext];
		[currentCommunity setName:[attributeDict objectForKey:@"name"]];
		
        NSLog(@"COMMUNITY: %@",[attributeDict objectForKey:@"name"]);
        
		// Add the state as a child to the current Country
		[currentState addStateToCommunityObject:currentCommunity];
    } else if([elementName isEqualToString:@"school"]) {
        
        self.currentSchoolName = [attributeDict objectForKey:@"name"];
        self.currentSchoolFeed = [NSMutableString string];
        self.currentSchoolTimetablesNames = [NSMutableString string];
        self.currentSchoolTimetablesUrls = [NSMutableString string];
        self.currentSchoolTimetablesClasses = [NSMutableString string];
        self.currentSchoolRepresentationUrls = [NSMutableString string];
        self.currentSchoolPhoneNumber = [NSMutableString string];
        self.currentSchoolWebsite = [NSMutableString string];
        self.currentSchoolEmailAddress = [NSMutableString string];
        self.currentSchoolAddress = [NSMutableString string];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (qName) {
        elementName = qName;
    }
    
	// If we're at the end of a state. Save changes to object model
	if ([elementName isEqualToString:@"state"]) {
		// Sanity check
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] saveContext]; // speichert
    }
    
    if ([elementName isEqualToString:@"school"]) {
        School *c = (School *)[NSEntityDescription insertNewObjectForEntityForName:@"School" inManagedObjectContext:managedObjectContext];
        
        [c setName:self.currentSchoolName];
        [c setFeed:self.currentSchoolFeed];
        [c setTimetablesNames:self.currentSchoolTimetablesNames];
        [c setTimetablesUrls:[self stringByReplacingSpecialCharacteresFromString:self.currentSchoolTimetablesUrls]];
        [c setTimetablesClasses:self.currentSchoolTimetablesClasses];
        [c setRepresentationUrls:[self stringByReplacingSpecialCharacteresFromString:self.currentSchoolRepresentationUrls]];
        [c setPhoneNumber:[self stringByReplacingSpecialCharacteresFromString:self.currentSchoolPhoneNumber]];
        [c setWebsite:[self stringByReplacingSpecialCharacteresFromString:self.currentSchoolWebsite]];
        [c setEmailAddress:[self stringByReplacingSpecialCharacteresFromString:self.currentSchoolEmailAddress]];
        [c setAddress:[[self.currentSchoolAddress stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByReplacingOccurrencesOfString:@", " withString:@",\n"]];
        
        [currentCommunity addCommunityToSchoolObject:c];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([elementName2 isEqualToString:@"feed"]) {
        [self.currentSchoolFeed appendString:string];
    } else if ([elementName2 isEqualToString:@"timetables_names"]) {
        [self.currentSchoolTimetablesNames appendString:string];
    } else if ([elementName2 isEqualToString:@"timetables_urls"]) {
        [self.currentSchoolTimetablesUrls appendString:string];
    } else if ([elementName2 isEqualToString:@"timetables_classes"]) {
        [self.currentSchoolTimetablesClasses appendString:string];
    } else if ([elementName2 isEqualToString:@"representation_urls"]) {
        [self.currentSchoolRepresentationUrls appendString:string];
    } else if ([elementName2 isEqualToString:@"phone_number"]) {
        [self.currentSchoolPhoneNumber appendString:string];
    } else if ([elementName2 isEqualToString:@"website"]) {
        [self.currentSchoolWebsite appendString:string];
    } else if ([elementName2 isEqualToString:@"email_address"]) {
        [self.currentSchoolEmailAddress appendString:string];
    } else if ([elementName2 isEqualToString:@"address"]) {
        [self.currentSchoolAddress appendString:string];
    }
}

- (NSString *)stringByReplacingSpecialCharacteresFromString:(NSString *)string {
    
    NSString *stringWithoutSpecialCharacteres = string;
    
    // Leerzeichen, Leerzeilen und Tabs String entfernen
    stringWithoutSpecialCharacteres = [stringWithoutSpecialCharacteres stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringWithoutSpecialCharacteres = [stringWithoutSpecialCharacteres stringByReplacingOccurrencesOfString:@"	" withString:@""];
    stringWithoutSpecialCharacteres = [stringWithoutSpecialCharacteres stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return stringWithoutSpecialCharacteres;
}

@end
