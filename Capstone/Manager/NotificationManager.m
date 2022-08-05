//
//  NotificationManager.m
//  Capstone
//
//  Created by jacquelinejou on 7/29/22.
//

#import "NotificationManager.h"

static NSInteger _timeLimit = 5;
static NSInteger _minutesInHour = 60;

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
    self = [super init];
    return self;
}

-(void)setNotificationTime:(int)hour minute:(int)minute {
    if (minute + _timeLimit >= _minutesInHour) {
        notificationHour = hour + 1;
        notificationMinute = minute + _timeLimit - _minutesInHour;
    } else {
        notificationHour = hour;
        notificationMinute = minute + _timeLimit;
    }
}

-(void)isTime:(void (^)(BOOL isTime))completion {
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    BOOL time = (notificationHour > [components hour] || (notificationHour == [components hour] && notificationMinute > [components minute]));
    completion(time);
}

@end
