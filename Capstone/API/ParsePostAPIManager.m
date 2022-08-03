//
//  ParsePostAPIManager.m
//  Capstone
//
//  Created by jacquelinejou on 7/27/22.
//

#import "ParsePostAPIManager.h"
#import "ParseCalendarAPIManager.h"
#import "CacheManager.h"
#import "Post.h"
#import "Parse/Parse.h"

@implementation ParsePostAPIManager

+ (id)sharedManager {
    static ParsePostAPIManager *sharedManager = nil;
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

- (void)postVideoWithCompletion:(NSURL *)url completion:(void(^)(NSError *error))completion {
    [Post postUserVideo:url withCaption:@"" withCompletion:^(BOOL succeeded, NSError *_Nullable error) {
        if ([[CacheManager sharedManager] hasCached]) {
            [[ParseCalendarAPIManager sharedManager] fetchLatestPostForCacheWithCompletion:[PFUser currentUser] completion:^(Post * _Nullable post, BOOL success) {
                if (post) {
                    [[CacheManager sharedManager] cachePost:post];
                }
            }];
        } else {
            [[CacheManager sharedManager] setCached];
            [[ParseCalendarAPIManager sharedManager] fetchCalendarDataWithCompletion:[PFUser currentUser] date:[NSDate date] completion:^(NSArray * _Nonnull posts, NSError * _Nonnull error) {
                            [[CacheManager sharedManager] cacheMonth:posts];
            }];
        }
        completion(error);
    }];
}

@end
