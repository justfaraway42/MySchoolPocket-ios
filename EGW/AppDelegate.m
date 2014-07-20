//
//  EGWAppDelegate.m
//  EGW
//
//  Created by Justus Dög on 16.07.11.
//  Copyright 2011 Europäisches Gymnasium Waldenburg. All rights reserved.
//

#import "AppDelegate.h"
#import "NewsViewController.h"
#import "NewsDetailViewController.h"
#import "PlansViewController.h"
#import "PlansDetailViewController.h"
#import "SchoolsViewController.h"
#import "PlansViewController.h"

@implementation AppDelegate

@synthesize window;
@synthesize tabBarController;

@synthesize managedObjectModel=_managedObjectModel;
@synthesize managedObjectContext=_managedObjectContext;
@synthesize persistentStoreCoordinator=_persistentStoreCoordinator;

// don't unterstand this way of synthesize **FIX_LATER


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"notFirstStart"]) {
        
        [defaults setInteger:15 forKey:@"maxArticles"];
        [defaults setBool:YES forKey:@"reloadSwitch"];
        [defaults setBool:YES forKey:@"loadTimetablesManually"];
        [defaults setBool:YES forKey:@"todaySwitch"];
        
        [defaults setBool:YES forKey:@"notFirstStart"];
        [defaults synchronize]; // save state
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    // die Statusbar wird wieder eingeblendet (ohne Animation)
    
    // Override point for customization after application launch. 
	NSManagedObjectContext *context = [self managedObjectContext];
	
	// We're not using undo. By setting it to nil we reduce the memory footprint of the app
	[context setUndoManager:nil];
    
	if (!context) {
        NSLog(@"Error initializing object model context");
		exit(-1);
    }
    
	// Create a table view controller
	NewsViewController *rootViewController = [[NewsViewController alloc] initWithStyle:UITableViewStylePlain];
	rootViewController.managedObjectContext = context;
	
    // Add the navigation controller's view to the window and display.
    
    window.rootViewController = tabBarController;
    [window makeKeyAndVisible];
    
    [[[tabBarController.tabBar items] objectAtIndex:0] setTitle:NSLocalizedString(@"news", NULL)];
    [[[tabBarController.tabBar items] objectAtIndex:1] setTitle:NSLocalizedString(@"timetables", NULL)];
    [[[tabBarController.tabBar items] objectAtIndex:2] setTitle:NSLocalizedString(@"representation", NULL)];
    [[[tabBarController.tabBar items] objectAtIndex:3] setTitle:NSLocalizedString(@"info", NULL)];
    [[[tabBarController.tabBar items] objectAtIndex:4] setTitle:NSLocalizedString(@"settings", NULL)];
    
    tabBarController.delegate = self;
    
    int activeTab = [defaults integerForKey:@"activeTab"];
    [tabBarController setSelectedIndex:activeTab];
    
    if (([[[UIDevice currentDevice] systemVersion] compare:@"3.0" options:NSNumericSearch] != NSOrderedDescending)) {
        // iOS 3-
        if ([window respondsToSelector:@selector(setRootViewController:)]) {
            window.rootViewController = tabBarController;
        } else {
            [window addSubview:tabBarController.view];
        }
    }
    
    // Register Local Notifications
    
    application.applicationIconBadgeNumber = 0;
	
	// Handle launching from a notification
	UILocalNotification *localNotif =
	[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
		NSLog(@"Recieved Notification %@",localNotif);
	}
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	// Handle the notificaton when the app is running
	NSLog(@"Recieved Notification %@",notification);
}

- (void)awakeFromNib {
    NewsViewController *rootViewController = (NewsViewController *)[self.navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [self updateBadgeNumber];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Saves changes in the application's managed object context before the application terminates.
    
    // FÜR ÄLTERE GERÄTE MUSS HIER DIE BADGE NUMBER AKTUALISIERT WERDEN (da diese ja Applikationen nicht im Hintergrund laufen lassen können)
    [self updateBadgeNumber];
    
    [self saveContext];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        // wenn die im tabBarController (diese Klasse) angewählte View eine Art der Klasse UINavigationController ist ...
        
        if (([[(UINavigationController *)self.selectedViewController visibleViewController] isKindOfClass:[PlansDetailViewController class]]) || ([[(UINavigationController *)self.selectedViewController visibleViewController] isKindOfClass:[NewsDetailViewController class]])) {
            // ... und die darin (im UINavigationController) enthaltene und gezeigte View von der Klasse TimetablesDetailViewController ist, dreht sich das Device in alle interfaceOrientations - außer in PortraitUpsideDown
            
            return (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight);
        } else {
            return UIInterfaceOrientationMaskPortrait;
        }
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
	if ([self.selectedViewController isKindOfClass:[UINavigationController class]]) {
        
		if (([[(UINavigationController *)self.selectedViewController visibleViewController] isKindOfClass:[PlansDetailViewController class]]) || ([[(UINavigationController *)self.selectedViewController visibleViewController] isKindOfClass:[NewsDetailViewController class]])) {
            
			return (interfaceOrientation == UIInterfaceOrientationPortrait ||interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
        }
    }
    
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark UITabBar Delegate Methods

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:item.tag forKey:@"activeTab"];
    [defaults synchronize];
}

#pragma mark -
#pragma mark Saving

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)  {
        
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)updateBadgeNumber {
    // update the Applications Badge Number
    
    if ([defaults boolForKey:@"badgeSwitch"] == YES) {
        // set badge
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:_managedObjectContext];
        [request setEntity:entity];
        
        // Set the predicate -- much like a WHERE statement in a SQL database
        [request setPredicate:[NSPredicate predicateWithFormat:@"read == %@", [NSNumber numberWithBool:NO]]]; 
        
        NSError *error;
        
        NSMutableArray *mutableFetchResults = [[_managedObjectContext executeFetchRequest:request error:&error] mutableCopy];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = [mutableFetchResults count];
    } else {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
}

#pragma mark -
#pragma mark Core Data stack

/*
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
*/

- (NSManagedObjectContext *)managedObjectContext {
    
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)  {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

/*
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
*/

- (NSManagedObjectModel *)managedObjectModel {
    
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"database" withExtension:@"mom"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return _managedObjectModel;
}

/*
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
*/

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"database.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's documents directory

/*
 Returns the URL to the application's Documents directory.
*/

- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
