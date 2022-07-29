//
//  APIManager.h
//  Capstone
//
//  Created by jacquelinejou on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
#import "Post.h"
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject {
    NSString *parseURL;
}

+ (id)sharedManager;
- (void)loginWithCompletion:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion;
- (void)registerWithCompletion:(PFUser *)newUser completion:(void(^)(NSError *error))completion;
- (void)logout;
- (void)connectToParse:(void(^)(NSError *error))completion;
- (void)fetchMapDataWithCompletion:(NSArray *)coordinates completion:(void(^)(NSArray *posts, NSError *error))completion;
- (void)postVideoWithCompletion:(NSURL *)url completion:(void(^)(NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
