//
//  InfoView.h
//  Info
//
//  Created by Justus Dög on 14.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h> // IMPORT MessageUI.framework
#import <MapKit/MapKit.h>


@interface InfoViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate> {
    NSUserDefaults *defaults;
    NSArray *actionArray;
    NSArray *descriptionArray;
}

@end