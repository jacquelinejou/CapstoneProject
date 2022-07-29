//
//  PostDetailsViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN
@class PostDetailsViewController;

@protocol PostDetailsViewControllerDelegate <NSObject>
- (void)addItemViewController:(PostDetailsViewController *)controller didSendPost:(Post *)post;
@end

@interface PostDetailsViewController : UIViewController
@property (nonatomic, strong) Post *postDetails;
@property (nonatomic, weak) id <PostDetailsViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
