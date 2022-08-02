//
//  Comments.m
//  Capstone
//
//  Created by jacquelinejou on 8/1/22.
//

#import "Comments.h"

@implementation Comments

@dynamic postID;
@dynamic comment;
@dynamic user;
@dynamic username;

+ (nonnull NSString *)parseClassName {
    return @"Comments";
}

+ (void) postComment:(NSString *)comment withPostID:(NSString *)postID withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Comments *newComment = [Comments new];
    newComment.postID = postID;
    newComment.comment = comment;
    newComment.user = [PFUser currentUser];
    newComment.username =[PFUser currentUser].username;
    [newComment saveInBackgroundWithBlock: completion];
}

@end
