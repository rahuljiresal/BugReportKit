//
//  BRKS3ImageUploader.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-06.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AWSS3/AWSS3.h>
#import "AWSServiceEnum.h"

#import "BRKImageUploaderDelegate.h"

@interface BRKS3ImageUploader : NSObject <BRKImageUploaderDelegate>

- (id)initWithS3AccessKey:(NSString*)accesskey secretKey:(NSString*)secretKey bucketName:(NSString*)bucketName;

//typedef NS_ENUM(NSInteger, BRKS3AWSRegionType) {
//    AWSRegionUnknown,
//    AWSRegionUSEast1,
//    AWSRegionUSWest1,
//    AWSRegionUSWest2,
//    AWSRegionEUWest1,
//    AWSRegionEUCentral1,
//    AWSRegionAPSoutheast1,
//    AWSRegionAPNortheast1,
//    AWSRegionAPSoutheast2,
//    AWSRegionSAEast1,
//    AWSRegionCNNorth1,
//    AWSRegionUSGovWest1,
//};

- (id)initWithS3AccessKey:(NSString*)accesskey secretKey:(NSString*)secretKey bucketName:(NSString*)bucketName AWSRegion:(AWSRegionType)AWSRegion;

@end



