//
//  ParseCalendarAPIManager.h
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseCalendarAPIManager : NSObject
+ (id)sharedManager;
- (void)fetchCalendarDataWithCompletion:(PFUser *)user date:(NSDate *)date completion:(void(^)(NSArray *posts, NSError *error))completion;
- (void)fetchLatestPostForCacheWithCompletion:(PFUser *)user completion:(void(^)(Post *_Nullable post, BOOL success))completion;
@end

NS_ASSUME_NONNULL_END
