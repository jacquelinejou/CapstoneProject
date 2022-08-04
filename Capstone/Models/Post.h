//
//  Post.h
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface Post : PFObject<PFSubclassing>
@property (nonatomic, strong) NSString *postID;
@property (nonatomic, strong) NSString *UserID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) PFFileObject *Image;
@property (nonatomic, strong) PFFileObject *Video;
@property (nonatomic, strong) PFFileObject *Video2;
@property (nonatomic, strong) NSMutableArray *Reactions;
@property (nonatomic, strong) NSMutableArray *Comments;
@property (nonatomic, strong) PFGeoPoint *Location;
@property (nonatomic) BOOL isFrontCamInForeground;

+ (void) postUserVideo: (NSURL * _Nullable)frontURL backURL:(NSURL * _Nullable)backURL withOreintation:(BOOL)isFrontCamInForeground withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (UIImage *)imageFromVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (UIImage *)rotateImage:(UIImage *)image;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
