//
//  MovieRecorder.h
//  Capstone
//
//  Created by jacquelinejou on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@interface MovieRecorder : NSObject
typedef void (^CompletionBlock)(void);
@property (copy, nonatomic) CompletionBlock completeRecording;
@property (nonatomic) BOOL isRecording;
-(void)startRecording;
- (void)stopRecording:(CompletionBlock) finishBlock;
- (id)initWith:(NSDictionary *)audioSettings videoSettings:(NSDictionary *)videoSettings videoTransform:(CGAffineTransform)videoTransform url:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
