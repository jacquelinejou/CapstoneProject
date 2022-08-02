//
//  Reactions.h
//  Capstone
//
//  Created by jacquelinejou on 8/1/22.
//

#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Reactions : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) PFFileObject *reaction;
@property (nonatomic, strong) NSString *username;
+ (void) postReaction:( UIImage * _Nullable )image withPostID:(NSString *)postID withCompletion: (PFBooleanResultBlock  _Nullable)completion;
@end

NS_ASSUME_NONNULL_END
