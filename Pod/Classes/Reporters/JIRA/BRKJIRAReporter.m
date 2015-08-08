//
//  BRKJIRAReporter.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKJIRAReporter.h"

@interface BRKJIRAReporter() 

@property NSString* baseURL;
@property NSString* projectKey;
@property NSString* username;
@property NSString* password;
@property id<BRKImageUploaderDelegate> imageUploader;

@end

@implementation BRKJIRAReporter

- (id)initWithJIRABaseURL:(NSString*)baseURL
                 username:(NSString*)username
                 password:(NSString*)password
               projectKey:(NSString*)projectKey
            imageUploader:(id<BRKImageUploaderDelegate>)imageUploader {
    
    self = [self init];
    if (self) {
        self.password = password;
        self.username = username;
        self.baseURL = baseURL;
        self.projectKey = projectKey;
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
        
        
        NSString* jiraUrlString = [NSString stringWithFormat:@"https://%@/rest/api/2/issue", self.baseURL];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:jiraUrlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString* summaryText = [text substringToIndex:MIN(text.length, 10)];
        NSString* description = [NSString stringWithFormat:@"%@\n\nPlease see attached screenshot.\n\n!%@!", text, absoluteUrl];
        NSDictionary *bodyDict = @{
                                   @"fields" : @{
                                       @"project"   : @{
                                               @"key" : self.projectKey
                                               },
                                       @"summary"     : [NSString stringWithFormat:@"BugReportKit Issue: %@...",  summaryText],
                                       @"description"      : description,
                                       @"issuetype"  : @{
                                               @"name" : @"Bug"
                                               }
                                       }
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
            
            NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                handler(error);
                
            }];
            [task resume];
        }
    }];
}

@end
