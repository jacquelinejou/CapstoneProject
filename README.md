# CapstoneProject
===

# Take5

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Take5 is a social media app that sends out a daily notification to users, gives them a 5 minute window to take and upload a front and back camera video post, and then can view all the daily posts on a map and all their personal posts on a calendar.

### App Evaluation
[Evaluation of your app across the following attributes]
- **Category:** Social Media
- **Mobile:** The app is for mobile use because it requires the use of a front and back camera.
- **Story:** Each user makes an account, logs in, then views a map of all the posts and can toggle back and forth between the map and a calendar. For 5 minutes after the notification, a camera view will be available for users to take a picture and post it.
- **Market:** Any individual who is interested in connecting with friends via social media. Target demographic is 13-30.
- **Habit:** This app is intended to be used daily.
- **Scope:** Start by individual user's posting, then interacting with each other's posts and expanding their network.
## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users must register a new account on their first time using the app.
* Users must login to see further information.
* Users can see a map filled with pins of the posts of the day.
* Users can see a calendar where each day a user posts, their post image is visible on that day in the calendar.
* Users can take a picture and upload it for 5 minutes after their daily post notification.

**Optional Nice-to-have Stories**

* Push notifications to post
* Custom camera with multicamera use (front and back cam usage at the same time)
* More efficient map loading (limit API calls to only retrieve posts that are in map frame.
* Users can add friends
* Friends can comment/react to post
* Sort posts in a scroll bar on the map view based on distance
* Search bar in map to search by user

### 2. Screen Archetypes

* Welcome - User sees welcome page with choice to register or login.
* Login - User can login
    * If failed login, popup message to tell user. Can cancel and return to welcome page or okay and try again.
* Register - User signs up
    * Upon reopening of the application, the user is brought to the home page
    * If username already taken, popup message to tell user. Can cancel and return to welcome page or okay and try again.
* Map Screen
    * Shows a user a map with markers in the location of each post of the day.
      * When click on a marker, will recenter with marker in the center of the screen and a popup window will appear above the marker with the post image, username, date, number of comments and reactions.
      * A scroll bar will also appear at the bottom of the screen that can horizontally scroll and see all the posts on the map.
      * When the user taps on the map where there is not a marker, the popup window and scroll bar will close.
      * When user taps on a post in scroll bar, will recenter on that post's location and popup with a post details page.
* Post Details Screen
    * Shows user's post details, including their video, username, post date/time, number of comments and reactions
    * User can tap on the number of comments or reactions to see all the comments/reactions and add their own.
* Comments Screen 
    * Users can see all the comments, which user commented, and the comment time.
    * Users can add their own comment.
* Reactions Screen
    * Users can see all the reactions, who reacted, and the reaction time.
    * Users can add their own reaction, using the front camera to take a photo.
* Calendar Screen
    * Shows the users previous posts on a calendar
        * For each day that the user posted, their post image will appear on the calendar
        * When users click on the calendar cell, their video will popup and be played
* Picture Taking Screen
    * Allows the user to take a 5-second video for 5 minutes after a notification is sent out.
    * Can take a video and post it, using both the front and back camera.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Map Screen
* Calendar Screen

**Flow Navigation** (Screen to Screen)

* Forced Welcome -> Account creation or login if no user is logged in
* Register User -> To welcome page if user cancels, and to login page if user successfully creates an account.
* Forced take picture -> For 5 minutes after a notification, if the user taps on the notification or already has the app running in foreground while notification goes off, the video taking page appears.
* Login -> Map Screen
* Video Taking Screen -> Video Playing screen to play the user's video
* Video Playing screen -> Map screen after posting or after 5 minute window after notification
* Map Screen -> Post details screen when a user taps on a post in the scroll bar.
* Post details screen -> Comments screen when a user taps on the number of comments.
* Post details screen -> Reactions screen when a user taps on the number of reactions.
* Reactions screen -> Video Taking Screen appears with settings changed to take a photo reaction
* Calendar Screen -> Video playing screen with the tapped cell's video

## Wireframes
<img src="https://github.com/jacquelinejou/CapstoneProject/blob/main/Screen%20Shot%202022-08-05%20at%205.02.24%20PM.png" width=600>

### [BONUS] Interactive Prototype

# Map Scroll Bar & markers
https://user-images.githubusercontent.com/73207898/183226089-d62957b1-c40a-492f-af89-30c2ef9d6473.mp4

# Map fetching data as it comes into frame
https://user-images.githubusercontent.com/73207898/183226125-51fa2154-5435-427c-8e79-551a309adaf2.mp4

# Tapping cell in Map scroll bar to show post details
https://user-images.githubusercontent.com/73207898/183226147-c07e3457-cacd-4cf2-afef-441f9cdad571.mp4

# Tapping number of comments in post details to see comments and add comment
https://user-images.githubusercontent.com/73207898/183226162-ed070d0e-5841-47c2-9e00-8c6228c52b47.mp4

# Tapping number of reactions in post details to see reactions and add reaction
https://user-images.githubusercontent.com/73207898/183226178-1a265e94-7d9c-44eb-8f48-15574f0012df.mp4

# Tapping a cell in calendar to see video of the day
https://user-images.githubusercontent.com/73207898/183226193-8965b90b-4f08-4dae-806b-7062dd5f06e0.mp4

# Getting post notification and posting a video. Watch it play back and go back to map.
https://user-images.githubusercontent.com/73207898/183226494-1e8941d8-6bbc-4c1e-905b-1ff81b2b6a37.mp4

## Schema

### Models
#### Post
| Property | Type | Description |
| -------- | -------- | -------- |
| postID | String | unique ID of post |
| UserID | String | unique ID of post's user |
| author | PFUser | post's author |
| date | Date | date of post |
| Image | PFFileObject | image of post as stored in database |
| Video | PFFileObject | foreground video of post |
| Video2 | PFFileObject | background video of post |
| imageData | UIImage | usable image of post |
| Reactions | Array<UIImage> | all reactions on this post |
| Comments | Array<String> | all comments on this post |
| Location | PFGeoLocation | location of post |
| isFrontCamInForeground | BOOL | records which camera was in foreground for playback |

#### Comments
| Property | Type | Description |
| -------- | -------- | -------- |
| postID | String | unique ID of post associated with the comment |
| comment | String | the text of the comment |
| user | PFUser | post's author |
| username | String | username of comment's user |

#### Reactions
| Property | Type | Description |
| -------- | -------- | -------- |
| postID | String | unique ID of post associated with the comment |
| reaction | PFFileObject | the image of the reaction |
| username | String | username of comment's user |
  
### Networking
#### List of network requests by screen
- SceneDelegate Screen
    - (Read/GET) Get connection to Parse database
      ```objective-c
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
      ```
- Register Screen
    - (Create/POST) Create a new User
      ```objective-c
      [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        completion(error);
    }];
      ```
- Login Screen
    - (Read/GET) Login User
      ```objective-c
      [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        completion(error);
    }];
      ```
- Map Screen
   - (Read/GET) logout of user's account
   ```objective-c
   [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        SceneDelegate *mySceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        WelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeView"];
        mySceneDelegate.window.rootViewController = welcomeViewController;
        [[CacheManager sharedManager] didlogout];
    }];
      ```
    - (Read/GET) fetch all posts from the day
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:today];
    [query whereKey:@"Location" withinPolygon:coordinates];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if (parsePosts != nil) {
            completion(parsePosts, error);
        }
    }];
      ```
- Photo Screen
    - (Create/POST) Create a new post
    ```objective-c
    Post *newPost = [Post new];
    UIImage *image = [self imageFromVideo:backURL atTime:_startTime];
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
      ```
- Calendar Screen
    - (Read/GET) fetch all current month's posts
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query whereKey:@"UserID" equalTo:user.username];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:firstDateMonth];
    [query whereKey:@"createdAt" lessThan:lastDateMonth];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if (parsePosts != nil) {
            completion(parsePosts, error);
        }
    }];
      ```
    - (Read/GET) fetch latest post from user after they posted
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"UserID" equalTo:user.username];
    [query whereKey:@"createdAt" greaterThanOrEqualTo:today];
    [query findObjectsInBackgroundWithBlock:^(NSArray *parsePosts, NSError *error) {
        if ([parsePosts count] == _increment) {
            completion([parsePosts firstObject], YES);
        } else {
            completion(nil, NO);
        }
    }];
      ```
- Comments Screen
    - (Read/GET) fetch all comments for given post
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Comments"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postID" equalTo:postID];

    [query findObjectsInBackgroundWithBlock:^(NSArray *parseComments, NSError *error) {
        completion(parseComments, error);
    }];
      ```
    - (Read/GET) fetch latest comment for given post after current user commented
    ```objective-c
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
      ```
    - (Read/GET) post comment
    ```objective-c
    [Comments postComment:comment withPostID:postID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateNumberCommentsWithCompletion:postID comment:comment];
        [self fetchLastCommentWithCompletion:postID completion:^(Comments *comment, NSError *error) {
            completion(comment, error);
        }];
    }];
      ```
    - (Read/GET) update number of reactions after the user reacted for other screens
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query getObjectInBackgroundWithId:postID block:^(PFObject *post, NSError *error) {
        NSMutableArray *newComments = (NSMutableArray *)post[@"Comments"];
        [newComments addObject:comment];
        post[@"Comments"] = newComments;
        [post saveInBackground];
    }];
      ```
- Reactions Screen
    - (Read/GET) fetch all reactions for given post
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Reactions"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postID" equalTo:postID];

    [query findObjectsInBackgroundWithBlock:^(NSArray *parseReactions, NSError *error) {
        completion(parseReactions, error);
    }];
      ```
    - (Read/GET) fetch latest reaction for given post after current user reacted
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Reactions"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"postID" equalTo:postID];
    query.limit = 1;
    [query findObjectsInBackgroundWithBlock:^(NSArray *parseReactions, NSError *error) {
        if (parseReactions.count == 1) {
            completion([parseReactions firstObject], error);
        } else {
            completion(nil, error);
        }
    }];
      ```
    - (Read/GET) post reaction
    ```objective-c
    [Reactions postReaction:reaction withPostID:postID withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        [self updateNumberReactionsWithCompletion:postID reaction:reaction];
        [self fetchLastReactionWithCompletion:postID completion:^(Reactions *reaction, NSError *error) {
            completion(reaction, error);
        }];
    }];
      ```
    - (Read/GET) fetch latest reaction for given post after current user reacted
    ```objective-c
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query getObjectInBackgroundWithId:postID block:^(PFObject *post, NSError *error) {
        NSMutableArray *newReactions = (NSMutableArray *)post[@"Reactions"];
        PFFileObject *image = [Post getPFFileFromImage:reaction];
        [newReactions addObject:image];
        post[@"Reactions"] = newReactions;
        [post saveInBackground];
    }];
      ```
