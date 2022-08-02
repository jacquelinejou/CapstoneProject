//
//  CommentsViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/31/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN
@class CommentsViewController;

@protocol CommentsViewControllerDelegate <NSObject>
- (void)didSendPost:(Post *)post;
@end

@interface CommentsViewController : UIViewController
@property (nonatomic, strong) Post *postDetails;
@property (nonatomic, weak) id <CommentsViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
