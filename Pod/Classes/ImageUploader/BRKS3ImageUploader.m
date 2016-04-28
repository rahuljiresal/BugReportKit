//
//  BRKS3ImageUploader.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-06.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKS3ImageUploader.h"

#import <AWSCredentialsProvider.h>

typedef void (^Handler)(NSString *, NSError *);

@interface BRKS3ImageUploader ()

@property NSString* bucketName;
@property NSString* urlString;

@end


@implementation BRKS3ImageUploader


- (id)initWithS3AccessKey:(NSString*)accesskey secretKey:(NSString*)secretKey bucketName:(NSString*)bucketName {
    self = [self init];
    if (self) {
        self.bucketName = bucketName;
        AWSStaticCredentialsProvider *cp = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accesskey secretKey:secretKey];
        AWSServiceConfiguration* config = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:cp];
        [AWSS3TransferManager registerS3TransferManagerWithConfiguration:config forKey:@"BugReportKitS3Uploader"];
    }
    return self;
}


- (id)initWithS3AccessKey:(NSString*)accesskey secretKey:(NSString*)secretKey bucketName:(NSString*)bucketName AWSRegion:(AWSRegionType)AWSRegion{
    self = [self init];
    if (self) {
        self.bucketName = bucketName;
        AWSStaticCredentialsProvider *cp = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:accesskey secretKey:secretKey];
        AWSServiceConfiguration* config = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegion credentialsProvider:cp];
        [AWSS3TransferManager registerS3TransferManagerWithConfiguration:config forKey:@"BugReportKitS3Uploader"];
    }
    return self;
}



- (void)uploadImage:(UIImage *)image completionHandler:(void (^)(NSString *, NSError *))handler {
    
    NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".png"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    NSData * imageData = UIImagePNGRepresentation(image);
    
    BOOL fileWritten = [imageData writeToFile:filePath atomically:YES];
    
    if (!fileWritten) {
        NSLog(@"File write failed");
    }
    
    AWSS3TransferManagerUploadRequest *uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.body = [NSURL fileURLWithPath:filePath];
    uploadRequest.key = fileName;
    uploadRequest.bucket = self.bucketName;
    uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    uploadRequest.contentType = @"image/png";
    
    AWSS3TransferManager* tm = [AWSS3TransferManager S3TransferManagerForKey:@"BugReportKitS3Uploader"];
    [[tm upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"Error: %@", task.error.localizedDescription);
        }
        else if (task.result) {
            NSLog(@"%@", NSStringFromClass([task.result class]));
        }

        NSString* uploadUrl = [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/%@", self.bucketName, fileName];
        handler(uploadUrl, task.error);
        
        return nil;
    }];
}



@end
