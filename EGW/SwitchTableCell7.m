//
//  SwitchTableCell.m
//  Info
//
//  Created by Justus Dög on 15.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "SwitchTableCell7.h"


@implementation SwitchTableCell7

@synthesize changeSwitch;
@synthesize textLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (IBAction)changeSwitch:(id)sender {
}
@end
