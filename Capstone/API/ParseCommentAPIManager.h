//
//  ParseCommentAPIManager.h
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import <Foundation/Foundation.h>
#import "Comments.h"
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseCommentAPIManager : NSObject
+ (id)sharedManager;
- (void)postCommentWithCompletion:(NSString *)comment withPostID:(NSString *)postID completion:(void(^)(Comments *comment, NSError *error))completion;
-(void)fetchCommentsWithCompletion:(NSString *)postID completion:(void(^)(NSArray *comments, NSError *error))completion;
-(void)fetchLastCommentWithCompletion:(NSString *)postID completion:(void(^)(Comments *comment, NSError *error))completion;
-(void)updateNumberCommentsWithCompletion:(NSString *)postID comment:(NSString *)comment;
@end

NS_ASSUME_NONNULL_END
