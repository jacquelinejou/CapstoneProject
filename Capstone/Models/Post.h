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
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) PFFileObject *Image;
@property (nonatomic, strong) PFFileObject *Video;
@property (nonatomic, strong) NSMutableArray *Reactions;
@property (nonatomic, strong) NSMutableArray *Comments;
@property (nonatomic, strong) PFGeoPoint *Location;

+ (void) postUserVideo: ( NSURL * _Nullable )image withCaption: ( NSString * _Nullable )caption withCompletion: (PFBooleanResultBlock  _Nullable)completion;
+ (UIImage *)imageFromVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;
+ (UIImage *)rotateImage:(UIImage *)image;
+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image;

@end

NS_ASSUME_NONNULL_END
