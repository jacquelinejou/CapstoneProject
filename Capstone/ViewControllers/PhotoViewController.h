//
//  PhotoViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureOutput.h>
#import "Reactions.h"

NS_ASSUME_NONNULL_BEGIN
@class PhotoViewController;

@protocol PhotoViewControllerDelegate <NSObject>
- (void)didSendPic:(Reactions *)pic;
@end

@interface PhotoViewController : UIViewController <AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate>
@property (nonatomic) BOOL isPicture;
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, weak) id <PhotoViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
