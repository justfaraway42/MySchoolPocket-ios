//
//  RootViewController.h
//  News
//
//  Created by Justus Dög on 05.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Protocols.h"

@interface NewsViewController : UITableViewController <NSFetchedResultsControllerDelegate, UIActionSheetDelegate, NewsParserDelegate> {
    
    UIActivityIndicatorView *activityIndicator;
    NSManagedObjectContext *managedObjectContext;
	NSMutableArray *entityArray;
    
    NSUserDefaults *defaults;
}

- (void)selectOptions;
- (void)deleteOldArticles;

@property (nonatomic, strong) NSMutableArray *entityArray;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
