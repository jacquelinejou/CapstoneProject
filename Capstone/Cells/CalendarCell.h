//
//  CalendarCell.h
//  Capstone
//
//  Created by jacquelinejou on 7/12/22.
//

#import <FSCalendar/FSCalendar.h>

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
@property (weak, nonatomic) CAShapeLayer *selectionLayer;
@property (assign, nonatomic) SelectionType selectionType;
@end

NS_ASSUME_NONNULL_END
