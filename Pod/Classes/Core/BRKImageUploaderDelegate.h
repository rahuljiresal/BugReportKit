//
//  BRKImageUploaderDelegate.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-06.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BRKImageUploaderDelegate <NSObject>

- (void)uploadImage:(UIImage*)image completionHandler:(void(^)(NSString* absoluteUrl, NSError* error))handler;

@end
