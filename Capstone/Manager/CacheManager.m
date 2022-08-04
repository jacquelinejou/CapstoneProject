//
//  CacheManager.m
//  Capstone
//
//  Created by jacquelinejou on 7/29/22.
//

#import "CacheManager.h"

@implementation CacheManager {
    NSCache *_imageCache;
    BOOL _hasCached;
}

+(id)sharedManager {
    static CacheManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(id)init {
    if (self = [super init]) {
        _imageCache = [[NSCache alloc] init];
        [_imageCache setCountLimit:31];
        _hasCached = NO;
    }
    return self;
}

-(void)setCached {
    _hasCached = YES;
}

-(BOOL)hasCached {
    return _hasCached;
}

-(void)cachePost:(Post*)post {
    NSDate *startOfDay = post.createdAt;
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&startOfDay interval:NULL forDate:startOfDay];
    [_imageCache setObject:post forKey:startOfDay];
}

-(void)cacheMonth:(NSArray *)posts {
    for (Post *post in posts) {
        [self cachePost:post];
    }
    _hasCached = YES;
}

-(Post *)getCachedPostForKey:(NSDate*)key {
    return [self->_imageCache objectForKey:key];
}

-(void)didlogout {
    _hasCached = NO;
    [_imageCache removeAllObjects];
}

@end
