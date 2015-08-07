//
//  BugReportKitDelegate.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-07.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BugReportKitDelegate <NSObject>

- (void)bugReportFailedToSend;
- (void)bugReportSentSuccessfully;
- (void)bugReportCancelled;

@end

