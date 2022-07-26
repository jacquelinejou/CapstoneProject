//
//  VideoEncoder.m
//  Capstone
//
//  Created by jacquelinejou on 7/22/22.
//

#import "VideoEncoder.h"

@implementation VideoEncoder {
    AVAssetWriter *assetWriter;
    AVAssetWriterInput *videoInput;
    AVAssetWriterInput *audioInput;
    NSString *fileName;
    NSString *videoDirectoryPath;
    NSString *filePath;
    int width;
    int height;
}

-(id)initWithPath:(NSString *)path width:(int)vidWidth height:(int)vidHeight {
    self = [super init];
    fileName = path;
    NSString *dir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    videoDirectoryPath = [dir stringByAppendingString:@"/Videos"];
    filePath = [videoDirectoryPath stringByAppendingString:@"/"];
    filePath = [filePath stringByAppendingString:fileName];
    width = vidWidth;
    height = vidHeight;
    return self;
}

-(void)setupWriter:(CMSampleBufferRef)buffer {
    if([[NSFileManager defaultManager] fileExistsAtPath:videoDirectoryPath]) {
        NSError *err;
        [[NSFileManager defaultManager] removeItemAtPath:videoDirectoryPath error:&err];
        [[NSFileManager defaultManager] createDirectoryAtPath:videoDirectoryPath withIntermediateDirectories:YES attributes:nil error:&err];
        
    }
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSError *error;
    assetWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:&error];
    
    // add video input
    NSDictionary *compressionProperties = @{AVVideoProfileLevelKey         : AVVideoProfileLevelH264HighAutoLevel,
                                            AVVideoH264EntropyModeKey      : AVVideoH264EntropyModeCABAC,
                                            AVVideoAverageBitRateKey       : @(1920 * 1080 * 11.4),
                                            AVVideoMaxKeyFrameIntervalKey  : @60,
                                            AVVideoAllowFrameReorderingKey : @NO};
    NSDictionary *videoSettings = @{AVVideoCompressionPropertiesKey : compressionProperties,
                                    AVVideoCodecKey                 : AVVideoCodecTypeH264,
                                    AVVideoWidthKey                 : [NSNumber numberWithInt:width],
                                    AVVideoHeightKey                : [NSNumber numberWithInt:height]};
    videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    videoInput.expectsMediaDataInRealTime = YES;
    if ([assetWriter canAddInput:videoInput]) {
        [assetWriter addInput:videoInput];
    }
    
    // add audio input
    NSDictionary *audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithUnsignedInt:kAudioFormatLinearPCM], AVFormatIDKey, nil];
    audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    audioInput.expectsMediaDataInRealTime = YES;
    
    if ([assetWriter canAddInput:audioInput]) {
        [assetWriter addInput:audioInput];
    }
    if (assetWriter.status == AVAssetWriterStatusUnknown) {
        CMTime startTime = CMSampleBufferGetPresentationTimeStamp(buffer);
        [assetWriter startWriting];
        [assetWriter startSessionAtSourceTime:startTime];
    }
}

@end
