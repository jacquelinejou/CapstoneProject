//
//  PostDetailsViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "CommentsViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class PostDetailsViewController;

@protocol PostDetailsViewControllerDelegate <NSObject>
- (void)didSendBackPost:(Post *)post withIndex:(NSInteger)postIndex;
@end

@interface PostDetailsViewController : UIViewController <CommentsViewControllerDelegate>
@property (nonatomic, strong) Post *postDetails;
@property (nonatomic) NSInteger postIndex;
@property (nonatomic, weak) id <PostDetailsViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
