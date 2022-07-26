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
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) PFUser *author;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) PFFileObject *image;
@property (nonatomic, strong) UIImage *imageData;
@property (nonatomic, strong) NSArray *reactions;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) PFGeoPoint *location;

+ (void) postUserVideo: ( NSURL * _Nullable )image withCaption: ( NSString * _Nullable )caption withCompletion: (PFBooleanResultBlock  _Nullable)completion;

@end

NS_ASSUME_NONNULL_END
