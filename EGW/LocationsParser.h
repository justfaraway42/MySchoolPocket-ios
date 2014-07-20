//
//  LocationsParser.h
//  EGW
//
//  Created by Justus Dög on 22.09.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "State.h"
#import "Community.h"
#import "School.h"

@interface LocationsParser : NSObject <NSXMLParserDelegate> {
	NSMutableString *contentsOfCurrentProperty;
	NSManagedObjectContext *managedObjectContext;
	State *currentState;
	Community *currentCommunity;
    NSString *elementName2;
}

@property (strong, nonatomic) NSMutableString *currentSchoolName;
@property (strong, nonatomic) NSMutableString *currentSchoolFeed;
@property (strong, nonatomic) NSMutableString *currentSchoolTimetablesNames;
@property (strong, nonatomic) NSMutableString *currentSchoolTimetablesUrls;
@property (strong, nonatomic) NSMutableString *currentSchoolTimetablesClasses;
@property (strong, nonatomic) NSMutableString *currentSchoolRepresentationUrls;
@property (strong, nonatomic) NSMutableString *currentSchoolPhoneNumber;
@property (strong, nonatomic) NSMutableString *currentSchoolWebsite;
@property (strong, nonatomic) NSMutableString *currentSchoolEmailAddress;
@property (strong, nonatomic) NSMutableString *currentSchoolAddress;

@property (retain, nonatomic) NSManagedObjectContext *managedObjectContext;

-(BOOL)parseXMLFileAtURL:(NSURL *)URL parseError:(NSError **)error;
-(void) emptyDataContext;
@end
