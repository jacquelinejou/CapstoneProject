//
//  ColorManager.h
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorManager : NSObject
+ (id)sharedManager;
- (UIColor *)lighterColorForColor:(UIColor *)c;
- (UIColor *)darkerColorForColor:(UIColor *)c;
@end

NS_ASSUME_NONNULL_END
