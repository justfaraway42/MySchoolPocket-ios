//
//  SwitchTableCell.h
//  Info
//
//  Created by Justus Dög on 15.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SwitchTableCell7 : UITableViewCell {
    
    UILabel *textLabel;
    UISwitch *changeSwitch;
}
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UISwitch *changeSwitch;
- (IBAction)changeSwitch:(id)sender; // wird benötigt, um target zu setzen

@end
