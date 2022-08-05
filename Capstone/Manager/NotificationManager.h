//
//  NotificationManager.h
//  Capstone
//
//  Created by jacquelinejou on 7/29/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotificationManager : NSObject {
    NSInteger notificationHour;
    NSInteger notificationMinute;
}

+ (id)sharedManager;
-(void)setNotificationTime:(int)hour minute:(int)minute;
-(void)isTime:(void (^)(BOOL isTime))completion;
@end

NS_ASSUME_NONNULL_END
