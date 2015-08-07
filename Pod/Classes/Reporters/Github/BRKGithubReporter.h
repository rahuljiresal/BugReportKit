//
//  BRKGithubReporter.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BRKImageUploaderDelegate.h"
#import "BRKReporterDelegate.h"

@interface BRKGithubReporter : NSObject <BRKReporterDelegate>

- (id)initWithGithubUsername:(NSString*)username
                    password:(NSString*)password
                  repository:(NSString*)repo
                       owner:(NSString*)owner
               imageUploader:(id<BRKImageUploaderDelegate>)imageUploader;

@end
