//
//  CommentCell.h
//  Capstone
//
//  Created by jacquelinejou on 7/31/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : UITableViewCell
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@end

NS_ASSUME_NONNULL_END
