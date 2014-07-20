//
//  AboutViewController.h
//  EGW
//
//  Created by Justus Dög on 13.10.12.
//  Copyright (c) 2012 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController {
    
    IBOutlet UILabel *versionLabel;
    IBOutlet UITextView *releasenotesLabel;
    
}

- (void)pushCancel;

@end
