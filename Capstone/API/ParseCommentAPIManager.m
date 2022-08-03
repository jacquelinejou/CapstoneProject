//
//  ParseCommentAPIManager.m
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import "ParseCommentAPIManager.h"

@implementation ParseCommentAPIManager

+ (id)sharedManager {
    static ParseCommentAPIManager *sharedManager = nil;
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

- (void)postCommentWithCompletion:(NSString *)comment withPostID:(NSString *)postID completion:(void(^)(Comments *comment, NSError *error))completion {
    [Comments postComment:comment withPostID:postID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateNumberCommentsWithCompletion:postID comment:comment];
        [self fetchLastCommentWithCompletion:postID completion:^(Comments *comment, NSError *error) {
            completion(comment, error);
        }];
    }];
}

-(void)fetchCommentsWithCompletion:(NSString *)postID completion:(void(^)(NSArray *_Nullable comments, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postID" equalTo:postID];

    [query findObjectsInBackgroundWithBlock:^(NSArray *parseComments, NSError *error) {
        completion(parseComments, error);
    }];
}

-(void)fetchLastCommentWithCompletion:(NSString *)postID completion:(void(^)(Comments *comment, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postID" equalTo:postID];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseComments, NSError *error) {
        if (parseComments.count == 1) {
            completion([parseComments firstObject], error);
        } else {
            completion(nil, error);
        }
    }];
}

-(void)updateNumberCommentsWithCompletion:(NSString *)postID comment:(NSString *)comment {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query getObjectInBackgroundWithId:postID block:^(PFObject *post, NSError *error) {
        NSMutableArray *newComments = (NSMutableArray *)post[@"Comments"];
        [newComments addObject:comment];
        post[@"Comments"] = newComments;
        [post saveInBackground];
    }];
}
@end
