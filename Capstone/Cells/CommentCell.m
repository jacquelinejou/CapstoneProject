//
//  CommentCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/31/22.
//

#import "CommentCell.h"
#import "ColorManager.h"

static NSInteger _fontSize = 11;
static CGFloat _widthSpacingMultiplier = 0.1;
static CGFloat _spacing = 0.05;
static CGFloat _widthMultiplier = 0.25;

@implementation CommentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createProperties];
    }
    return self;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

-(void)updateConstraints {
    [super updateConstraints];
    [self usernameConstraints];
    [self commentConstraints];
    [self dateConstraints];
    [self createProperties];
    [self setupCommentLines];
    [self setupFont];
}

-(void)usernameConstraints {
    [self.contentView addSubview:self.usernameLabel];
    [self.usernameLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.usernameLabel.widthAnchor constraintGreaterThanOrEqualToAnchor:self.contentView.widthAnchor multiplier:_widthMultiplier].active = YES;
    [self.usernameLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:self.contentView.frame.size.width * _widthSpacingMultiplier].active = YES;
    [self.usernameLabel.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor multiplier:0.2].active = YES;
    [self.usernameLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:self.contentView.frame.size.height * _spacing].active = YES;
}

-(void)commentConstraints {
    [self.contentView addSubview:self.commentLabel];
    [self.commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.commentLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:_widthMultiplier * 3].active = YES;
    [self.commentLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:self.contentView.frame.size.width * _widthSpacingMultiplier].active = YES;
    [self.commentLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor].active = YES;
    [self.commentLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:self.contentView.frame.size.height * _spacing].active = YES;
}

-(void)dateConstraints {
    [self.contentView addSubview:self.dateLabel];
    [self.dateLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.dateLabel.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:_widthMultiplier].active = YES;
    [self.dateLabel.heightAnchor constraintEqualToAnchor:self.usernameLabel.heightAnchor].active = YES;
    [self.dateLabel.topAnchor constraintEqualToAnchor:self.usernameLabel.topAnchor].active = YES;
    [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:self.contentView.frame.size.width * _widthSpacingMultiplier].active = YES;
}

-(void)createProperties {
    self.usernameLabel = [[UILabel alloc] init];
    self.commentLabel = [[UILabel alloc] init];
    self.dateLabel = [[UILabel alloc] init];
    self.backgroundColor = [UIColor colorWithRed:[[ColorManager sharedManager] getCellColor] green:[[ColorManager sharedManager] getCellColor] blue:[[ColorManager sharedManager] getCurrColor] alpha:1.0];
}

-(void)setupCommentLines {
    self.commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.commentLabel.numberOfLines = 0;
}

-(void)setupFont {
    self.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:_fontSize];
    self.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
    self.commentLabel.font = [UIFont fontWithName:@"VirtuousSlabRegular" size:_fontSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
