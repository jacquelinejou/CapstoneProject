//
//  CalendarCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import "CalendarCell.h"
#import <FSCalendar/FSCalendar.h>
#import "FSCalendarExtensions.h"
#import "ColorManager.h"

static CGFloat _topHeight = 0.2;
static CGFloat _bottomHeight = 0.6;
static NSInteger _frameSize = 1;
static NSInteger _indexValue = 0;

@implementation CalendarCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *circleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
        [self.contentView insertSubview:circleImageView atIndex:1];
        self.circleImageView = circleImageView;
        
        CAShapeLayer *selectionLayer = [[CAShapeLayer alloc] init];
        selectionLayer.fillColor = [UIColor blackColor].CGColor;
        selectionLayer.actions = @{@"hidden":[NSNull null]};
        [self.contentView.layer insertSublayer:selectionLayer below:self.titleLabel.layer];
        self.selectionLayer = selectionLayer;
        
        self.shapeLayer.hidden = NO;
        self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        self.backgroundView.backgroundColor = [[UIColor colorWithRed:[[ColorManager sharedManager] getCurrColor] green:[[ColorManager sharedManager] getCurrColor] blue:[[ColorManager sharedManager] getOtherColor] alpha:[[ColorManager sharedManager] getCurrColor]] colorWithAlphaComponent:[[ColorManager sharedManager] getAlphaComponent]];
        
        self.postImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView insertSubview:circleImageView atIndex:_indexValue];
    }
    return self;
}

-(CalendarCell *)setupCell:(UIImage *)image withVideo1:(PFFileObject *)video1 withVideo2:(PFFileObject *)video2 withBool:(BOOL)isFrontCamInForeground {
    // format image
    self.postImageView.image = image;
    [self.contentView insertSubview:self.postImageView atIndex:_indexValue];
    self.video1 = video1;
    self.video2 = video2;
    self.isFrontCamInForeground = isFrontCamInForeground;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = CGRectInset(self.bounds, _frameSize, _frameSize);
    self.circleImageView.frame = self.backgroundView.frame;
    self.postImageView.frame = CGRectMake(0, self.backgroundView.frame.size.height * _topHeight, self.backgroundView.frame.size.width, self.backgroundView.frame.size.height * _bottomHeight);
    self.selectionLayer.frame = self.bounds;
}

- (void)configureAppearance {
    [super configureAppearance];
    // Override the build-in appearance configuration
    if (self.isPlaceholder) {
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.eventIndicator.hidden = YES;
    }
}

- (void)setSelectionType:(SelectionType)selectionType {
    if (_selectionType != selectionType) {
        _selectionType = selectionType;
        [self setNeedsLayout];
    }
}

-(void)prepareForReuse {
    [super prepareForReuse];
    self.postImageView.image = [[UIImage alloc] init];
}
@end
