//
//  MapViewController.h
//  Capstone
//
//  Created by jacquelinejou on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "PostDetailsViewController.h"
@import GoogleMaps;
@import GoogleMapsUtils;

NS_ASSUME_NONNULL_BEGIN

@interface MapViewController : UIViewController <GMSMapViewDelegate, PostDetailsViewControllerDelegate>
@end

NS_ASSUME_NONNULL_END
