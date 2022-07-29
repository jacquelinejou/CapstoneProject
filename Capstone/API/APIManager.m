//
//  APIManager.m
//  Capstone
//
//  Created by jacquelinejou on 7/27/22.
//

#import "APIManager.h"
#import "SceneDelegate.h"
#import "WelcomeViewController.h"

@implementation APIManager

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
        parseURL = @"https://parseapi.back4app.com";
    }
    return self;
}

- (void)connectToParse:(void (^)(NSError * _Nonnull))completion {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        NSString *path = [[NSBundle mainBundle] pathForResource: @"Keys" ofType: @"plist"];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];
        NSString *ID = [dict objectForKey: @"App ID"];
        NSString *key = [dict objectForKey: @"Client Key"];
        NSString *kMapsAPIKey = [dict objectForKey: @"API Key"];
        configuration.applicationId = ID;
        configuration.clientKey = key;
        configuration.server = self->parseURL;
        
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
    }];
}

- (void)fetchMapDataWithCompletion:(NSArray *)coordinates completion:(void(^)(NSArray *posts, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"Location" withinPolygon:coordinates];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if (parsePosts != nil) {
            completion(parsePosts, error);
        }
    }];
}

- (void)postVideoWithCompletion:(NSURL *)url completion:(void(^)(NSError *error))completion {
    [Post postUserVideo:url withCaption:@"" withCompletion:^(BOOL succeeded, NSError *_Nullable error) {
        completion(error);
    }];
}

@end
