# BugReportKit

[![CI Status](http://img.shields.io/travis/Rahul Jiresal/BugReportKit.svg?style=flat)](https://travis-ci.org/Rahul Jiresal/BugReportKit)
[![Version](https://img.shields.io/cocoapods/v/BugReportKit.svg?style=flat)](http://cocoapods.org/pods/BugReportKit)
[![License](https://img.shields.io/cocoapods/l/BugReportKit.svg?style=flat)](http://cocoapods.org/pods/BugReportKit)
[![Platform](https://img.shields.io/cocoapods/p/BugReportKit.svg?style=flat)](http://cocoapods.org/pods/BugReportKit)

## About

We've always wanted bug reports to be easy. Our users should not have to jump through hoops to tell us what happened on the app. BugReportKit is an attempt to do that.

Once BugReportKit is integrated into your app, all you need to do is take a screenshot, point to the bug on the screen by doodling on it, write a small description, and send it away! BugReportKit currently allows you to send bug reports as Github Issues, JIRA Issues, or Emails.

Here is a GIF'ed video --

![BugReportKit GIF](https://cloud.githubusercontent.com/assets/216346/9147661/06328b94-3d1f-11e5-829f-bbda3ceb9856.gif)

To run the sample project, clone the repo, and run `pod install` from the Example directory first.


## Installation

BugReportKit is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "BugReportKit"
```

## Usage

Github and JIRA do not support uploading images through their APIs. Hence we need a place to upload images publicly and include the link to the Github/JIRA issues. `BugReportKit` includes the AWS S3 uploader, but you can easily create your own by implementing the `BRKImageUploader` protocol.

### Send Bug Reports to Github Issues

You need these additional sub-pod for Github.
```ruby
pod "BugReportKit"
pod "BugReportKit/GithubReporter"
```
Then, in your `AppDelegate`, 
```objective-c
#import <BRK.h>
#import <BugReportKit/BRKGithubReporter.h>
#import <BugReportKit/BRKS3ImageUploader.h>
```
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BRKS3ImageUploader* uploader = [[BRKS3ImageUploader alloc] initWithS3AccessKey:S3_ACCESSKEY
                                                                         secretKey:S3_SECRETKEY
                                                                        bucketName:S3_BUCKET];
    BRKGithubReporter* reporter = [[BRKGithubReporter alloc] initWithGithubUsername:GITHUB_USERNAME
                                                                           password:GITHUB_PASSWORD
                                                                         repository:GITHUB_REPO
                                                                              owner:GITHUB_OWNER
                                                                      imageUploader:uploader];
    
    [BugReportKit initializeWithReporter:reporter delegate:self];
    
    return YES;
}
```

### Send Bug Reports to JIRA Issues

You need these additional sub-pod for Github.
```ruby
pod "BugReportKit"
pod "BugReportKit/JIRAReporter"
```
Then, in your `AppDelegate`, 
```objective-c
#import <BRK.h>
#import <BugreportKit/BRKJIRAReporter.h>
#import <BugReportKit/BRKS3ImageUploader.h>
```
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BRKS3ImageUploader* uploader = [[BRKS3ImageUploader alloc] initWithS3AccessKey:S3_ACCESSKEY
                                                                         secretKey:S3_SECRETKEY
                                                                        bucketName:S3_BUCKET];
    BRKJIRAReporter* reporter = [[BRKJIRAReporter alloc] initWithJIRABaseURL:JIRA_URL
                                                                    username:JIRA_USERNAME
                                                                    password:JIRA_PASSWORD
                                                                  projectKey:JIRA_PROJECTKEY
                                                               imageUploader:uploader];
    
    [BugReportKit initializeWithReporter:reporter delegate:self];
    
    return YES;
}
```

### Send Bug Reports to Gitlab Issues

You need these additional sub-pod for Gitlab.
```ruby
pod "BugReportKit"
pod "BugReportKit/GitlabReporter"
```
Then, in your `AppDelegate`, 
```objective-c
#import <BRK.h>
#import <BugReportKit/BRKGitlabReporter.h>
#import <BugReportKit/BRKS3ImageUploader.h>
```
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BRKS3ImageUploader* uploader = [[BRKS3ImageUploader alloc] initWithS3AccessKey:S3_ACCESSKEY
                                                                         secretKey:S3_SECRETKEY
                                                                        bucketName:S3_BUCKET];
    BRKGitlabReporter* reporter = [[BRKGitlabReporter alloc] initWithGitlabUsername:GITLAB_USERNAME
                                                                           password:GITLAB_PASSWORD
                                                                         repository:GITLAB_REPO
                                                                              owner:GITLAB_OWNER
                                                                      imageUploader:uploader];
    
    [BugReportKit initializeWithReporter:reporter delegate:self];
    
    return YES;
}
```


### Send Bug Reports via Email

*Note: The dependency used by the Email sub-pod has a huge static library (100+ MB). I would not recommend using emails to report bugs unless you don't have any other options.*

You need these additional sub-pod for Github.
```ruby
pod "BugReportKit"
pod "BugReportKit/EmailReporter"
```
Then, in your `AppDelegate`, 
```objective-c
#import <BRK.h>
#import <BugreportKit/BRKEmailReporter.h>
```
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    BRKEmailReporter* reporter = [[BRKEmailReporter alloc] initWithHostname:EMAIL_HOSTNAME
                                                                       port:EMAIL_HOSTPORT
                                                                   username:EMAIL_USERNAME
                                                                   password:EMAIL_PASSWORD
                                                             connectionType:BRKEmailConnectionTypeClear
                                                                  toAddress:EMAIL_TO];
    
    [BugReportKit initializeWithReporter:reporter delegate:self];
    
    return YES;
}
```

### You can also add `BugReportKitDelegate` methods

```objective-c
#pragma mark - BugReportKitDelegate

- (void)bugReportSentSuccessfully {
    NSLog(@"Bug Report Was Sent Successfully");
}

- (void)bugReportFailedToSend {
    NSLog(@"Bug Report Failed");
}

- (void)bugReportCancelled {
    NSLog(@"Bug Report Was Cancelled");
}

```


## Author

Let me know if you like the library, or have any suggestions, let me know. I plan to maintain this library regularly. Any pull requests are welcome!

Rahul Jiresal, rahul.jiresal@gmail.com, [Website](http://www.rahuljiresal.com), [Twitter](https://www.twitter.com/rahuljiresal)

## License

BugReportKit is available under the MIT license. See the LICENSE file for more info.
