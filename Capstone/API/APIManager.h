//
//  APIManager.h
//  Capstone
//
//  Created by jacquelinejou on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Post.h"
#import "Comments.h"
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject

+ (id)sharedManager;
- (void)loginWithCompletion:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion;
- (void)registerWithCompletion:(PFUser *)newUser completion:(void(^)(NSError *error))completion;
- (void)logout;
- (void)connectToParse;
- (void)fetchMapDataWithCompletion:(NSArray *)coordinates completion:(void(^)(NSArray *posts, NSError *error))completion;
- (void)postVideoWithCompletion:(NSURL *)url completion:(void(^)(NSError *error))completion;
- (void)fetchCalendarDataWithCompletion:(PFUser *)user date:(NSDate *)date completion:(void(^)(NSArray *posts, NSError *error))completion;
- (void)fetchTodayCalendarDataWithCompletion:(PFUser *)user completion:(void(^)(Post *_Nullable post, BOOL success))completion;
- (void)postCommentWithCompletion:(NSString *)comment withPostID:(NSString *)postID completion:(void(^)(Comments *comment, NSError *error))completion;
-(void)fetchCommentsWithCompletion:(NSString *)postID completion:(void(^)(NSArray *comments, NSError *error))completion;
-(void)fetchLastCommentWithCompletion:(NSString *)postID completion:(void(^)(Comments *comment, NSError *error))completion;
-(void)updateNumberCommentsWithCompletion:(NSString *)postID comment:(NSString *)comment;
@end

NS_ASSUME_NONNULL_END
