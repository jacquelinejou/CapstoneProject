//
//  Reactions.m
//  Capstone
//
//  Created by jacquelinejou on 8/1/22.
//

#import "Reactions.h"

@implementation Reactions

@dynamic postID;
@dynamic reaction;
@dynamic username;

+ (nonnull NSString *)parseClassName {
    return @"Reactions";
}

+ (void) postReaction:( UIImage * _Nullable )image withPostID:(NSString *)postID withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Reactions *newReaction = [Reactions new];
    newReaction.postID = postID;
    newReaction.reaction = [self getPFFileFromImage:image];
    newReaction.username = [PFUser currentUser].username;
    [newReaction saveInBackgroundWithBlock: completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
    if (!image) {
        return nil;
    }
    NSData *imageData = UIImagePNGRepresentation(image);
    if (!imageData) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

@end
