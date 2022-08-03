//
//  ParseMapAPIManager.m
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import "ParseMapAPIManager.h"

@implementation ParseMapAPIManager

+ (id)sharedManager {
    static ParseMapAPIManager *sharedManager = nil;
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

- (void)fetchMapDataWithCompletion:(NSArray *)coordinates completion:(void(^)(NSArray *posts, NSError *error))completion {
    NSDate *today = [NSDate date];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&today interval:NULL forDate:today];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:today];
    [query whereKey:@"Location" withinPolygon:coordinates];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if (parsePosts != nil) {
            completion(parsePosts, error);
        }
    }];
}

@end
