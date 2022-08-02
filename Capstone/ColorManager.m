//
//  ColorManager.m
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import "ColorManager.h"

@implementation ColorManager

+(id)sharedManager {
    static ColorManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(id)init {
    if (self = [super init]) {
    }
    return self;
}

- (UIColor *)lighterColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MIN(r + 0.45, 1.0) green:MIN(g + 0.45, 1.0) blue:MIN(b + 0.45, 1.0) alpha:a];
    }
    return nil;
}

- (UIColor *)darkerColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MAX(r - 0.05, 0.0) green:MAX(g - 0.05, 0.0) blue:MAX(b - 0.05, 0.0) alpha:a];
    }
    return nil;
}

@end
