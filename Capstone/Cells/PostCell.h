//
//  PostCell.h
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *commentLabel;
@property (nonatomic, strong) UILabel *reactionLabel;
@property (nonatomic, strong) UIImageView *postImage;
@property (nonatomic, strong) Post *post;

//-(void)setupCell:(Post *)post;
@end

NS_ASSUME_NONNULL_END
