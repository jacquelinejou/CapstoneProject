//
//  PreviewView.m
//  Capstone
//
//  Created by jacquelinejou on 7/14/22.
//

#import "PreviewView.h"

@implementation PreviewView

-(AVCaptureVideoPreviewLayer *)videoPreviewLayer {
    AVCaptureVideoPreviewLayer *layer = [[AVCaptureVideoPreviewLayer alloc] init];
    [layer setVideoGravity:kCAGravityResizeAspect];
    return layer;
}

+ (Class)layerClass {
    return AVCaptureVideoPreviewLayer.self;
}

@end
