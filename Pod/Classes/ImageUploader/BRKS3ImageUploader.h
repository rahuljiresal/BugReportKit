//
//  BRKS3ImageUploader.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-06.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>

#import "BRKImageUploaderDelegate.h"

@interface BRKS3ImageUploader : NSObject <BRKImageUploaderDelegate>

- (id)initWithS3AccessKey:(NSString*)accesskey secretKey:(NSString*)secretKey bucketName:(NSString*)bucketName;

@end
