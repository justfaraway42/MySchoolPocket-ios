//
//  LoaingOverlay.m
//  Timetables
//
//  Created by Justus Dög on 02.06.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "OverlayView.h"
#import <QuartzCore/QuartzCore.h> // benötigt für den cornerRadius

@implementation OverlayView

@synthesize messageLabel, iconLabel, spinner, delegate;

static OverlayView *overlayView = nil;

#pragma mark -
#pragma mark Public Methods

- (void)showActivity:(NSString *)message {
    [iconLabel removeFromSuperview];
    
    [self show];
    [self showSpinner];
    [self setMessage:message];
}

- (void)updateMessage:(NSString *)message {
    [self setMessage:message];
}

- (void)showSuccess:(NSString *)success withIcon:(NSString *)icon {
    [spinner removeFromSuperview];
    
    [self setIcon:icon];
    [self setMessage:success];
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:1.5];

        [self setAlpha:0];
        
        [UIView setAnimationDelay: UIViewAnimationCurveEaseOut]; // beginnt langsam und wird schneller
        [UIView commitAnimations];
        
        [self performSelector:@selector(hide) withObject:nil afterDelay:1.5];
}

- (void)showError:(NSString *)error withIcon:(NSString *)icon {
    [spinner removeFromSuperview];
    
    [self setIcon:icon];
    [self setMessage:error];
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:3];
        
        [self setAlpha:0];
        
        [UIView setAnimationDelay: UIViewAnimationCurveEaseOut];
        [UIView commitAnimations];
        
        [self performSelector:@selector(hide) withObject:nil afterDelay:3];
}

#pragma mark -
#pragma mark OverlayView

- (id)init {
    if (overlayView == nil) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        /*
         das keyWindow ist das ganz oben liegende Fenster (also das Fenster, welchem zuletzt gesagt wurde, es soll sich selber darstellen)
         <UIWindow: 0x4e33d10; frame = (0 0; 320 480); opaque = NO; autoresize = RM+BM; layer = <CALayer: 0x4e33ec0>>
         größe des Windows: 320x480
        */
        
        CGFloat width = 160;
        CGFloat height = 160;
        CGRect centeredFrame = CGRectMake(keyWindow.bounds.size.width/2 - width/2,
                                          keyWindow.bounds.size.height/2 - height/2,
                                          width,
                                          height);
        /*
         CGRect ist eine STRUKTUR (Ansammlung von Informationen) - beeinhaltet Information POSITION und GRÖßE
         
         -> Documentation - View Programming Guide for iOS - “View and Window Architecture” && "Views"
         
         CGRect CGRectMake (
         CGFloat x (Die X-Koordinate des Nullpunktes des Vierecks),
            
             keyWindow.bounds.size.width
             Rand des keyWindows (keyWindows.bounds).für die Breite (size.width) = 320 (/2 = 160)
             
             - width
             - die Größe des neuen Fensters = 160 (/2 = 80)
             
             160 - 80 = 80 -> Nullpunkt für dei Breite des Vierecks (x = 80)
         
         CGFloat y (Die Y-Koordinate des Nullpunktes des Vierecks),
         
            Höhe des aktuellen Fensters = 480 (/2 = 240)
            Höhe des neuen Fensters = 160 (/2 = 80)
            
            240 - 80 = 160-> Nullpunkt für dei Höhe des Vierecks (y = 160)
         
         CGFloat width (Die Breite des Vierecks - 160),
         
         CGFloat height (Die Höhe des Vierecks - 160)
         );
        */

        overlayView = [[OverlayView alloc] initWithFrame:centeredFrame];
        
        overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        overlayView.alpha = 0;
        
        overlayView.layer.cornerRadius = 10;
        
        overlayView.userInteractionEnabled = NO;
        overlayView.autoresizesSubviews = YES;
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |  UIViewAutoresizingFlexibleTopMargin |  UIViewAutoresizingFlexibleBottomMargin;

        [[NSNotificationCenter defaultCenter] addObserver:overlayView selector:@selector(deviceHasChangedOrientation) name:UIDeviceOrientationDidChangeNotification object:nil]; // animierter Übergang
        
    }
    
	return overlayView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark -

