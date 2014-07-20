//
//  LoaingOverlay.h
//  Timetables
//
//  Created by Justus Dög on 02.06.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OverlayView : UIView {
    id delegate;
    
    UILabel *iconLabel;
    UILabel *messageLabel;
    UILabel *newLabel;
    UIActivityIndicatorView *spinner;
}

@property (strong) id delegate;

@property (strong) UILabel *messageLabel;
@property (strong) UILabel *iconLabel;
@property (strong) UIActivityIndicatorView *spinner;

- (void)showActivity:(NSString *)message;
- (void)updateMessage:(NSString *)message;
- (void)showSuccess:(NSString *)success withIcon:(NSString *)icon;
- (void)showError:(NSString *)error withIcon:(NSString *)icon;

- (void)show;
- (void)showSpinner;
- (void)setIcon:(NSString *)icon;
- (void)setMessage:(NSString *)message;
- (void)hide;

- (void)deviceHasChangedOrientation;

@end
