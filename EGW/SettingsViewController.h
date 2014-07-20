//
//  SettingsView.h
//  Info
//
//  Created by Justus Dög on 14.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h> // IMPORT MessageUI.framework
#import "Protocols.h"

@interface SettingsViewController : UITableViewController <MFMailComposeViewControllerDelegate, UIPickerViewDelegate> {
    
    NSUserDefaults *defaults;
    NSMutableArray *sectionHeaders;
    NSInteger selectedValue;
}

// Properties ?

- (void)reloadOnStartup:(UISwitch *)reloadSwitch;
- (void)showBadge:(UISwitch *)badgeSwitch;

- (void)loadTimetablesManually:(UISwitch *)reloadSwitch;

- (void)showTodayFirst:(UISwitch *)todaySwitch;
- (void)loadRepresentationManually:(UISwitch *)reloadSwitch;

- (void)remindMe:(UISwitch *)remindSwitch;

@end