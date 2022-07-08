//
//  CustomInfoWindow.h
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CustomInfoWindow : UIView
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *reactionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@end

NS_ASSUME_NONNULL_END
