//
//  PostCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import "PostCell.h"

@implementation PostCell {
    CGFloat _borderSpace;
    NSInteger _fontSize;
    CGFloat _widthMultiplier;
    CGFloat _heightMultiplier;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.reactionLabel];
    [self.contentView addSubview:self.postImage];
    _borderSpace = 8.0;
    _fontSize = 10;
    _widthMultiplier = 0.5;
    _heightMultiplier = 0.7;
    [self updateConstraints];
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)setupCell:(Post *)post {
    self.backgroundColor = [UIColor lightGrayColor];
    self.post = post;
    [self setupUsername];
    [self setupComments];
    [self setupReactions];
    [self setupDate];
    [self setupImage];
}

-(void)setupUsername {
    self.usernameLabel = [[UILabel alloc] init];
    self.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:_fontSize];
    self.usernameLabel.text = self.post[@"UserID"];
}

-(void)setupComments {
    self.commentLabel = [[UILabel alloc] init];
    self.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
    self.commentLabel.text = [[NSString stringWithFormat:@"%lu", [self.post[@"Comments"] count]] stringByAppendingString:@" Comments"];
}

-(void)setupReactions {
    self.reactionLabel = [[UILabel alloc] init];
    self.reactionLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
    self.reactionLabel.text = [[NSString stringWithFormat:@"%lu", [self.post[@"Reactions"] count]] stringByAppendingString:@" Reactions"];
}

-(void)setupDate {
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    NSDate *postTime = self.post.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    // Configure the input format to parse the date string
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.dateLabel.text = [formatter stringFromDate:postTime];
}

-(void)setupImage {
    self.postImage = [[UIImageView alloc] init];
    PFFileObject *pffile = self.post[@"Image"];
    NSString *url = pffile.url;
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: url]];
    self.postImage.image = [UIImage imageWithData: imageData];
}

-(void)updateConstraints {
    [super updateConstraints];
    [self imageConstraints];
    [self textConstraints];
}

-(void)imageConstraints {
    [self.contentView addSubview:self.postImage];
    [self.postImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.postImage.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:_widthMultiplier].active = YES;
    [self.postImage.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:_borderSpace / 2].active = YES;
    [self.postImage.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.postImage.heightAnchor constraintEqualToConstant:_heightMultiplier * self.contentView.frame.size.height].active = YES;
}

-(void)textConstraints {
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.reactionLabel];
    [self.commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.usernameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.reactionLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.commentLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:_borderSpace].active = YES;
    [self.commentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:_borderSpace].active = YES;
    [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.commentLabel.leadingAnchor].active = YES;
    [self.commentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:_borderSpace * -1].active = YES;
    [self.reactionLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:_borderSpace * -1].active = YES;
    [self.reactionLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:_borderSpace * -1].active = YES;
    [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.reactionLabel.trailingAnchor].active = YES;
    [self.dateLabel.bottomAnchor constraintEqualToAnchor:self.reactionLabel.topAnchor constant:_borderSpace * -1].active = YES;
}

@end
