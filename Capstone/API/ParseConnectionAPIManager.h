//
//  ParseConnectionAPIManager.h
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import <Foundation/Foundation.h>
#import "Parse/Parse.h"
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface ParseConnectionAPIManager : NSObject
+ (id)sharedManager;
- (void)loginWithCompletion:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion;
- (void)registerWithCompletion:(PFUser *)newUser completion:(void(^)(NSError *error))completion;
- (void)logout;
- (void)connectToParse;
@end

NS_ASSUME_NONNULL_END
