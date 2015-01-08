//
//  AppDelegate.h
//  FlowGateApp1
//
//  Created by tianb on 4/30/14.
//  Copyright (c) 2014 21cn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FGAgent.h"

#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

@class Reachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


@property (strong, nonatomic) Reachability *reachability;

//@property (strong, nonatomic) FGProxyResult *currProxy;


@property (strong, nonatomic) FGProxyResult *currProxy;

@end
