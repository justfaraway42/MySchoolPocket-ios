//
//  NewsDetailViewController.h
//  EGW
//
//  Created by Justus Dög on 16.01.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parser.h" // benötigt um die darin definierten Keys "title", "date", "description" und "link zu importieren"

@interface NewsDetailViewController : UIViewController <UIActionSheetDelegate> {
	NSDictionary *item;
    
    UIWebView *webView;
}

@property (nonatomic, strong) NSDictionary *item;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

- (id)initWithItem:(NSDictionary *)selectedItem;
- (void)loadHTML;

@end