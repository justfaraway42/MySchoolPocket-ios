//
//  PickerViewController.h
//  EGW
//
//  Created by Justus Dög on 25.09.13.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, UIPickerViewDelegate> {
    
    NSUserDefaults *defaults;
    NSInteger selectedValue;
}
@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSArray *array;

@property (strong, nonatomic) IBOutlet UITableView *pickerTableView;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerPickerView;

@end
