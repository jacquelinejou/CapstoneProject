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

@interface PostDetailsViewController ()
@property (nonatomic, strong) UILabel *_usernameLabel;
@property (nonatomic, strong) UILabel *_dateLabel;
@property (nonatomic, strong) UIButton *_commentLabel;
@property (nonatomic, strong) UIButton *_reactionLabel;
@property (strong,nonatomic) CommentsViewController* commentsVC;
@property (strong,nonatomic) ReactionsViewController* reactionsVC;
@end

@implementation PostDetailsViewController {
    AVPlayerViewController *_postVideo;
    CGFloat _borderSpace;
    NSInteger _fontSize;
    NSInteger _labelSize;
    CGFloat _heightMultiplier;
    BOOL _moveForward;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.commentsVC = [[CommentsViewController alloc] init];
    self.commentsVC.delegate = self;
    self.reactionsVC = [[ReactionsViewController alloc] init];
    self.reactionsVC.delegate = self;
    _borderSpace = 50.0;
    _fontSize = 18.0;
    _labelSize = 30.0;
    _heightMultiplier = 0.5;
    [self setupVariables];
}

- (void)viewDidAppear:(BOOL)animated {
    _moveForward = NO;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self videoConstraints];
    [self textConstraints];
}

-(void)setupVariables {
    [self setupVideo];
    [self setupUsername];
    [self setupDate];
    [self setupComment];
    [self setupReactions];
}

-(void)setupVideo {
    PFFileObject *pffile = self.postDetails.Video;
    NSString *stringUrl = pffile.url;
    NSURL *url = [NSURL URLWithString: stringUrl];
    AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
    AVPlayer* playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    _postVideo = [[AVPlayerViewController alloc] init];
    _postVideo.player = playVideo;
    _postVideo.player.volume = 0;
    [self.view addSubview:_postVideo.view];
    [self videoConstraints];
    [playVideo play];
}

-(void)setupUsername {
    self._usernameLabel = [[UILabel alloc] init];
    self._usernameLabel.text = self.postDetails.UserID;
    self._usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
}

-(void)setupDate {
    self._dateLabel = [[UILabel alloc] init];
    self._dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    NSDate *postTime = self.postDetails.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self._dateLabel.text = [formatter stringFromDate:postTime];
}

-(void)setupComment {
    self._commentLabel = [[UIButton alloc] init];
    self._commentLabel.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
    [self._commentLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self._commentLabel setTitle:[[NSString stringWithFormat:@"%lu", [self.postDetails.Comments count]] stringByAppendingString:@" Comments"] forState:UIControlStateNormal];
    [self._commentLabel addTarget:self action:@selector(didTapComment) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setupReactions {
    self._reactionLabel = [[UIButton alloc] init];
    [self._reactionLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self._reactionLabel.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
    [self._reactionLabel setTitle:[[NSString stringWithFormat:@"%lu", [self.postDetails.Reactions count]] stringByAppendingString:@" Reactions"] forState:UIControlStateNormal];
    [self._reactionLabel sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self._reactionLabel addTarget:self action:@selector(didTapReaction) forControlEvents:UIControlEventTouchUpInside];
}

-(void)videoConstraints {
    [_postVideo.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_postVideo.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [_postVideo.view.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:_borderSpace * 2].active = YES;
    [_postVideo.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [_postVideo.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:_heightMultiplier].active = YES;
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
    [self._commentLabel.topAnchor constraintEqualToAnchor:self._usernameLabel.bottomAnchor constant:_borderSpace].active = YES;
    [self._commentLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:_borderSpace].active = YES;
    [self._usernameLabel.leadingAnchor constraintEqualToAnchor:self._commentLabel.leadingAnchor].active = YES;
    [self._commentLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:_borderSpace * -2].active = YES;
    [self._reactionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:_borderSpace * -1].active = YES;
    [self._reactionLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:_borderSpace * -2].active = YES;
    [self._dateLabel.trailingAnchor constraintEqualToAnchor:self._reactionLabel.trailingAnchor].active = YES;
    [self._dateLabel.bottomAnchor constraintEqualToAnchor:self._reactionLabel.topAnchor constant:_borderSpace * -1].active = YES;
    [self._usernameLabel.heightAnchor constraintEqualToConstant:_labelSize].active = YES;
    [self._dateLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor].active = YES;
    [self._commentLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor multiplier:2].active = YES;
    [self._reactionLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor multiplier:2].active = YES;
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
}

- (void)didSendPost:(nonnull Post *)post {
    self.postDetails = post;
    [self._commentLabel setTitle:[[NSString stringWithFormat:@"%lu", [post.Comments count]] stringByAppendingString:@" Comments"] forState:UIControlStateNormal];
}

- (void)didSendReactions:(Post *)post {
    self.postDetails = post;
    [self._reactionLabel setTitle:[[NSString stringWithFormat:@"%lu", [post.Reactions count]] stringByAppendingString:@" Reactions"] forState:UIControlStateNormal];
}

@end
