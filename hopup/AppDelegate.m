//
//  AppDelegate.m
//  hopup
//
//  Created by Edward Kim on 8/27/12.
//  Copyright (c) 2012 Edward Kim. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationManagerStore.h"
#import "MenuViewController.h"
#import "RestKit.h"
#import "SessionStore.h"
#import "TagsStore.h"

NSString *applicationURL;

@interface AppDelegate ()
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    applicationURL = @"http://ancient-plains-4741.herokuapp.com/";
    [RKClient clientWithBaseURLString:applicationURL];
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    //app launched with local notification
    if (localNotif) {
        
    }

    if ([[SessionStore sharedStore] signedIn]) {
        //TODO - tag may not be cached, only created tags are cached here, need chachwithtopic id
        [[TagsStore sharedStore] cacheTagsWithBlock:^(BOOL successful) {
            if (successful) {
                [LocationManagerStore sharedStore]; //initiate location store so it can handle the region
            }
        }];
    }
    

    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[MenuViewController new]];
    [self.window makeKeyAndVisible];
    [self setAppearance];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setAppearance {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"BackgroundNavigationBar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"ButtonBack.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 13.0, 0.0, 9.0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[[UIImage imageNamed:@"ButtonBackSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0, 13.0, 0.0, 9.0)] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"ButtonNavigationBar.png"] resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage imageNamed:@"ButtonNavigationBarSelected.png"] resizableImageWithCapInsets:UIEdgeInsetsZero] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
    [[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"BackgroundNavigationBar.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

@end
