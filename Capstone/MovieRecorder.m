//
//  MovieRecorder.m
//  Capstone
//
//  Created by jacquelinejou on 7/19/22.
//

#import "MovieRecorder.h"

@implementation MovieRecorder {
    AVAssetWriter *_assetWriter;
    AVAssetWriterInput *_assetWriterAudioInput;
    AVAssetWriterInput *_assetWriterVideoInput;
    CGAffineTransform _videoTransform;
    NSDictionary *_videoSettings;
    NSDictionary *_audioSettings;
    NSURL *_outputFileURL;
}

- (id)initWith:(NSDictionary *)audioSettings videoSettings:(NSDictionary *)videoSettings videoTransform:(CGAffineTransform)videoTransform url:(NSURL *)url {
    _audioSettings = audioSettings;
    _videoSettings = videoSettings;
    _videoTransform = videoTransform;
    _outputFileURL = url;
    return self;
}

-(void)startRecording {
//    NSString *outputFileName = [[NSUUID UUID] UUIDString];
//    NSURL *outputFileURL = [[[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:outputFileName] URLByAppendingPathComponent:@"MOV"];
    NSError * error = NULL;
    AVAssetWriter *assetWriter = [AVAssetWriter assetWriterWithURL:_outputFileURL fileType:AVFileTypeQuickTimeMovie error:&error];
    if (!assetWriter) {
        return;
    }
    
    // add audio input
    AVAssetWriterInput *assetWriterAudioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:_audioSettings];
    [assetWriterAudioInput setExpectsMediaDataInRealTime:YES];
    [assetWriter addInput:assetWriterAudioInput];
    
    // add video input
    AVAssetWriterInput *assetWriterVideoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:_videoSettings];
    [assetWriterVideoInput setExpectsMediaDataInRealTime:YES];
    [assetWriterVideoInput setTransform:_videoTransform];
    [assetWriter addInput:assetWriterVideoInput];
    
    _assetWriter = assetWriter;
    _assetWriterAudioInput = assetWriterAudioInput;
    _assetWriterVideoInput = assetWriterVideoInput;
    _isRecording = YES;
}

- (void)stopRecording:(CompletionBlock) finishBlock {
    _isRecording = NO;
    _assetWriter = nil;
    [_assetWriter finishWritingWithCompletionHandler:^{
        finishBlock();
    }];
}

-(void)recordVideo:(CMSampleBufferRef)sampleBuffer {
    if (_assetWriter.status == AVAssetWriterStatusUnknown) {
        [_assetWriter startWriting];
        [_assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
    } else if (_assetWriter.status == AVAssetWriterStatusWriting) {
        AVAssetWriterInput *input = _assetWriterVideoInput;
        if (input.isReadyForMoreMediaData) {
            [input appendSampleBuffer:sampleBuffer];
        }
    }
}

-(void)recordAudio:(CMSampleBufferRef)sampleBuffer {
    if (_isRecording) {
        [_assetWriter startWriting];
        AVAssetWriterInput *input = _assetWriterAudioInput;
        if (!input.isReadyForMoreMediaData) {
            return;
        }
        [input appendSampleBuffer:sampleBuffer];
    }
}

@end
