//
//  PlayVideoViewController.h
//  Capstone
//
//  Created by jacquelinejou on 8/4/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayVideoViewController : UIViewController
@property (nonatomic) NSURL *vid1;
@property (nonatomic) NSURL *vid2;
@property (nonatomic) BOOL isFrontCamInForeground;
@end

NS_ASSUME_NONNULL_END
