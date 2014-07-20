//
//  SchoolsViewController.h
//  EGW
//
//  Created by Justus Dög on 22.09.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "State.h"
#import "School.h"
#import "LocationsParser.h"
#import "Protocols.h"

@interface SchoolsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
    
	NSManagedObjectContext *managedObjectContext;
	NSMutableArray *entityArray;
	NSString *entityName;
	NSPredicate *entitySearchPredicate;
    School *currentSchool;
}

- (void)loadLocations;
- (void)pushCancel;

@property (nonatomic, retain) School *currentSchool;
@property (nonatomic, retain) NSPredicate *entitySearchPredicate;
@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSMutableArray *entityArray;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
