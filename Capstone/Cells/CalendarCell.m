//
//  CalendarCell.m
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import "CalendarCell.h"
#import <FSCalendar/FSCalendar.h>
#import "FSCalendarExtensions.h"

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
        self.backgroundView.backgroundColor = [[UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:1.0] colorWithAlphaComponent:0.025];
        
        self.postImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView insertSubview:circleImageView atIndex:0];
    }
    return self;
}

-(CalendarCell *)setupCell:(UIImage *)image {
    // format image
    self.postImageView.image = image;
    [self.contentView insertSubview:self.postImageView atIndex:0];
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundView.frame = CGRectInset(self.bounds, 1, 1);
    self.circleImageView.frame = self.backgroundView.frame;
    self.postImageView.frame = self.backgroundView.frame;
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
