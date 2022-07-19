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
Take5 is a social media app that sends out a daily notification to users, gives them a 5 minute window to take and upload a picture post, and then can view all the daily posts on a map and all their personal posts on a calendar.

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
        * A scroll bar will also appear at the bottom of the screen that can horizontally scroll and see all the posts on the map. As the user scrolls, the map will shift to the current post in the tab bar.
        * When the user taps on the map where there is not a marker, the popup window and scroll bar will close.
* Calendar Screen
    * Shows the users previous posts on a calendar
        * For each day that the user posted, their post image will appear on the calendar
* Picture Taking Screen
    * Allows the user to take a photo for 5 minutes after a notification is sent out.
    * Can take a photo and post it, using both the front and back camera.

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Map Screen
* Calendar Screen

**Flow Navigation** (Screen to Screen)

* Forced Welcome -> Account creation or login if no user is logged in
* Register User -> To welcome page if user cancels, and to login page if user successfully creates an account.
* Forced take picture -> For 5 minutes after a notification, if the user taps on the notification or already has the app running in foreground while notification goes off, the photo taking page appears.
* Login -> Map Screen
* Photo Taking Screen -> Map screen after posting or after 5 minute window after notification

## Wireframes
<img src="https://github.com/jacquelinejou/CapstoneProject/blob/main/Screen%20Shot%202022-07-19%20at%2010.24.42%20AM.png" width=600>

### [BONUS] Digital Wireframes & Mockups

### [BONUS] Interactive Prototype

## Schema

### Models
#### Post
| Property | Type | Description |
| -------- | -------- | -------- |
| postID | String | unique ID of post |
| userID | String | unique ID of post's user |
| author | PFUser | post's author |
| date | Date | date of post |
| caption | String | caption of post (if any) |
| image | PFFileObject | image of post as stored in database |
| imageData | UIImage | usable image of post |
| reactions | Array<UIImage> | all reactions on this post |
| comments | Array<String> | all comments on this post |
| loaction | PFGeoLocation | location of post |
  
### Networking
#### List of network requests by screen
- Register Screen
    - (Create/POST) Create a new User
      ```objective-c
      PFUser *newUser = [PFUser user];
      // set user properties
      newUser.username = self.usernameText.text;
      newUser.password = self.passwordText.text;
      if ([self.usernameText.text isEqualToString:@""] || [self.passwordText.text isEqualToString:@""]) {
          [self registrationHelper];
      } else {
         [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
             if (error == nil) {
                 [self resignFirstResponder];
                 [self performSegueWithIdentifier:@"createdSegue" sender:nil];
             } else {
                 [self failedRegister];
             }
         }];
      }
      ```
- Login Screen
    - (Read/GET) Login User
      ```objective-c
      [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
           if (error == nil) {
               [self resignFirstResponder];
               [self performSegueWithIdentifier:@"loginSegue" sender:nil];
           } else {
               [self failedLogin];
           }
       }];
      ```
- Photo Screen
    - (Create/POST) Create a new post
