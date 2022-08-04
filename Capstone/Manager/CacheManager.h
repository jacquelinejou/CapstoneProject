//
//  CacheManager.h
//  Capstone
//
//  Created by jacquelinejou on 7/29/22.
//

#import <Foundation/Foundation.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface CacheManager : NSObject
+ (id)sharedManager;
- (void)setCached;
- (BOOL)hasCached;
- (void)cachePost:(Post*)post;
- (void)cacheMonth:(NSArray *)posts;
- (Post *)getCachedPostForKey:(NSDate*)key;
- (void)didlogout;

@end

NS_ASSUME_NONNULL_END
