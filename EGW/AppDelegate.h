//
//  EGWAppDelegate.h
//  EGW
//
//  Created by Justus Dög on 16.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UITabBarController <UIApplicationDelegate, UITabBarControllerDelegate> {
    // UITabBar Controller oben ^ und "EGWAppDelegate" als Class vom UITabBarController im InterfaceBuilder von "MainWindow.xib" eintragen !!!
    NSUserDefaults *defaults;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (weak, nonatomic) IBOutlet UITabBar *tabBar;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (void)updateBadgeNumber;
- (NSURL *)applicationDocumentsDirectory;

@end
