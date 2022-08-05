//
//  PlayVideoViewController.m
//  Capstone
//
//  Created by jacquelinejou on 8/4/22.
//

#import "PlayVideoViewController.h"
#import "AVKit/AVKit.h"

@interface PlayVideoViewController ()
@end

static Float32 _aspectRatio = 16.0/9.0;
static Float32 _backFrontRatio = 0.25;
static Float32 _spacing = 20.0;
static Float32 _volume = 1.0;
static NSInteger _videoLength = 5;
static Float32 _aspectRatioConstant = 0.0;

@implementation PlayVideoViewController {
    UIView *_backgroundVideo;
    UIView *_foregroundVideo;
    AVPlayerLayer *_backCameraVideoPreviewLayer;
    AVPlayerLayer *_frontCameraVideoPreviewLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupVideo];
}

-(void)setupVideo {
    _backgroundVideo = [[UIView alloc] init];
    _foregroundVideo = [[UIView alloc] init];
    [self.view addSubview:_backgroundVideo];
    [self.view addSubview:_foregroundVideo];
    [self setupVideoConstraints];
    [self connectVideoToView];
}

-(void)connectVideoToView {
    if (!self.isFrontCamInForeground) {
        _backCameraVideoPreviewLayer = [self setupLayers:self.vid1 withView:_backgroundVideo];
        _frontCameraVideoPreviewLayer = [self setupLayers:self.vid2 withView:_foregroundVideo];
    } else {
        _backCameraVideoPreviewLayer = [self setupLayers:self.vid2 withView:_backgroundVideo];
        _frontCameraVideoPreviewLayer = [self setupLayers:self.vid1 withView:_foregroundVideo];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_frontCameraVideoPreviewLayer.frame = self->_foregroundVideo.bounds;
        self->_backCameraVideoPreviewLayer.frame = self->_backgroundVideo.bounds;
        self->_frontCameraVideoPreviewLayer.player.volume = _volume;
        self->_backCameraVideoPreviewLayer.player.muted = YES;
        [self->_backCameraVideoPreviewLayer.player play];
        [self->_frontCameraVideoPreviewLayer.player play];
    });
}

-(AVPlayerLayer *)setupLayers:(NSURL *)videoURL withView:(UIView *)view {
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    AVPlayer* playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:playVideo];
    [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [view.layer addSublayer:playerLayer];
    return playerLayer;
}

-(void)setupVideoConstraints {
    [_backgroundVideo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_foregroundVideo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setupAspectRatioConstraints];
    [self setupBackgroundConstraints];
    [self setupForegroundConstraints];
}

-(void)setupAspectRatioConstraints {
    NSLayoutConstraint *_frontCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_foregroundVideo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_foregroundVideo attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:_aspectRatioConstant];
    NSLayoutConstraint *_backCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_backgroundVideo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_backgroundVideo attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:_aspectRatioConstant];
    [self.view addConstraints:@[_frontCameraPiPConstraints, _backCameraPiPConstraints]];
}

-(void)setupForegroundConstraints {
    [_foregroundVideo.widthAnchor constraintEqualToAnchor:_backgroundVideo.widthAnchor multiplier:_backFrontRatio].active = YES;
    [_foregroundVideo.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
    [_foregroundVideo.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_foregroundVideo.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_foregroundVideo.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
}

-(void)setupBackgroundConstraints {
    [_backgroundVideo.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_backgroundVideo.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [_backgroundVideo.trailingAnchor constraintEqualToAnchor:_foregroundVideo.trailingAnchor constant:_spacing].active = YES;
    [_backgroundVideo.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_backgroundVideo.widthAnchor constraintLessThanOrEqualToAnchor:self.view.widthAnchor].active = YES;
    [_backgroundVideo.bottomAnchor constraintEqualToAnchor:_foregroundVideo.bottomAnchor constant:_spacing].active = YES;
    [_backgroundVideo.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
    [_backgroundVideo.heightAnchor constraintLessThanOrEqualToAnchor:self.view.heightAnchor].active = YES;
}


@end
