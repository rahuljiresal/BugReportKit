//
//  BRKAppDelegate.m
//  BugReportKit
//
//  Created by Rahul Jiresal on 08/03/2015.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKAppDelegate.h"

#import <BugReportKit/BugReportKit.h>
#import <BugReportKit/BRKEmailReporter.h>
#import <BugReportKit/BRKGithubReporter.h>
#import <BugReportKit/BRKS3ImageUploader.h>
#import <BugreportKit/BRKJIRAReporter.h>

#define SET_THESE_OPTIONS_FIRST 1

#define EMAIL_HOSTNAME @""
#define EMAIL_HOSTPORT @0
#define EMAIL_USERNAME @""
#define EMAIL_PASSWORD @""
#define EMAIL_TO @""

#define S3_ACCESSKEY @""
#define S3_SECRETKEY @""
#define S3_BUCKET @""

#define GITHUB_USERNAME @""
#define GITHUB_PASSWORD @""
#define GITHUB_REPO @""
#define GITHUB_OWNER @""

#define JIRA_URL @""
#define JIRA_USERNAME @""
#define JIRA_PASSWORD @""
#define JIRA_PROJECTKEY @""

@implementation BRKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#if SET_THESE_OPTIONS_FIRST
#error "You need to set the options and delete the define macro for SET_THESE_OPTIONS_FIRST"
#endif
    
//    BRKEmailReporter* reporter = [[BRKEmailReporter alloc] initWithHostname:EMAIL_HOSTNAME port:EMAIL_HOSTPORT username:EMAIL_USERNAME password:EMAIL_PASSWORD connectionType:BRKEmailConnectionTypeClear toAddress:EMAIL_TO];

    BRKS3ImageUploader* uploader = [[BRKS3ImageUploader alloc] initWithS3AccessKey:S3_ACCESSKEY secretKey:S3_SECRETKEY bucketName:S3_BUCKET];

//    BRKJIRAReporter* reporter = [[BRKJIRAReporter alloc] initWithJIRABaseURL:JIRA_URL username:JIRA_USERNAME password:JIRA_PASSWORD projectKey:JIRA_PROJECTKEY imageUploader:uploader];
    
    BRKGithubReporter* reporter = [[BRKGithubReporter alloc] initWithGithubUsername:GITHUB_USERNAME password:GITHUB_PASSWORD repository:GITHUB_REPO owner:GITHUB_OWNER imageUploader:uploader];

    [BugReportKit initializeWith:reporter];

    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
