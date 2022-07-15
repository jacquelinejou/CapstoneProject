//
//  PreviewView.h
//  Capstone
//
//  Created by jacquelinejou on 7/14/22.
//

#import <UIKit/UIKit.h>
#import "AVFoundation/AVFoundation.h"

NS_ASSUME_NONNULL_BEGIN

@interface PreviewView : UIView

-(AVCaptureVideoPreviewLayer *)videoPreviewLayer;
+ (Class)layerClass;
@end

NS_ASSUME_NONNULL_END
