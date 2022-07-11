//
//  AppDelegate.m
//  Capstone
//
//  Created by jacquelinejou on 7/5/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"
#import <UserNotifications/UserNotifications.h>
@import GoogleMaps;

@interface AppDelegate ()

@end

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
    //    PFObject *post = [PFObject objectWithClassName:@"Post"];
    //    post[@"UserID"] = @"testUser1";
    //    post[@"Location"] = [PFGeoPoint geoPointWithLatitude:40.0 longitude:-30.0];
    //    post[@"Comments"] = [[NSArray alloc] init];
    //    post[@"Reactions"] = [[NSArray alloc] init];
    //    NSData *imageData = UIImagePNGRepresentation([UIImage imageNamed:@"custom_pin.png"]);
    //    post[@"Image"] = [PFFileObject fileObjectWithName:@"image.png" data:imageData];;
    //    [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //        if (succeeded) {
    //            NSLog(@"Object saved!");
    //        } else {
    //            NSLog(@"Error: %@", error.description);
    //        }
    //    }];
    return YES;
}

-(void)pushNotification {
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"Take 5" arguments:nil];
    content.body = [NSString localizedUserNotificationStringForKey:@"Upload before time's up!" arguments:nil];
    content.sound = [UNNotificationSound defaultSound];
    
    UNNotificationCategory* generalCategory = [UNNotificationCategory categoryWithIdentifier:@"GENERAL" actions:@[] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
//    // Create the custom actions for expired timer notifications.
//    UNNotificationAction* snoozeAction = [UNNotificationAction actionWithIdentifier:@"SNOOZE_ACTION" title:@"Snooze" options:UNNotificationActionOptionNone];
//
//    UNNotificationAction* stopAction = [UNNotificationAction actionWithIdentifier:@"STOP_ACTION" title:@"Stop" options:UNNotificationActionOptionForeground];
//
//    // Create the category with the custom actions.
//    UNNotificationCategory* expiredCategory = [UNNotificationCategory categoryWithIdentifier:@"TIMER_EXPIRED" actions:@[snoozeAction, stopAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
    
    // Register the notification categories.
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    [center setNotificationCategories:[NSSet setWithObjects:generalCategory, nil]];
    
    // Configure the trigger for a random time between 6am - 12am.
    int hourLowerBound = 6;
    int hourUpperBound = 24;
    int hourRndValue = hourLowerBound + arc4random() % (hourUpperBound - hourLowerBound);
    
    int minuteLowerBound = 0;
    int minuteUpperBound = 59;
    int minuteRndValue = minuteLowerBound + arc4random() % (minuteUpperBound - minuteLowerBound);
    
    NSDateComponents* date = [[NSDateComponents alloc] init];
    date.hour = 13;
    date.minute = 57;
    UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger
                                              triggerWithDateMatchingComponents:date repeats:YES];
    
    // Create the request object.
    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"MorningAlarm" content:content trigger:trigger];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
        willPresentNotification:(UNNotification *)notification
        withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    
    // Play a sound.
   completionHandler(UNNotificationPresentationOptionSound);
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}

@end
