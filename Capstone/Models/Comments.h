//
//  Comments.h
//  Capstone
//
//  Created by jacquelinejou on 8/1/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Comments : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *username;

+ (void) postComment:(NSString *)comment withPostID:(NSString *)postID withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
