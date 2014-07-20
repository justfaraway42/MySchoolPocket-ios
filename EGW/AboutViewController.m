//
//  AboutViewController.m
//  EGW
//
//  Created by Justus Dög on 13.10.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"buttonDone", NULL) style:UIBarButtonItemStyleDone target:self action:@selector(pushCancel)];
    self.navigationItem.rightBarButtonItem = doneButton;
    self.title = NSLocalizedString(@"settingsAboutApp", NULL);
    versionLabel.text =[NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"appVersion", NULL), [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    
    releasenotesLabel.text = [NSLocalizedString(@"appReleaseNotes", NULL) stringByReplacingOccurrencesOfString:@"<year>" withString:[formatter stringFromDate:[NSDate date]]];
    
}

- (void)pushCancel {
    [self dismissModalViewControllerAnimated:YES];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)viewDidUnload {
    versionLabel = nil;
    releasenotesLabel = nil;
    [super viewDidUnload];
}
@end
