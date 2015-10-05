//
//  BRKGitlabReporter.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-07.
//
//

#import "BRKGitlabReporter.h"

@interface BRKGitlabReporter ()

@property NSString* repository;
@property NSString* owner;
@property NSString* username;
@property NSString* password;
@property id<BRKImageUploaderDelegate> imageUploader;

@end

@implementation BRKGitlabReporter

- (id)initWithGitlabUsername:(NSString*)username
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

- (void)sendBugReportWithImage:(UIImage*)image text:(NSString *)text completionHandler:(void (^)(NSError *error, NSString* url))handler {
    NSAssert([self.imageUploader respondsToSelector:@selector(uploadImage:completionHandler:)], @"Error: Invalid instance of BRKImageUploaderDelegate");
    
    [self.imageUploader uploadImage:image completionHandler:^(NSString *absoluteUrl, NSError *error) {
        if (error) {
            handler(error, nil);
            return ;
        }
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
        
        NSString* gitlabSessionUrl = @"https://gitlab.com/api/v3/session";
        NSMutableURLRequest *sessionRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:gitlabSessionUrl]];
        [sessionRequest setHTTPMethod:@"POST"];
        
        NSDictionary* sessionRequestBody = @{
                                             @"login"    :   self.username,
                                             @"password" :   self.password
                                             };
        
        NSError* sessionJsonError;
        NSData *sessionJsonData = [NSJSONSerialization dataWithJSONObject:sessionRequestBody options:0 error:&sessionJsonError];
        
        if (!sessionJsonData) {
            handler(sessionJsonError, nil);
        }
        else {
            [sessionRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [sessionRequest setHTTPBody:sessionJsonData];
            [sessionRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)sessionJsonData.length] forHTTPHeaderField:@"Content-Length"];
            
            NSURLSessionTask* sessionTask = [session dataTaskWithRequest:sessionRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                
                if (error) {
                    handler(error, nil);
                    return;
                }
                
                NSError* jsonConversionError;
                NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonConversionError];
                NSString* privateToken = [responseDict objectForKeyedSubscript:@"private_token"];
                NSNumber* assigneeId = [responseDict objectForKey:@"id"];

                NSString* projectId = [NSString stringWithFormat:@"%@%%2F%@", self.owner, self.repository];
                NSString* gitlabUrlString = [NSString stringWithFormat:@"https://gitlab.com/api/v3/projects/%@/issues", projectId];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:gitlabUrlString]];
                [request setHTTPMethod:@"POST"];
                
                NSRange range = [text rangeOfString:@"\n"];
                NSInteger min = range.location;
                NSString* titleText = [[text substringToIndex:MIN(text.length, min)] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
                NSString* bodyText = [NSString stringWithFormat:@"%@\n\n\nIssue reported using BugReportKit. Please see attached screenshot --!\n\n[Attached Screenshot](%@)", text, absoluteUrl];
                NSDictionary *bodyDict = @{
                                           @"title"         : [NSString stringWithFormat:@"%@...",  titleText],
                                           @"description"   : bodyText,
                                           @"assignee_id"   : assigneeId
                                           };
                
                NSError *jsonError;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bodyDict
                                                                   options:0 // Pass NSJSONWritingPrettyPrinted if you care about the readability of the generated string
                                                                     error:&jsonError];
                
                if (!jsonData) {
                    handler(error, nil);
                    return;
                } else {
                    [request setValue:privateToken forHTTPHeaderField:@"PRIVATE-TOKEN"];
                    [request setHTTPBody:jsonData];
                    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)jsonData.length] forHTTPHeaderField:@"Content-Length"];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                    
                    NSURLSessionTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                        handler(error, nil);
                        
                    }];
                    [task resume];
                }
            }];
            
            [sessionTask resume];
        }
        
        

    }];
}

@end
