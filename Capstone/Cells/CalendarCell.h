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
@property (assign, nonatomic) PFFileObject *video1;
@property (assign, nonatomic) PFFileObject *video2;
@property (assign, nonatomic) BOOL isFrontCamInForeground;
-(CalendarCell *)setupCell:(UIImage *)image withVideo1:(PFFileObject *)video1 withVideo2:(PFFileObject *)video2 withBool:(BOOL)isFrontCamInForeground;
@end

NS_ASSUME_NONNULL_END
