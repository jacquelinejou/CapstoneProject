//
//  PhotoViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureOutput.h>

NS_ASSUME_NONNULL_BEGIN
@interface PhotoViewController : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate>
@end

NS_ASSUME_NONNULL_END
