//
//  PostDetailsViewController.m
//  Capstone
//
//  Created by jacquelinejou on 7/28/22.
//

#import "PostDetailsViewController.h"
#import "MapViewController.h"
#import "Post.h"
#import "AVKit/AVKit.h"
#import "ColorManager.h"

@interface PostDetailsViewController ()
@property (nonatomic, strong) UILabel *_usernameLabel;
@property (nonatomic, strong) UILabel *_dateLabel;
@property (nonatomic, strong) UIButton *_commentLabel;
@property (nonatomic, strong) UIButton *_reactionLabel;
@property (strong,nonatomic) CommentsViewController* commentsVC;
@property (strong,nonatomic) ReactionsViewController* reactionsVC;
@end

static CGFloat _borderSpace = 50.0;
static NSInteger _fontSize = 18;
static NSInteger _labelSize = 30;
static Float32 _backFrontRatio = 0.25;
static Float32 _aspectRatio = 5.0/4.0;
static CGFloat _playerVolume = 1.0;
static CGFloat _bottomMultiplier = -2.0;
static CGFloat _heightMultiplier = 1.5;
static Float32 _aspectRatioConstant = 0.0;
static Float32 _foregroundMultplier = -0.05;
static Float32 _backgroundTopMultiplier = 0.1;
static NSInteger _startTime = 0;
static NSInteger _stopTime = 1;

@implementation PostDetailsViewController {
    UIView *_backgroundVideo;
    UIView *_foregroundVideo;
    BOOL _moveForward;
    AVPlayerLayer *_backCameraVideoPreviewLayer;
    AVPlayerLayer *_frontCameraVideoPreviewLayer;
    NSLayoutConstraint *_frontCameraPiPConstraints;
    NSLayoutConstraint *_backCameraPiPConstraints;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.commentsVC = [[CommentsViewController alloc] init];
    self.commentsVC.delegate = self;
    self.reactionsVC = [[ReactionsViewController alloc] init];
    self.reactionsVC.delegate = self;
    [self createVariables];
    [self setupVariables];
    [self assignVariables];
    [self setupColor];
}

- (void)viewDidAppear:(BOOL)animated {
    _moveForward = NO;
    [self assignVariables];
    [self.view setNeedsDisplay];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self videoConstraints];
    [self textConstraints];
}

-(void)createVariables {
    _backgroundVideo = [[UIView alloc] init];
    _foregroundVideo = [[UIView alloc] init];
    self._usernameLabel = [[UILabel alloc] init];
    self._dateLabel = [[UILabel alloc] init];
    self._commentLabel = [[UIButton alloc] init];
    self._reactionLabel = [[UIButton alloc] init];
}

-(void)setupVariables {
    self._usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    self._dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    self._commentLabel.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
    [self._commentLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self._commentLabel addTarget:self action:@selector(didTapComment) forControlEvents:UIControlEventTouchUpInside];
    [self._reactionLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self._reactionLabel.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
    [self._reactionLabel sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self._reactionLabel addTarget:self action:@selector(didTapReaction) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)assignVariables {
    [self setupVideo];
    [self setupUsername];
    [self setupDate];
    [self setupComment];
    [self setupReactions];
}

-(AVPlayerLayer *)setupLayers:(NSURL *)videoURL withView:(UIView *)view {
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:videoURL];
    AVPlayer* playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:playVideo];
    [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [playerLayer setFrame:view.bounds];
    [view.layer addSublayer:playerLayer];
    return playerLayer;
}

-(void)setupVideo {
    [self.view addSubview:_backgroundVideo];
    [self.view addSubview:_foregroundVideo];
    [self videoConstraints];
    if (self.postDetails.isFrontCamInForeground) {
        _backCameraVideoPreviewLayer = [self setupLayers:[NSURL URLWithString:self.postDetails.Video2.url] withView:_backgroundVideo];
        _frontCameraVideoPreviewLayer = [self setupLayers:[NSURL URLWithString:self.postDetails.Video.url] withView:_foregroundVideo];
    } else {
        _backCameraVideoPreviewLayer = [self setupLayers:[NSURL URLWithString:self.postDetails.Video.url] withView:_backgroundVideo];
        _frontCameraVideoPreviewLayer = [self setupLayers:[NSURL URLWithString:self.postDetails.Video2.url] withView:_foregroundVideo];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_frontCameraVideoPreviewLayer.player.volume = _playerVolume;
        self->_backCameraVideoPreviewLayer.player.muted = YES;
        [self->_backCameraVideoPreviewLayer.player play];
        [self->_frontCameraVideoPreviewLayer.player play];
    });
}

-(void)setupUsername {
    self._usernameLabel.text = self.postDetails.UserID;
}

-(void)setupDate {
    NSDate *postTime = self.postDetails.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.dateStyle = NSDateFormatterNoStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self._dateLabel.text = [formatter stringFromDate:postTime];
}

-(void)setupComment {
    [self._commentLabel setTitle:[[NSString stringWithFormat:@"%lu", [self.postDetails.Comments count]] stringByAppendingString:@" Comments"] forState:UIControlStateNormal];
}

-(void)setupReactions {
    [self._reactionLabel setTitle:[[NSString stringWithFormat:@"%lu", [self.postDetails.Reactions count]] stringByAppendingString:@" Reactions"] forState:UIControlStateNormal];
}

-(void)videoConstraints {
    [_backgroundVideo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_foregroundVideo setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self setupAspectRatioConstraints];
    [self setupBackgroundConstraints];
    [self setupForegroundConstraints];
}

