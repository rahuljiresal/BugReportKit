//
//  BRKAppDelegate.m
//  BugReportKit
//
//  Created by Rahul Jiresal on 08/03/2015.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKAppDelegate.h"

#import <BRK.h>
#import <BugReportKit/BRKEmailReporter.h>
#import <BugReportKit/BRKGithubReporter.h>
#import <BugReportKit/BRKGitlabReporter.h>
#import <BugReportKit/BRKS3ImageUploader.h>
#import <BugreportKit/BRKJIRAReporter.h>

#define SET_THESE_OPTIONS_FIRST 1

#define EMAIL_HOSTNAME @""
#define EMAIL_HOSTPORT @0
#define EMAIL_USERNAME @""
#define EMAIL_PASSWORD @""
#define EMAIL_TO @""

#define S3_ACCESSKEY @"AKIAI6PKI5T27G24RPMQ"
#define S3_SECRETKEY @"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"
#define S3_BUCKET @"bug-report-kit"

#define GITHUB_USERNAME @""
#define GITHUB_PASSWORD @""
#define GITHUB_REPO @""
#define GITHUB_OWNER @""

#define GITLAB_USERNAME @""
#define GITLAB_PASSWORD @""
#define GITLAB_REPO @""
#define GITLAB_OWNER @""

#define JIRA_URL @""
#define JIRA_USERNAME @""
#define JIRA_PASSWORD @""
#define JIRA_PROJECTKEY @""

@interface BRKAppDelegate () <BugReportKitDelegate>

@end

@implementation BRKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    BRKEmailReporter* reporter = [[BRKEmailReporter alloc] initWithHostname:EMAIL_HOSTNAME
//                                                                       port:EMAIL_HOSTPORT
//                                                                   username:EMAIL_USERNAME
//                                                                   password:EMAIL_PASSWORD
//                                                             connectionType:BRKEmailConnectionTypeClear
//                                                                  toAddress:EMAIL_TO];
    
//    BRKS3ImageUploader* uploader = [[BRKS3ImageUploader alloc] initWithS3AccessKey:S3_ACCESSKEY
//                                                                         secretKey:S3_SECRETKEY
//                                                                        bucketName:S3_BUCKET];
    
    
    BRKS3ImageUploader* uploader = [[BRKS3ImageUploader alloc] initWithS3AccessKey:S3_ACCESSKEY
                                                                         secretKey:S3_SECRETKEY
                                                                        bucketName:S3_BUCKET
                                                                         AWSRegion:AWSRegionUSWest2];

                                    
//    BRKJIRAReporter* reporter = [[BRKJIRAReporter alloc] initWithJIRABaseURL:JIRA_URL
//                                                                    username:JIRA_USERNAME
//                                                                    password:JIRA_PASSWORD
//                                                                  projectKey:JIRA_PROJECTKEY
//                                                               imageUploader:uploader];
    
    BRKGithubReporter* reporter = [[BRKGithubReporter alloc] initWithGithubUsername:GITHUB_USERNAME
                                                                           password:GITHUB_PASSWORD
                                                                         repository:GITHUB_REPO
                                                                              owner:GITHUB_OWNER
                                                                      imageUploader:uploader];
    
    

//    BRKGitlabReporter* reporter = [[BRKGitlabReporter alloc] initWithGitlabUsername:GITLAB_USERNAME
//                                                                           password:GITLAB_PASSWORD
//                                                                         repository:GITLAB_REPO
//                                                                              owner:GITLAB_OWNER
//                                                                      imageUploader:uploader];

    [BugReportKit initializeWithReporter:reporter delegate:self];
    [BugReportKit setUniqueUserIdentifier:@"rahul.jiresal@gmail.com"];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application { }

- (void)applicationDidEnterBackground:(UIApplication *)application { }

- (void)applicationWillEnterForeground:(UIApplication *)application { }

- (void)applicationDidBecomeActive:(UIApplication *)application{}

- (void)applicationWillTerminate:(UIApplication *)application {}

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

@end
