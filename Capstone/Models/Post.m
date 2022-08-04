//
//  Post.m
//  Capstone
//
//  Created by jacquelinejou on 7/7/22.
//

#import "Post.h"
#import <AVFoundation/AVFoundation.h>

@implementation Post

@dynamic postID;
@dynamic UserID;
@dynamic author;
@dynamic date;
@dynamic Image;
@dynamic Video;
@dynamic Video2;
@dynamic Reactions;
@dynamic Comments;
@dynamic Location;
@dynamic isFrontCamInForeground;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (void) postUserVideo: (NSURL * _Nullable)frontURL backURL:(NSURL * _Nullable)backURL withOreintation:(BOOL)isFrontCamInForeground withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    Post *newPost = [Post new];
    UIImage *image = [self imageFromVideo:backURL atTime:0];
    newPost.Image = [self getPFFileFromImage:image];
    newPost.Video = [self getPFFileFromUrl:frontURL];
    newPost.Video2 = [self getPFFileFromUrl:backURL];
    newPost.author = [PFUser currentUser];
    newPost.Reactions = [[NSMutableArray alloc] init];
    newPost.Comments = [[NSMutableArray alloc] init];
    newPost.UserID = [PFUser currentUser].username;
    newPost.isFrontCamInForeground = isFrontCamInForeground;
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            newPost[@"Location"] = geoPoint;
            [newPost saveInBackgroundWithBlock: completion];
        }
    }];
}

+ (PFFileObject *)getPFFileFromUrl: (NSURL * _Nullable)url {
    if (!url) {
        return nil;
    }
    NSString *sendStr = [[url absoluteString] stringByReplacingOccurrencesOfString:@"file:///private" withString:@""];
    NSData *data = [NSData dataWithContentsOfFile:sendStr];
    // get image data and check if that is not nil
    if (!data) {
        return nil;
    }
    return [PFFileObject fileObjectWithName:@"video.mov" data:data];
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

+ (UIImage *)imageFromVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVAsset* asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
    UIImage* image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
    UIImage* flippedImage = [UIImage imageWithCGImage:image.CGImage
                                                scale:image.scale
                                          orientation:UIImageOrientationUpMirrored];
    return [self rotateImage:flippedImage];
}

+ (UIImage *)rotateImage:(UIImage *)image {
  BOOL sameOrientationType = YES;
  CGFloat radians = M_PI / 2.0;
  CGSize newSize = sameOrientationType ? image.size : CGSizeMake(image.size.height, image.size.width);

  UIGraphicsBeginImageContext(newSize);
  CGContextRef ctx = UIGraphicsGetCurrentContext();
  CGImageRef cgImage = image.CGImage;
  if (ctx == NULL || cgImage == NULL) {
    UIGraphicsEndImageContext();
    return nil;
  }

  CGContextTranslateCTM(ctx, newSize.width / 2.0, newSize.height / 2.0);
  CGContextRotateCTM(ctx, radians);
  CGContextScaleCTM(ctx, 1, -1);
  CGPoint origin = CGPointMake(-(image.size.width / 2.0), -(image.size.height / 2.0));
  CGRect rect = CGRectZero;
  rect.origin = origin;
  rect.size = image.size;
  CGContextDrawImage(ctx, rect, cgImage);
  UIImage *rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  return rotatedImage;
}

@end
