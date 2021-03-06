//
//  AppDelegate.m
//  FlowGateApp1
//
//  Created by tianb on 4/30/14.
//  Copyright (c) 2014 21cn. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
#import "MainViewController.h"

#import "DownloadViewController.h"
#import "WebViewController.h"


@implementation AppDelegate
//@synthesize flowgateSDK;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //self.ks = @"00000000000000000000000000847470";
    //self.tk = @"00000000000000000000000000847470";
    
    UITabBarController *controller = (UITabBarController*)self.window.rootViewController;
    NSMutableArray *arr = [NSMutableArray array];
    
    MainViewController *mainVC = [[MainViewController alloc] init];
    mainVC.title = @"获取代理";
    [arr addObject:mainVC];
    
    DownloadViewController *downloadVC = [[DownloadViewController alloc] init];
    downloadVC.title = @"文件下载";
    [arr addObject:downloadVC];
    
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.title = @"WEBVIEW";
    [arr addObject:webVC];
    
    //[arr addObjectsFromArray:controller.viewControllers];
    [controller setViewControllers:arr];


    return YES;
}

//- (void)reachabilityChanged:(NSNotification *)note {
//    Reachability* curReach = [note object];
//    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
//    NetworkStatus status = [curReach currentReachabilityStatus];
//    NSLog(@"===========network did change:%ld",status);
//    if (status == NotReachable) {
//        [FGFlowgate networkDidChange:0];
//    } else if(status == ReachableViaWiFi) {
//        [FGFlowgate networkDidChange:1];
//    } else if (status == ReachableViaWWAN) {
//        [FGFlowgate networkDidChange:2];
//    }
//}

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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
