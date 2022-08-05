//
//  ParseConnectionAPIManager.m
//  Capstone
//
//  Created by jacquelinejou on 8/2/22.
//

#import "ParseConnectionAPIManager.h"
#import "SceneDelegate.h"
#import "WelcomeViewController.h"
#import "CacheManager.h"

@implementation ParseConnectionAPIManager {
    NSString *_parseURL;
}

+ (id)sharedManager {
    static ParseConnectionAPIManager *sharedManager = nil;
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

@end
