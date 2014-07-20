//
//  TimetablesDetailViewController.h
//  Timetables
//
//  Created by Justus Dög on 23.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlansViewController.h"
#import "OverlayView.h"


@interface PlansDetailViewController : UIViewController <UIActionSheetDelegate, NSURLConnectionDataDelegate, UIDocumentInteractionControllerDelegate> {
    // ActionSheet für das Menü
    
    NSString *currentName;
    NSString *currentURL;
    NSDate *currentDate;
    NSURL *saveurl;
    NSString *savepath;
    
    NSDate *oldDate;
    
    IBOutlet UIWebView *__unsafe_unretained webView;
    IBOutlet UILabel *__unsafe_unretained lastUpdate;
    IBOutlet UIToolbar *__unsafe_unretained toolbar;
    IBOutlet UIBarButtonItem *__unsafe_unretained pushRefresh;
    
    OverlayView *overlayView;
    NSMutableData *responseData;
    NSURLConnection *URLConnection;
    
    UILabel *percentLabel;
    UILabel *sizeLabel;
    NSString *mimeType, *textEncoding;
    NSInteger fileSize;
    
    UIDocumentInteractionController *interactionController;
}

@property (nonatomic, strong) NSString *currentName;
@property (nonatomic, strong) NSString *currentURL;
@property (nonatomic, strong) NSDate *currentDate;
@property (strong) NSURL *saveurl;

@property (unsafe_unretained) IBOutlet UIWebView *webView;
@property (unsafe_unretained) IBOutlet UILabel *lastUpdate;
@property (unsafe_unretained) IBOutlet UIToolbar *toolbar;
@property (unsafe_unretained) IBOutlet UIBarButtonItem *pushRefresh;

@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLConnection *URLConnection;

@property (nonatomic, strong) IBOutlet UILabel *percentLabel;
@property (nonatomic, strong) IBOutlet UILabel *sizeLabel;

@property (nonatomic, strong) UIDocumentInteractionController *interactionController;

@property (strong) OverlayView *overlayView;

- (IBAction)pushRefresh:(id)sender;

- (void)loadData;

- (void)showOverlayView;
- (void)successfulOverlayView;
- (void)errorOverlayView;
- (void)removedOverlayView;

- (void)updateDate;

@end
