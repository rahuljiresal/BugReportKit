//
//  BRKGithubReporter.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKGithubReporter.h"

@interface BRKGithubReporter() <NSURLSessionDataDelegate, NSURLSessionDelegate>

@property NSString* repository;
@property NSString* owner;
@property NSString* username;
@property NSString* password;
@property id<BRKImageUploaderDelegate> imageUploader;

@end

@implementation BRKGithubReporter

- (id)initWithGithubUsername:(NSString*)username
                  password:(NSString*)password
                repository:(NSString*)repo
                     owner:(NSString*)owner
               imageUploader:(id<BRKImageUploaderDelegate>)imageUploader {
    
    self = [self init];
    if (self) {
        self.password = password;
        self.username = username;
        self.repository = repo;
        self.owner = owner;
        self.imageUploader = imageUploader;
    }
    return self;
}

- (void)sendBugReportWithImage:(UIImage*)image text:(NSString *)text completionHandler:(void (^)(NSError *))handler {
    NSAssert([self.imageUploader respondsToSelector:@selector(uploadImage:completionHandler:)], @"Error: Invalid instance of BRKImageUploaderDelegate");
    
    [self.imageUploader uploadImage:image completionHandler:^(NSString *absoluteUrl, NSError *error) {
        if (error) {
            handler(error);
            return ;
        }
        
        
        NSString* githubUrlString = [NSString stringWithFormat:@"https://api.github.com/repos/%@/%@/issues", self.owner, self.repository];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:githubUrlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString* titleText = [text substringToIndex:MIN(text.length, 25)];
        NSString* bodyText = [NSString stringWithFormat:@"%@\n\n\nIssue reported using BugReportKit. Please see attached screenshot --!\n\n![Attached Screenshot](%@)", text, absoluteUrl];
        NSDictionary *bodyDict = @{
                                   @"title"     : [NSString stringWithFormat:@"%@...",  titleText],
                                   @"body"      : bodyText,
                                   @"assignee"  : self.username
                                   };
        
        NSError *jsonError;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict
                                                           options:0 // Pass NSJSONWritingPrettyPrinted if you care about the readability of the generated string
                                                             error:&jsonError];
        
        if (!jsonData) {
            handler(error);
            return;
        } else {
            NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
            NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
            NSString *authValue = [NSString stringWithFormat: @"Basic %@",[authData base64EncodedStringWithOptions:0]];
            [request setValue:authValue forHTTPHeaderField:@"Authorization"];
            [request setHTTPBody:jsonData];
            [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];

            NSLog(@"%@", request);
            NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                handler(error);
                
            }];
            [task resume];
        }
    }];
}

@end
