//
//  ReactionCell.m
//  Capstone
//
//  Created by jacquelinejou on 8/1/22.
//

#import "ReactionCell.h"
#import "ColorManager.h"

static NSInteger _fontSize = 11;
static CGFloat _widthSpacingMultiplier = 0.1;
static CGFloat _spacing = 0.05;
static CGFloat _widthMultiplier = 0.25;

@implementation ReactionCell

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
    [self reactionConstraints];
    [self dateConstraints];
    [self createProperties];
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

-(void)reactionConstraints {
    [self.contentView addSubview:self.reactionImage];
    [self.reactionImage setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.reactionImage.widthAnchor constraintEqualToAnchor:self.contentView.widthAnchor multiplier:_widthMultiplier * 1.5].active = YES;
    [self.reactionImage.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor].active = YES;
    [self.reactionImage.heightAnchor constraintEqualToAnchor:self.contentView.heightAnchor multiplier:_widthMultiplier * 2.5].active = YES;
    [self.reactionImage.topAnchor constraintEqualToAnchor:self.usernameLabel.bottomAnchor constant:self.contentView.frame.size.height * _spacing].active = YES;
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
    self.reactionImage = [[UIImageView alloc] init];
    self.dateLabel = [[UILabel alloc] init];
    self.backgroundColor = [UIColor colorWithRed:[[ColorManager sharedManager] getCellColor] green:[[ColorManager sharedManager] getCurrColor] blue:[[ColorManager sharedManager] getCellColor] alpha:1.0];
}

-(void)setupFont {
    self.usernameLabel.font = [UIFont fontWithName:@"VirtuousSlabBold" size:_fontSize];
    self.dateLabel.font = [UIFont fontWithName:@"VirtuousSlabThin" size:_fontSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