-(void)textConstraints {
    [self.view addSubview:self._usernameLabel];
    [self.view addSubview:self._dateLabel];
    [self.view addSubview:self._commentLabel];
    [self.view addSubview:self._reactionLabel];
    [self._commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self._usernameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self._reactionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self._dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self usernameConstraints];
    [self commentConstraints];
    [self reactionConstraints];
    [self dateConstraints];
}

-(void)commentConstraints {
    [self._commentLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:_borderSpace].active = YES;
    [self._commentLabel.topAnchor constraintEqualToAnchor:self._usernameLabel.bottomAnchor constant:_borderSpace].active = YES;
    [self._commentLabel.leadingAnchor constraintEqualToAnchor:self._usernameLabel.leadingAnchor].active = YES;
    [self._commentLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:_borderSpace * _bottomMultiplier].active = YES;
    [self._commentLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor multiplier:_heightMultiplier].active = YES;
    self._commentLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
}

-(void)reactionConstraints {
    [self.view.trailingAnchor constraintEqualToAnchor:self._reactionLabel.trailingAnchor constant:_borderSpace].active = YES;
    [self._reactionLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:_borderSpace * _bottomMultiplier].active = YES;
    [self._dateLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor].active = YES;
    [self._reactionLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor multiplier:_heightMultiplier].active = YES;
    self._reactionLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
}

-(void)usernameConstraints {
    [self._usernameLabel.heightAnchor constraintEqualToConstant:_labelSize].active = YES;
}

-(void)dateConstraints {
    [self._dateLabel.trailingAnchor constraintEqualToAnchor:self._reactionLabel.trailingAnchor].active = YES;
    [self._reactionLabel.topAnchor constraintEqualToAnchor:self._dateLabel.bottomAnchor  constant:_borderSpace].active = YES;
}

-(void)setupAspectRatioConstraints {
    _frontCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_foregroundVideo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_foregroundVideo attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:_aspectRatioConstant];
    _backCameraPiPConstraints = [NSLayoutConstraint constraintWithItem:_backgroundVideo attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:_backgroundVideo attribute:NSLayoutAttributeWidth multiplier:_aspectRatio constant:_aspectRatioConstant];
    [self.view addConstraints:@[_frontCameraPiPConstraints, _backCameraPiPConstraints]];
}

-(void)setupForegroundConstraints {
    [_foregroundVideo.widthAnchor constraintEqualToAnchor:_backgroundVideo.widthAnchor multiplier:_backFrontRatio].active = YES;
    [_foregroundVideo.heightAnchor constraintEqualToAnchor:_backgroundVideo.heightAnchor multiplier:_backFrontRatio].active = YES;
    [_foregroundVideo.bottomAnchor constraintEqualToAnchor:_backgroundVideo.bottomAnchor constant:_backgroundVideo.bounds.size.height * _foregroundMultplier].active = YES;
    [_foregroundVideo.rightAnchor constraintEqualToAnchor:_backgroundVideo.rightAnchor constant:_backgroundVideo.bounds.size.width * _foregroundMultplier].active = YES;
}

-(void)setupBackgroundConstraints {
    [_backgroundVideo.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_backgroundVideo.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self.view.frame.size.height * _backgroundTopMultiplier].active = YES;
    [_backgroundVideo.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
}

-(void)didTapComment {
    self.commentsVC.postDetails = self.postDetails;
    _moveForward = YES;
    [[self navigationController] pushViewController:self.commentsVC animated:YES];
}

-(void)didTapReaction {
    self.reactionsVC.postDetails = self.postDetails;
    _moveForward = YES;
    [[self navigationController] pushViewController:self.reactionsVC animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    if (!_moveForward) {
        if ([self.delegate respondsToSelector:@selector(didSendBackPost:withIndex:)]) {
            [self.delegate didSendBackPost:self.postDetails withIndex:self.postIndex];
        }
    }
    [_backCameraVideoPreviewLayer.player seekToTime:CMTimeMake(_startTime, _stopTime)];
    [_backCameraVideoPreviewLayer.player pause];
    [_frontCameraVideoPreviewLayer.player seekToTime:CMTimeMake(_startTime, _stopTime)];
    [_frontCameraVideoPreviewLayer.player pause];
}

- (void)didSendPost:(nonnull Post *)post {
    self.postDetails = post;
    [self._commentLabel setTitle:[[NSString stringWithFormat:@"%lu", [post.Comments count]] stringByAppendingString:@" Comments"] forState:UIControlStateNormal];
}

- (void)didSendReactions:(Post *)post {
    self.postDetails = post;
    [self._reactionLabel setTitle:[[NSString stringWithFormat:@"%lu", [post.Reactions count]] stringByAppendingString:@" Reactions"] forState:UIControlStateNormal];
}

-(void)setupColor {
    self._commentLabel.backgroundColor = [[ColorManager sharedManager] lighterColorForColor:[[UIColor colorWithRed:[[ColorManager sharedManager] getCurrColor] green:[[ColorManager sharedManager] getOtherColor] blue:[[ColorManager sharedManager] getOtherColor] alpha:[[ColorManager sharedManager] getCurrColor]] colorWithAlphaComponent:[[ColorManager sharedManager] getCurrColor]]];
    self._reactionLabel.backgroundColor = self._commentLabel.backgroundColor;
    self.view.backgroundColor = [[ColorManager sharedManager] lighterColorForColor:self._commentLabel.backgroundColor];
}

@end
