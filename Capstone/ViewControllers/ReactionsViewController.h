//
//  ReactionsViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/31/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "PhotoViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class ReactionsViewController;

@protocol ReactionsViewControllerDelegate <NSObject>
- (void)didSendReactions:(Post *)post;
@end

@interface ReactionsViewController : UIViewController <PhotoViewControllerDelegate>
@property (nonatomic, strong) Post *postDetails;
@property (nonatomic, weak) id <ReactionsViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
