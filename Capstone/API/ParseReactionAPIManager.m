//
//  ParseReactionAPIManager.m
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import "ParseReactionAPIManager.h"
#import "Post.h"

@implementation ParseReactionAPIManager

+ (id)sharedManager {
    static ParseReactionAPIManager *sharedManager = nil;
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

- (void)postReactionWithCompletion:(UIImage *)reaction withPostID:(NSString *)postID completion:(void(^)(Reactions *reaction, NSError *error))completion {
    [Reactions postReaction:reaction withPostID:postID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateNumberReactionsWithCompletion:postID reaction:reaction];
        [self fetchLastReactionWithCompletion:postID completion:^(Reactions *reaction, NSError *error) {
            completion(reaction, error);
        }];
    }];
}

-(void)fetchReactionWithCompletion:(NSString *)postID completion:(void(^)(NSArray *_Nullable reactions, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Reactions"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postID" equalTo:postID];

    [query findObjectsInBackgroundWithBlock:^(NSArray *parseReactions, NSError *error) {
        completion(parseReactions, error);
    }];
}

-(void)fetchLastReactionWithCompletion:(NSString *)postID completion:(void(^)(Reactions *reaction, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Reactions"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postID" equalTo:postID];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseReactions, NSError *error) {
        if (parseReactions.count == 1) {
            completion([parseReactions firstObject], error);
        } else {
            completion(nil, error);
        }
    }];
}

-(void)updateNumberReactionsWithCompletion:(NSString *)postID reaction:(UIImage *)reaction {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query getObjectInBackgroundWithId:postID block:^(PFObject *post, NSError *error) {
        NSMutableArray *newReactions = (NSMutableArray *)post[@"Reactions"];
        PFFileObject *image = [Post getPFFileFromImage:reaction];
        [newReactions addObject:image];
        post[@"Reactions"] = newReactions;
        [post saveInBackground];
    }];
}
@end
