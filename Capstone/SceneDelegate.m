//
//  SceneDelegate.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "SceneDelegate.h"
#import "Parse/Parse.h"
#import "PhotoViewController.h"
#import "Post.h"
#import <UserNotifications/UserNotifications.h>
#import "ParseConnectionAPIManager.h"
#import "NotificationManager.h"

@import GoogleMaps;

@interface SceneDelegate () <UNUserNotificationCenterDelegate>
@end

bool _isGrantedNotificationAccess;
NSInteger _hourLowerBound = 6;
NSInteger _hourUpperBound = 24;
NSInteger _minuteLowerBound = 0;
NSInteger _minuteUpperBound = 60;

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    [[ParseConnectionAPIManager sharedManager] connectToParse];
    [self pushNotification];
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
    }
}

-(void)pushNotification {
    _isGrantedNotificationAccess = NO;
    // Register the notification categories.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    UNNotificationCategory* generalCategory = [UNNotificationCategory categoryWithIdentifier:@"GENERAL" actions:@[] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        _isGrantedNotificationAccess = granted;
    }];
    
    // setup notification content
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Take 5" arguments:nil];
    content.subtitle = [NSString localizedUserNotificationStringForKey:@"5...4...3...2...1" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Upload before time's up!" arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    // Configure the trigger for a random time between 6am - 12am.
    int hourRndValue = (int) (_hourLowerBound + arc4random_uniform(_hourUpperBound - _hourLowerBound));
    int minuteRndValue = (uint32_t) arc4random_uniform(_minuteUpperBound - _minuteLowerBound);
    
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.hour = hourRndValue;
    date.minute = minuteRndValue;
    
    [[NotificationManager sharedManager] setNotificationTime:hourRndValue minute:minuteRndValue];
    
    // Create the request object.
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:YES];
    // Create a request objects.
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"Post Time" content:content trigger:trigger];
    // add error handling
    [center addNotificationRequest:request withCompletionHandler:nil];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionSound+UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner;
    // Play a sound.
    completionHandler(presentationOptions);
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
        [self.window makeKeyAndVisible];
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        [[NotificationManager sharedManager] isTime:^(BOOL isTime) {
            if (isTime && [PFUser currentUser]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
                [self.window makeKeyAndVisible];
            }
        }];
    }
}

@end
