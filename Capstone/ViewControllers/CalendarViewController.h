//
//  CalendarViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalendarViewController : UIViewController
@property (nonatomic, strong) NSMutableDictionary *dictOfPosts;
@property (nonatomic, strong) NSMutableDictionary *currMonthDictOfPosts;
@end

NS_ASSUME_NONNULL_END
