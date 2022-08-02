//
//  ReactionCell.h
//  Capstone
//
//  Created by jacquelinejou on 8/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReactionCell : UITableViewCell
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UIImageView *reactionImage;
@property (nonatomic, strong) UILabel *dateLabel;
@end

NS_ASSUME_NONNULL_END
