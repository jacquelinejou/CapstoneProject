//
//  ParseMapAPIManager.h
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseMapAPIManager : NSObject
+ (id)sharedManager;
- (void)fetchMapDataWithCompletion:(NSArray *)coordinates completion:(void(^)(NSArray *posts, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
