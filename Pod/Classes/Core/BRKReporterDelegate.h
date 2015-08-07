//
//  BRKReporterDelegate.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-06.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BRKReporterDelegate <NSObject>

- (void)sendBugReportWithImage:(UIImage*)image text:(NSString*)text completionHandler:(void(^)(NSError* error))handler;

@end
