//
//  ParseCalendarAPIManager.m
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import "ParseCalendarAPIManager.h"

@implementation ParseCalendarAPIManager

+ (id)sharedManager {
    static ParseCalendarAPIManager *sharedManager = nil;
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

- (void)fetchCalendarDataWithCompletion:(PFUser *)user date:(NSDate *)date completion:(void(^)(NSArray *posts, NSError *error))completion {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:date];
    [comps setMonth:[comps month]+1];
    [comps setDay:0];
    NSDate *lastDateMonth = [calendar dateFromComponents:comps];
    lastDateMonth = [lastDateMonth dateByAddingTimeInterval:(60*60*24)];
    [comps setMonth:[comps month]-1];
    [comps setDay:1];
    NSDate *firstDateMonth = [calendar dateFromComponents:comps];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&firstDateMonth interval:NULL forDate:firstDateMonth];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"UserID" equalTo:user.username];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:firstDateMonth];
    [query whereKey:@"createdAt" lessThan:lastDateMonth];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if (parsePosts != nil) {
            completion(parsePosts, error);
        }
    }];
}

// called after user posts to fetch new post into cache
- (void)fetchLatestPostForCacheWithCompletion:(PFUser *)user completion:(void(^)(Post *_Nullable post, BOOL success))completion {
    NSDate *today = [NSDate date];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&today interval:NULL forDate:today];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"UserID" equalTo:user.username];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:today];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if ([parsePosts count] == 1) {
            completion([parsePosts firstObject], YES);
        } else {
            completion(nil, NO);
        }
    }];
}
@end
