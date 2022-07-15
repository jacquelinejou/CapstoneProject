//
//  AppDelegate.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import "PhotoViewController.h"
#import "Post.h"
#import <UserNotifications/UserNotifications.h>
@import GoogleMaps;

@interface AppDelegate () <UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
