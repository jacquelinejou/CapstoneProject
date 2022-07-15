//
//  PhotoViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import "PhotoViewController.h"
#import "SceneDelegate.h"
#import "MapViewController.h"
#import "Photos/Photos.h"
#import "AVKit/AVKit.h"
#import "PreviewView.h"

@interface PhotoViewController ()
@end

typedef enum SessionSetupResult : NSUInteger {
    Success,
    notAuthorized,
    configurationFailed,
    multiCamNotSupported
} SessionSetupResult;

@implementation PhotoViewController {
    PreviewView *_background;
    PreviewView *_foreground;
    UIButton *_recordButton;
    BOOL isSessionRunning;
    AVCaptureMultiCamSession *session;
    dispatch_queue_t sessionQueue;
    dispatch_queue_t dataOutputQueue;
    
    AVCaptureDeviceInput *backCameraDeviceInput;
    AVCaptureVideoDataOutput *backCameraVideoDataOutput;
    AVCaptureVideoPreviewLayer *backCameraVideoPreviewLayer;
    
    AVCaptureDeviceInput *frontCameraDeviceInput;
    AVCaptureVideoDataOutput *frontCameraVideoDataOutput;
    AVCaptureVideoPreviewLayer *frontCameraVideoPreviewLayer;
    
    AVCaptureDeviceInput *microphoneDeviceInput;
    AVCaptureAudioDataOutput *backMicrophoneAudioDataOutput;
    AVCaptureAudioDataOutput *frontMicrophoneAudioDataOutput;
    
    AVCaptureDevicePosition pipDevicePosition;
    CGRect normalizedPipFrame;
    NSLayoutConstraint *frontCameraPiPConstraints;
    NSLayoutConstraint *backCameraPiPConstraints;
    SessionSetupResult setupResult;
    
    Float32 spacing;
    Float32 widthHeight;
    Float32 backFrontRatio;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    spacing = 20.0;
    widthHeight = 16.0/9.0;
    backFrontRatio = 0.25;
    _background = [[PreviewView alloc] init];
    _foreground = [[PreviewView alloc] init];
    _recordButton = [[UIButton alloc] init];
    session = [[AVCaptureMultiCamSession alloc] init];
    isSessionRunning = NO;
    pipDevicePosition = AVCaptureDevicePositionFront;
    normalizedPipFrame = CGRectZero;
    setupResult = Success;
    backCameraVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    frontCameraVideoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    backMicrophoneAudioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    frontMicrophoneAudioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkTime) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    [self updateViewConstraints];
    [_recordButton setEnabled:NO];
    [_background.videoPreviewLayer setSessionWithNoConnection:session];
    [_foreground.videoPreviewLayer setSessionWithNoConnection:session];
    backCameraVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    backCameraVideoPreviewLayer = _background.videoPreviewLayer;
    frontCameraVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] init];
    frontCameraVideoPreviewLayer = _foreground.videoPreviewLayer;
    [UIDevice.currentDevice beginGeneratingDeviceOrientationNotifications];
    sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    dataOutputQueue = dispatch_queue_create("data output queue", DISPATCH_QUEUE_SERIAL);
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self.view addSubview:_background];
    [self.view addSubview:_foreground];
    [self.view addSubview:_recordButton];
    frontCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_foreground attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_foreground attribute:NSLayoutAttributeWidth multiplier:widthHeight constant:0.0];
    backCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_background attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_background attribute:NSLayoutAttributeWidth multiplier:widthHeight constant:0.0];
    [self.view addConstraints:@[frontCameraPiPConstraints, backCameraPiPConstraints]];
    [_background setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_foreground setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_recordButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_background.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_background.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_background.trailingAnchor constraintEqualToAnchor:_foreground.trailingAnchor constant:spacing].active = YES;
    [_background.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_background.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_foreground.widthAnchor constraintEqualToAnchor:_background.widthAnchor multiplier:backFrontRatio].active = YES;
    [_background.bottomAnchor constraintEqualToAnchor:_foreground.bottomAnchor constant:spacing].active = YES;
    [_background.bottomAnchor constraintEqualToAnchor:_recordButton.bottomAnchor constant:spacing].active = YES;
    [_background.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_background.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
    [_foreground.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
    [_foreground.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_foreground.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_foreground.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_foreground.bottomAnchor constraintEqualToAnchor:_recordButton.bottomAnchor constant:spacing].active = YES;
    [_recordButton.widthAnchor constraintGreaterThanOrEqualToConstant:4 * spacing].active = YES;
    [_recordButton.heightAnchor constraintEqualToConstant:1.5 * spacing].active = YES;
    [_recordButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
}

-(void)checkTime{
    SceneDelegate *sd = [[SceneDelegate alloc] init];
    if (![sd dateConverter]) {
        [self performSegueWithIdentifier:@"postSegue" sender:nil];
    }
}
@end
