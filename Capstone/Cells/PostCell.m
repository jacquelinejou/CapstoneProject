//
//  PostCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import "PostCell.h"

@implementation PostCell
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
    [self updateConstraints];
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
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
    [self.contentView addSubview:self.postImage];
    [self.postImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.postImage.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:0.5].active = YES;
    [self.postImage.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:2.0].active = YES;
    [self.postImage.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.postImage.heightAnchor constraintEqualToConstant:0.7 * self.contentView.frame.size.height].active = YES;
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
    [self.commentLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:8.0].active = YES;
    [self.commentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8.0].active = YES;
    [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.commentLabel.leadingAnchor].active = YES;
    [self.commentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0].active = YES;
    [self.reactionLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8.0].active = YES;
    [self.reactionLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8.0].active = YES;
    [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.reactionLabel.trailingAnchor].active = YES;
    [self.dateLabel.bottomAnchor constraintEqualToAnchor:self.reactionLabel.topAnchor constant:-8.0].active = YES;
}

@end
