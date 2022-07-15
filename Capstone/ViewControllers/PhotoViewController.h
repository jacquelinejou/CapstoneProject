//
//  PhotoViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface PhotoViewController : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@end

NS_ASSUME_NONNULL_END
