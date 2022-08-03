//
//  ParsePostAPIManager.h
//  Capstone
//
//  Created by jacquelinejou on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParsePostAPIManager : NSObject

+ (id)sharedManager;
- (void)postVideoWithCompletion:(NSURL *)url completion:(void(^)(NSError *error))completion;
@end

NS_ASSUME_NONNULL_END
