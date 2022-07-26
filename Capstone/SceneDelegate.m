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
@import GoogleMaps;

@interface SceneDelegate () <UNUserNotificationCenterDelegate>

@end

bool isGrantedNotificationAccess;
NSInteger notificationHour;
NSInteger notificationMinute;

@implementation SceneDelegate {
    NSInteger timeLimit;
    NSInteger hourLowerBound;
    NSInteger hourUpperBound;
    NSInteger minuteLowerBound;
    NSInteger minuteUpperBound;
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    timeLimit = 5;
    hourLowerBound = 6;
    hourUpperBound = 24;
    minuteLowerBound = 0;
    minuteUpperBound = 60;
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
        NSString *ID = [dict objectForKey: @"App ID"];
        NSString *key = [dict objectForKey: @"Client Key"];
        NSString *kMapsAPIKey = [dict objectForKey: @"API Key"];
        configuration.applicationId = ID;
        configuration.clientKey = key;
        configuration.server = @"https://parseapi.back4app.com";
        
        [GMSServices provideAPIKey:kMapsAPIKey];
    }];
    [Parse initializeWithConfiguration:config];
    
    [self pushNotification];
    if (PFUser.currentUser) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
        self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    }
}

-(void)pushNotification {
    isGrantedNotificationAccess = NO;
    // Register the notification categories.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    UNNotificationCategory* generalCategory = [UNNotificationCategory categoryWithIdentifier:@"GENERAL" actions:@[] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
    [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
        isGrantedNotificationAccess = granted;
    }];
    
    // setup notification content
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Take 5" arguments:nil];
    content.subtitle = [NSString localizedUserNotificationStringForKey:@"5...4...3...2...1" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Upload before time's up!" arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    // Configure the trigger for a random time between 6am - 12am.
    int hourRndValue = (int) (hourLowerBound + arc4random_uniform(hourUpperBound - hourLowerBound));
    int minuteRndValue = (uint32_t) arc4random_uniform(minuteUpperBound - minuteLowerBound);
    
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.hour = hourRndValue;
    date.minute = minuteRndValue;
    
    if (minuteRndValue + timeLimit >= 60) {
        notificationHour = hourRndValue + 1;
        notificationMinute = minuteRndValue + timeLimit - 60;
    } else {
        notificationHour = hourRndValue;
        notificationMinute = minuteRndValue + timeLimit;
    }
    
    // Create the request object.
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:YES];
    // Create a request objects.
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"MorningAlarm" content:content trigger:trigger];
    // add error handling
    [center addNotificationRequest:request withCompletionHandler:nil];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    UNNotificationPresentationOptions presentationOptions = UNNotificationPresentationOptionSound+UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner;
    // Play a sound.
    completionHandler(presentationOptions);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    [self.window makeKeyAndVisible];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler {
    if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
        if ([self dateConverter]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
            [self.window makeKeyAndVisible];
        }
    }
}

-(BOOL)dateConverter {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    return (notificationHour > [components hour] || (notificationHour == [components hour] && notificationMinute > [components minute]));
}

@end
