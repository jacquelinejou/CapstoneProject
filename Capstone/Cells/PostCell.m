//
//  PostCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
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
    [self updateConstraints];
}

-(void)setupCell:(Post *)post {
    self.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.25];
    self.usernameLabel = [[UILabel alloc] init];
    self.dateLabel = [[UILabel alloc] init];
    self.commentLabel = [[UILabel alloc] init];
    self.reactionLabel = [[UILabel alloc] init];
    self.postImage = [[UIImageView alloc] init];
    self.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:10];
    self.usernameLabel.text = post[@"UserID"];
    
    // format date
    self.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:10];
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
    
    self.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    self.commentLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Comments"] count]] stringByAppendingString:@" Comments"];
    self.reactionLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:10];
    self.reactionLabel.text = [[NSString stringWithFormat:@"%lu", [post[@"Reactions"] count]] stringByAppendingString:@" Reactions"];
}

-(void)updateConstraints {
    [super updateConstraints];
    [self imageConstraints];
    [self textConstraints];
}

-(void)imageConstraints {
    NSLayoutConstraint *imageXConstraint = [NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute: NSLayoutAttributeCenterX multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *imageHeightConstraint = [NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute: NSLayoutAttributeHeight multiplier:0.7 constant:0.0f];
    NSLayoutConstraint *imageWidthConstraint = [NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute: NSLayoutAttributeWidth multiplier:0.5 constant:0.0f];
    NSLayoutConstraint *imageTopConstraint = [NSLayoutConstraint constraintWithItem:self.postImage attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:2.0f];
    [self.contentView addConstraints:@[imageXConstraint, imageHeightConstraint, imageWidthConstraint, imageTopConstraint]];
}

-(void)textConstraints {
    NSLayoutConstraint *commentTopConstraint = [NSLayoutConstraint constraintWithItem:self.commentLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.usernameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0f];
    NSLayoutConstraint *commentLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.commentLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeading multiplier:1.0 constant:8.0f];
    NSLayoutConstraint *usernameLeadingConstraint = [NSLayoutConstraint constraintWithItem:self.usernameLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.commentLabel attribute:NSLayoutAttributeLeading multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *commentBottomConstraint = [NSLayoutConstraint constraintWithItem:self.commentLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8.0f];
    NSLayoutConstraint *reactionTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.reactionLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-8.0f];
    NSLayoutConstraint *reactionBottomConstraint = [NSLayoutConstraint constraintWithItem:self.reactionLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-8.0f];
    NSLayoutConstraint *dateTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.reactionLabel attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:0.0f];
    NSLayoutConstraint *dateBottomConstraint = [NSLayoutConstraint constraintWithItem:self.dateLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.reactionLabel attribute:NSLayoutAttributeTop multiplier:1.0 constant:-8.0f];
    [self.contentView addConstraints:@[commentTopConstraint, commentLeadingConstraint, usernameLeadingConstraint, commentBottomConstraint, reactionTrailingConstraint, reactionBottomConstraint, dateTrailingConstraint, dateBottomConstraint]];
}

@end
