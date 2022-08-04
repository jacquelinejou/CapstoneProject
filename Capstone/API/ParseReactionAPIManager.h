//
//  ParseReactionAPIManager.h
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Reactions.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseReactionAPIManager : NSObject
+ (id)sharedManager;
- (void)postReactionWithCompletion:(UIImage *)reaction withPostID:(NSString *)postID completion:(void(^)(Reactions *reaction, NSError *error))completion;
-(void)fetchReactionWithCompletion:(NSString *)postID completion:(void(^)(NSArray *_Nullable reactions, NSError *error))completion;
-(void)fetchLastReactionWithCompletion:(NSString *)postID completion:(void(^)(Reactions *reaction, NSError *error))completion;
-(void)updateNumberReactionsWithCompletion:(NSString *)postID reaction:(UIImage *)reaction;
@end

NS_ASSUME_NONNULL_END
