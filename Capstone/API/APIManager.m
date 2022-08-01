//
//  APIManager.m
//  Capstone
//
//  Created by jacquelinejou on 7/27/22.
//

#import "APIManager.h"
#import "SceneDelegate.h"
#import "WelcomeViewController.h"
#import "CacheManager.h"

@implementation APIManager {
    NSString *_parseURL;
}

+ (id)sharedManager {
    static APIManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(id)init {
    if (self = [super init]) {
        _parseURL = @"https://parseapi.back4app.com";
    }
    return self;
}

- (void)connectToParse {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
        NSString *ID = [dict objectForKey: @"App ID"];
        NSString *key = [dict objectForKey: @"Client Key"];
        NSString *kMapsAPIKey = [dict objectForKey: @"API Key"];
        configuration.applicationId = ID;
        configuration.clientKey = key;
        configuration.server = self->_parseURL;
        
        [GMSServices provideAPIKey:kMapsAPIKey];
    }];
    [Parse initializeWithConfiguration:config];
}

- (void)loginWithCompletion:(NSString *)username password:(NSString *)password completion:(void(^)(NSError *error))completion {
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        completion(error);
    }];
}

- (void)registerWithCompletion:(PFUser *)newUser completion:(void(^)(NSError *error))completion {
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        completion(error);
    }];
}

- (void)logout {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeView"];
        mySceneDelegate.window.rootViewController = welcomeViewController;
        [[CacheManager sharedManager] didlogout];
    }];
}

- (void)fetchMapDataWithCompletion:(NSArray *)coordinates completion:(void(^)(NSArray *posts, NSError *error))completion {
    NSDate *today = [NSDate date];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&today interval:NULL forDate:today];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:today];
    [query whereKey:@"Location" withinPolygon:coordinates];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if (parsePosts != nil) {
            completion(parsePosts, error);
        }
    }];
}

- (void)fetchCalendarDataWithCompletion:(PFUser *)user date:(NSDate *)date completion:(void(^)(NSArray *posts, NSError *error))completion {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comps = [calendar components:unitFlags fromDate:date];
    [comps setMonth:[comps month]+1];
    [comps setDay:0];
    NSDate *lastDateMonth = [calendar dateFromComponents:comps];
    lastDateMonth = [lastDateMonth dateByAddingTimeInterval:(60*60*24)];
    [comps setMonth:[comps month]-1];
    [comps setDay:1];
    NSDate *firstDateMonth = [calendar dateFromComponents:comps];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&firstDateMonth interval:NULL forDate:firstDateMonth];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"UserID" equalTo:user.username];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:firstDateMonth];
    [query whereKey:@"createdAt" lessThan:lastDateMonth];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if (parsePosts != nil) {
            completion(parsePosts, error);
        }
    }];
}

// called after user posts to fetch new post into cache
- (void)fetchTodayCalendarDataWithCompletion:(PFUser *)user completion:(void(^)(Post *_Nullable post, BOOL success))completion {
    NSDate *today = [NSDate date];
    [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay startDate:&today interval:NULL forDate:today];
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"UserID" equalTo:user.username];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:today];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if ([parsePosts count] == 1) {
            completion([parsePosts firstObject], YES);
        } else {
            completion(nil, NO);
        }
    }];
}

- (void)postVideoWithCompletion:(NSURL *)url completion:(void(^)(NSError *error))completion {
    [Post postUserVideo:url withCaption:@"" withCompletion:^(BOOL succeeded, NSError *_Nullable error) {
        if ([[CacheManager sharedManager] hasCached]) {
            [self fetchTodayCalendarDataWithCompletion:[PFUser currentUser] completion:^(Post * _Nullable post, BOOL success) {
                if (post) {
                    [[CacheManager sharedManager] cachePost:post];
                }
            }];
        } else {
            [[CacheManager sharedManager] setCached];
            [self fetchCalendarDataWithCompletion:[PFUser currentUser] date:[NSDate date] completion:^(NSArray * _Nonnull posts, NSError * _Nonnull error) {
                            [[CacheManager sharedManager] cacheMonth:posts];
            }];
        }
        completion(error);
    }];
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
