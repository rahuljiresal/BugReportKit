//
//  BRKGitlabReporter.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-07.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BRKImageUploaderDelegate.h"
#import "BRKReporterDelegate.h"

@interface BRKGitlabReporter : NSObject <BRKReporterDelegate>

- (id)initWithGitlabUsername:(NSString*)username
                    password:(NSString*)password
                  repository:(NSString*)repo
                       owner:(NSString*)owner
               imageUploader:(id<BRKImageUploaderDelegate>)imageUploader;


@end
