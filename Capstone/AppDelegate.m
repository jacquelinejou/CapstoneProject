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

bool isGrantedNotificationAccess;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
        
        NSString *ID = [dict objectForKey: @"App ID"];
        NSString *key = [dict objectForKey: @"Client Key"];
        NSString *kMapsAPIKey = [dict objectForKey: @"API Key"];
        configuration.applicationId = ID; // <- UPDATE
        configuration.clientKey = key; // <- UPDATE
        configuration.server = @"https://parseapi.back4app.com";
        
        [GMSServices provideAPIKey:kMapsAPIKey];
    }];
    
    [Parse initializeWithConfiguration:config];
    [self pushNotification];
    return YES;
}

-(void)pushNotification {
<<<<<<< Updated upstream
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Take 5" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Upload before time's up!" arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    UNNotificationCategory* generalCategory = [UNNotificationCategory categoryWithIdentifier:@"GENERAL" actions:@[] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
=======
    isGrantedNotificationAccess = NO;
>>>>>>> Stashed changes
    
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
    int hourLowerBound = 6;
    int hourUpperBound = 24;
    int hourRndValue = hourLowerBound + arc4random() % (hourUpperBound - hourLowerBound);
    
    int minuteLowerBound = 0;
    int minuteUpperBound = 59;
    int minuteRndValue = minuteLowerBound + arc4random() % (minuteUpperBound - minuteLowerBound);
    
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.hour = hourRndValue;
    date.minute = minuteRndValue;

    // Create the request object.
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:date repeats:YES];
    // Create a request objects. (to be changed to 100 requests)
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
    //NotificationPreviewViewConroller
    UIViewController *vc=[storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
    [self.window.rootViewController.navigationController pushViewController:vc animated: false];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
          didReceiveNotificationResponse:(UNNotificationResponse *)response
          withCompletionHandler:(void (^)(void))completionHandler {
   if ([response.actionIdentifier isEqualToString:UNNotificationDefaultActionIdentifier]) {
       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
       //NotificationPreviewViewConroller
       UIViewController *vc=[storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
       [self.window.rootViewController presentViewController:vc animated:true completion:nil];
//       self.window.rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"PhotoViewController"];
//       [self.window.rootViewController.navigationController pushViewController:vc animated: false];
   }
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
