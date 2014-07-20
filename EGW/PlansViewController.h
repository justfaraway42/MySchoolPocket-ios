//
//  PlansViewController.h
//  Timetables
//
//  Created by Justus Dög on 23.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlansDetailViewController.h"


@interface PlansViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
	NSMutableArray *names;
    NSMutableArray *urls;
    NSArray *classes;
    
    NSUserDefaults *defaults;
    NSInteger selectedItemTag;
    NSInteger today;
}

@end