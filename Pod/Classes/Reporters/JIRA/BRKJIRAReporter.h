//
//  BRKJIRAReporter.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRKImageUploaderDelegate.h"
#import "BRKReporterDelegate.h"

@interface BRKJIRAReporter : NSObject <BRKReporterDelegate>

- (id)initWithJIRABaseURL:(NSString*)baseURL
                 username:(NSString*)username
                 password:(NSString*)password
               projectKey:(NSString*)projectKey
            imageUploader:(id<BRKImageUploaderDelegate>)imageUploader;

@end