- (void)show {
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 0);
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 90);
            break;
            
            //case UIDeviceOrientationPortraitUpsideDown:
            //    self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 180);
            //    break;
            
        case UIDeviceOrientationLandscapeRight:
            self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 270);
            break;
            
        default:
            break;
    }
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    // wir fügen uns selbst (als UIView) dem keyWindow als Unterview (Subview) hinzu
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        
        [self setAlpha:1];
        //[self setFrame:CGRectMake(0,0,320,100)];
        
        [UIView setAnimationDelay:UIViewAnimationCurveEaseIn]; // beginnt schnell und wird langsamer
        [UIView commitAnimations];
}

- (void)hide {
    [spinner removeFromSuperview];
    [iconLabel removeFromSuperview];
    
    self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 0); // zurücksetzen der Orientation
    
    if ([self.delegate respondsToSelector:@selector(removedOverlayView)]) {
        [self.delegate performSelector:@selector(removedOverlayView)]; // die aufrufende Klasse (delegate) wird benachrichtig
    }
    
    [self removeFromSuperview];
}

#pragma mark -
#pragma mark Icon & Spinner

- (void)setIcon:(NSString *)icon {
    self.iconLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,self.bounds.size.height/2-50/2,self.bounds.size.width-20,50)];
    
    
    iconLabel.backgroundColor = [UIColor clearColor];
    iconLabel.opaque = NO;
    iconLabel.textColor = [UIColor whiteColor];
    iconLabel.font = [UIFont boldSystemFontOfSize:50];
    iconLabel.textAlignment = UITextAlignmentCenter;
    iconLabel.shadowColor = [UIColor darkGrayColor];
    iconLabel.shadowOffset = CGSizeMake(1,1);
    iconLabel.adjustsFontSizeToFitWidth = YES;
    
    [self addSubview:iconLabel];
    
    iconLabel.text = icon;
}

- (void)showSpinner {
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    spinner.frame = CGRectMake(round(self.bounds.size.width/2 - spinner.frame.size.width/2),
                               round(self.bounds.size.height/2 - spinner.frame.size.height/2),
                               spinner.frame.size.width,
                               spinner.frame.size.height);
	
	[self addSubview:spinner];
	[spinner startAnimating];
}

#pragma mark -
#pragma mark Message

- (void)setMessage:(NSString *)message {
    if (messageLabel == nil) {
        // wenn es vorher noch keinen Status (UILabel) gabe, wird dieser erstellt
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,self.bounds.size.height-45,self.bounds.size.width-20,30)];
        
        /*
         die Größe des initialisierte UIView beträgt 160 x 160
         
         REMEMBER: the upper left corner is 0.0 [x], 0.0 [y]
         
         X-Koordinate: X=10 (12,5 points vom Rand des UIViews entfernt)
         Y-Koordinate: Y=115 (160 - 45)
         Breite: 140 (160-20)
         Höhe: 30
        */
        
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.opaque = NO;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.font = [UIFont boldSystemFontOfSize:17];
        messageLabel.textAlignment = UITextAlignmentCenter;
        messageLabel.shadowColor = [UIColor darkGrayColor];
        messageLabel.shadowOffset = CGSizeMake(1,1);
        messageLabel.adjustsFontSizeToFitWidth = YES;
        
        [self addSubview:messageLabel];
    }
    
    messageLabel.text = message; // wenn es vorher schon einen Status gab, wird dieser nur aktualisiert
}

#pragma mark -
#pragma mark Orientation

- (void)deviceHasChangedOrientation {
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
        /*
         Umfang eines Kreises
         U = 2πr // da der Radius hier unwichtig ist, setzen wir für r = 1 ein
         U = 2π
         
         Vollwinkel eines Kreises
         360°
         
         Beziehung
         
         Winkel im Bogenmaß (α)     2π
         ---------------------- = ------ | :2
         Winkel im Gradmaß (α°)    360°
         
         
          α     π
         --- = ----   | * α°
          α°   180°
         
         
                π 
         α  = ----- * α°
               180°
         
         
         α = (M_PI / 180 * α°)
        */
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationPortrait:
            self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 0);
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 90);
            break;
            
        //case UIDeviceOrientationPortraitUpsideDown:
        //    self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 180);
        //    break;
        
        case UIDeviceOrientationLandscapeRight:
            self.transform = CGAffineTransformMakeRotation(M_PI / 180 * 270);
            break;
            
        default:
            break;
    }
        
    [UIView commitAnimations];
}

@end