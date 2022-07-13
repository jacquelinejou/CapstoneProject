//
//  PostCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import "PostCell.h"

@implementation PostCell {
    CGFloat borderSpace;
    NSInteger fontSize;
    CGFloat widthMultiplier;
    CGFloat heightMultiplier;
}

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectZero];
    self.usernameLabel = [[UILabel alloc] init];
    self.dateLabel = [[UILabel alloc] init];
    self.commentLabel = [[UILabel alloc] init];
    self.reactionLabel = [[UILabel alloc] init];
    self.postImage = [[UIImageView alloc] init];
    [self.contentView addSubview:self.usernameLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.commentLabel];
    [self.contentView addSubview:self.reactionLabel];
    [self.contentView addSubview:self.postImage];
    borderSpace = 8.0;
    fontSize = 10;
    widthMultiplier = 0.5;
    heightMultiplier = 0.7;
    [self updateConstraints];
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)setupCell:(Post *)post {
    self.backgroundColor = [UIColor lightGrayColor];
    self.usernameLabel = [[UILabel alloc] init];
    self.dateLabel = [[UILabel alloc] init];
    self.commentLabel = [[UILabel alloc] init];
    self.reactionLabel = [[UILabel alloc] init];
    self.postImage = [[UIImageView alloc] init];
    self.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:fontSize];
    self.usernameLabel.text = post[@"UserID"];
    
    // format date
    self.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:fontSize];
    NSDate *postTime = post.createdAt;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"E MMM d HH:mm:ss Z y";
    // Configure the input format to parse the date string
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.dateLabel.text = [formatter stringFromDate:postTime];
    
    // format image
    [post[@"Image"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        self.postImage.image = [UIImage imageWithData:data];
    }];
    
    self.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:fontSize];
    self.commentLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Comments"] count]] stringByAppendingString:@" Comments"];
    self.reactionLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:fontSize];
    self.reactionLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Reactions"] count]] stringByAppendingString:@" Reactions"];
}

-(void)updateConstraints {
    [super updateConstraints];
    [self imageConstraints];
    [self textConstraints];
}

-(void)imageConstraints {
    [self.contentView addSubview:self.postImage];
    [self.postImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.postImage.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:widthMultiplier].active = YES;
    [self.postImage.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:borderSpace / 2].active = YES;
    [self.postImage.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.postImage.heightAnchor constraintEqualToConstant:heightMultiplier * self.contentView.frame.size.height].active = YES;
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
    [self.commentLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:borderSpace].active = YES;
    [self.commentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:borderSpace].active = YES;
    [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.commentLabel.leadingAnchor].active = YES;
    [self.commentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:borderSpace * -1].active = YES;
    [self.reactionLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:borderSpace * -1].active = YES;
    [self.reactionLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:borderSpace * -1].active = YES;
    [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.reactionLabel.trailingAnchor].active = YES;
    [self.dateLabel.bottomAnchor constraintEqualToAnchor:self.reactionLabel.topAnchor constant:borderSpace * -1].active = YES;
}

@end
