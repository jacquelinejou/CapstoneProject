//
//  NotificationManager.m
//  Capstone
//
//  Created by jacquelinejou on 7/29/22.
//

#import "NotificationManager.h"

@implementation NotificationManager

+ (id)sharedManager {
    static NotificationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(id)init {
    if (self = [super init]) {
        timeLimit = 5;
    }
    return self;
}

-(void)setNotificationTime:(int)hour minute:(int)minute {
    if (minute + timeLimit >= 60) {
        notificationHour = hour + 1;
        notificationMinute = minute + timeLimit - 60;
    } else {
        notificationHour = hour;
        notificationMinute = minute + timeLimit;
    }
}

-(void)isTime:(void (^)(BOOL isTime))completion {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    BOOL time = (notificationHour > [components hour] || (notificationHour == [components hour] && notificationMinute > [components minute]));
    completion(YES);
}

@end
