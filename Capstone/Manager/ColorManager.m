//
//  ColorManager.m
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import "ColorManager.h"

static CGFloat _currColor = 1.0;
static CGFloat _otherColors = 0.0;
static CGFloat _cellColor = 0.91;
static CGFloat _lighterIncrement = 0.45;
static CGFloat _lighterMinValue = 1.0;
static CGFloat _darkerIncrement = 0.05;
static CGFloat _darkerMaxValue = 0.0;
static CGFloat _alphaComponent = 0.025;

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
    self = [super init];
    return self;
}

-(CGFloat)getCurrColor {
    return _currColor;
}

-(CGFloat)getOtherColor {
    return _otherColors;
}

-(CGFloat)getAlphaComponent {
    return _alphaComponent;
}

-(CGFloat)getCellColor {
    return _cellColor;
}

- (UIColor *)lighterColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MIN(r + _lighterIncrement, _lighterMinValue) green:MIN(g + _lighterIncrement, _lighterMinValue) blue:MIN(b + _lighterIncrement, _lighterMinValue) alpha:a];
    }
    return nil;
}

- (UIColor *)darkerColorForColor:(UIColor *)c {
    CGFloat r, g, b, a;
    if ([c getRed:&r green:&g blue:&b alpha:&a]) {
        return [UIColor colorWithRed:MAX(r - _darkerIncrement, _darkerMaxValue) green:MAX(g - _darkerIncrement, _darkerMaxValue) blue:MAX(b - _darkerIncrement, _darkerMaxValue) alpha:a];
    }
    return nil;
}

@end
