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
@property (nonatomic, strong) AVPlayerViewController *_postVideo;
@property (nonatomic) CGFloat _borderSpace;
@property (nonatomic) NSInteger _fontSize;
@property (nonatomic) NSInteger _labelSize;
@property (nonatomic) CGFloat _heightMultiplier;
@end

@implementation PostDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self._borderSpace = 50.0;
    self._fontSize = 18.0;
    self._labelSize = 30.0;
    self._heightMultiplier = 0.5;
    [self setupVariables];
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
    self._postVideo = [[AVPlayerViewController alloc] init];
    self._postVideo.player = playVideo;
    self._postVideo.player.volume = 0;
    [self.view addSubview:self._postVideo.view];
    [self videoConstraints];
    [playVideo play];
}

-(void)setupUsername {
    self._usernameLabel = [[UILabel alloc] init];
    self._usernameLabel.text = self.postDetails.UserID;
    self._usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:self._fontSize];
}

-(void)setupDate {
    self._dateLabel = [[UILabel alloc] init];
    self._dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:self._fontSize];
    NSDate *postTime = self.postDetails.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self._dateLabel.text = [formatter stringFromDate:postTime];
}

-(void)setupComment {
    self._commentLabel = [[UIButton alloc] init];
    self._commentLabel.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:self._fontSize];
    [self._commentLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self._commentLabel setTitle:[[NSString stringWithFormat:@"%lu", [self.postDetails.Comments count]] stringByAppendingString:@" Comments"] forState:UIControlStateNormal];
}

-(void)setupReactions {
    self._reactionLabel = [[UIButton alloc] init];
    [self._reactionLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self._reactionLabel.titleLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:self._fontSize];
    [self._reactionLabel setTitle:[[NSString stringWithFormat:@"%lu", [self.postDetails.Reactions count]] stringByAppendingString:@" Reactions"] forState:UIControlStateNormal];
    [self._reactionLabel sendActionsForControlEvents:UIControlEventTouchUpInside];
}

-(void)videoConstraints {
    [self._postVideo.view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self._postVideo.view.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self._postVideo.view.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:self._borderSpace * 2].active = YES;
    [self._postVideo.view.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self._postVideo.view.heightAnchor constraintEqualToAnchor:self.view.heightAnchor multiplier:self._heightMultiplier].active = YES;
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
    [self._commentLabel.topAnchor constraintEqualToAnchor:self._usernameLabel.bottomAnchor constant:self._borderSpace].active = YES;
    [self._commentLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:self._borderSpace].active = YES;
    [self._usernameLabel.leadingAnchor constraintEqualToAnchor:self._commentLabel.leadingAnchor].active = YES;
    [self._commentLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self._borderSpace * -2].active = YES;
    [self._reactionLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:self._borderSpace * -1].active = YES;
    [self._reactionLabel.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor constant:self._borderSpace * -2].active = YES;
    [self._dateLabel.trailingAnchor constraintEqualToAnchor:self._reactionLabel.trailingAnchor].active = YES;
    [self._dateLabel.bottomAnchor constraintEqualToAnchor:self._reactionLabel.topAnchor constant:self._borderSpace * -1].active = YES;
    [self._usernameLabel.heightAnchor constraintEqualToConstant:self._labelSize].active = YES;
    [self._dateLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor].active = YES;
    [self._commentLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor multiplier:2].active = YES;
    [self._reactionLabel.heightAnchor constraintEqualToAnchor:self._usernameLabel.heightAnchor multiplier:2].active = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.delegate addItemViewController:self didSendPost:self.postDetails];
}

@end
