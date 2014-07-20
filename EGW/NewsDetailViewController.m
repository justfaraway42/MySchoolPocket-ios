//
//  NewsDetailViewController.m
//  EGW
//
//  Created by Justus Dög on 16.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "NewsDetailViewController.h"

@implementation NewsDetailViewController

@synthesize item, webView;

- (BOOL)shouldAutorotate {
    return YES;
}

- (id)initWithItem:(NSDictionary *)selectedItem {
    self = [super initWithNibName:@"NewsDetailViewController" bundle:nil];

    self.item = selectedItem;
	
	return self;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/
    
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad { 
    [super viewDidLoad];
    
    self.title = [[item objectForKey:@"title"] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
 
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareLink)];
    
    // remove Shadow from UIWebView **SOURCE: http://stackoverflow.com/questions/1074320/remove-uiwebview-shadow
    
    for(UIView *wview in [[[webView subviews] objectAtIndex:0] subviews]) { 
        if([wview isKindOfClass:[UIImageView class]]) {
            wview.hidden = YES;
        } 
    }
    
    //[webView setOpaque:YES]; //in InterfaceBuilder
    webView.backgroundColor = [UIColor clearColor];
    
    [self loadHTML];
}

- (void)loadHTML {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    
    NSMutableString *data = [NSMutableString new];
    
    [data appendString:@"<html><head>"];
    [data appendString:@"<style>body { background-color:white; font-size:18x; font-family:HelveticaNeue; margin-left:15px; margin-right:15px; } .title { font-size:22px; font-family:Helvetica text-align:justify; } .date { font-size:12px; font-family:Helvetica; color:gray; text-align:right; } </style>"];
    [data appendString:@"</head><body>"];
    
    
    [data appendString:@"<b class=\"title\">"];
    [data appendString:[item objectForKey:@"title"]];
    [data appendString:@"</b>"];
    
    [data appendString:@"<div class=\"date\">"];
    [data appendString:[dateFormatter stringFromDate:[item objectForKey:@"date"]]];
    [data appendString:@"</div>"];
    
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    NSInteger imageWidth;
    
    if (orientation == UIDeviceOrientationPortrait) {
        imageWidth = 290; // 320 px Breite des iPhone-Displays - 2* 15px der WebView
        
    } else if ((orientation |= (UIDeviceOrientationLandscapeLeft | UIDeviceOrientationLandscapeRight))) { // |= "ODER GELICH"
        imageWidth = 450;
    }
    
    NSString *message = [item objectForKey:@"message"];
    
    message = [message stringByReplacingOccurrencesOfString:@"<img" withString:@"<img width=\"100%\" height=\"auto\""];
    
    message = [message stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"%@", message);
    
    [data appendString:message];
    
    [data appendString:@"</body></html>"];
    
    //[dateFormatter release];
    [self.webView loadHTMLString:data baseURL:nil];
}

- (void)shareLink {
    if (([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)) {
        //iOS 6+
        NSString *link = [item objectForKey: @"link"];
        
        link = [link stringByReplacingOccurrencesOfString:@" " withString:@" "];
        link = [link stringByReplacingOccurrencesOfString:@"	 " withString:@""];
        link = [link stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        
        link = [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        //self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        
        UIActivityViewController* activityViewController = [[UIActivityViewController alloc] initWithActivityItems:[NSArray arrayWithObjects:[NSURL URLWithString:link], nil] applicationActivities:nil];
        [self presentViewController:activityViewController animated:YES completion:^{}];
        
    } else {
        // URL direkt an Safari - Dialog mit einem OK und einem Chancel knopf
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"newsDetailsActionSheetTitle", NULL) delegate:self cancelButtonTitle:NSLocalizedString(@"buttonCancel", NULL) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"actionSheetButtonMobileSafari", NULL), nil]; // Willst Du den aktuellen Artikel in Safari öffnen? -OK-||-Abbrechen-
        
        //actionSheet.actionSheetStyle = self.navigationController.navigationBar.barStyle; // Benutzt den selben Style wie der navigationController
        //actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
	if (buttonIndex == 0) {
        
        NSString *link = [item objectForKey: @"link"];
        
        link = [link stringByReplacingOccurrencesOfString:@" " withString:@""];
        link = [link stringByReplacingOccurrencesOfString:@"	 " withString:@""];
        link = [link stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        link = [link stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        link = [link stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSLog(@"link: *%@*", link); // protokolliert die aufgerufene URL
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link]]; // übergibt URL an Safari
	}
}

// Override to allow orientations other than the default portrait orientation.
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
//    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
//}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [self setWebView:nil];
    [super viewDidUnload];
    // Release any stronged subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
