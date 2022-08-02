//
//  CalendarCell.h
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import <FSCalendar/FSCalendar.h>
#import "Post.h"

typedef NS_ENUM(NSUInteger, SelectionType) {
    SelectionTypeNone,
    SelectionTypeSingle,
    SelectionTypeLeftBorder,
    SelectionTypeMiddle,
    SelectionTypeRightBorder
};

NS_ASSUME_NONNULL_BEGIN

@interface CalendarCell : FSCalendarCell
@property (weak, nonatomic) UIImageView *circleImageView;
@property (strong, nonatomic) UIImageView *postImageView;
@property (weak, nonatomic) CAShapeLayer *selectionLayer;
@property (assign, nonatomic) SelectionType selectionType;
@property (assign, nonatomic) PFFileObject *video;
-(CalendarCell *)setupCell:(UIImage *)image withVideo:(NSURL *)video;
@end

NS_ASSUME_NONNULL_END
