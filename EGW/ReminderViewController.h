//
//  ReminderView.h
//  EGW
//
//  Created by Justus Dög on 24.08.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderViewController : UIViewController <UITableViewDataSource, UITabBarDelegate> {
    UIDatePicker *datePicker;
    UITableView *tableView;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;

- (IBAction)pickedDateValueChanged:(id)sender;

@end
