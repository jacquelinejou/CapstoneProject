//
//  APIManager.h
//  Capstone
//
//  Created by jacquelinejou on 7/27/22.
//

#import <Foundation/Foundation.h>
@import GoogleMaps;

NS_ASSUME_NONNULL_BEGIN

@interface APIManager : NSObject {
    NSString *parseURL;
}

+ (id)sharedManager;
- (void)connectToParse:(void(^)(NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
