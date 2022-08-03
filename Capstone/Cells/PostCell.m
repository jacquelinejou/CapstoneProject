//
//  PostCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import "PostCell.h"

static CGFloat _borderSpace = 8.0;
static NSInteger _fontSize = 10;
static NSInteger _labelSize = 15;
static CGFloat _widthMultiplier = 0.5;
static CGFloat _heightMultiplier = 0.6;

@implementation PostCell

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    self.backgroundColor = [UIColor lightGrayColor];
    [self createProperties];
    [self setupFont];
    [self updateConstraints];
    return self;
}

-(void)createProperties {
    self.usernameLabel = [[UILabel alloc] init];
    self.commentLabel = [[UILabel alloc] init];
    self.reactionLabel = [[UILabel alloc] init];
    self.dateLabel = [[UILabel alloc] init];
    self.postImage = [[UIImageView alloc] init];
}

-(void)setupFont {
    self.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:_fontSize];
    self.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    self.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
    self.reactionLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
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
    [self.postImage.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor multiplier:_heightMultiplier].active = YES;
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
    [self.usernameLabel.heightAnchor constraintEqualToConstant:_labelSize].active = YES;
    [self.dateLabel.heightAnchor constraintEqualToAnchor:self.usernameLabel.heightAnchor].active = YES;
    [self.commentLabel.heightAnchor constraintEqualToAnchor:self.usernameLabel.heightAnchor].active = YES;
    [self.reactionLabel.heightAnchor constraintEqualToAnchor:self.usernameLabel.heightAnchor].active = YES;
}

@end
