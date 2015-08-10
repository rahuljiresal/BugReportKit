//
//  BugReportKit.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-03.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "BRKReporterDelegate.h"
#import "BugReportKitDelegate.h"

@interface BugReportKit : NSObject

+ (void)initializeWithReporter:(id<BRKReporterDelegate>)reporter delegate:(id<BugReportKitDelegate>)bugReportKitDelegate;
+ (void)setUniqueUserIdentifier:(NSString*)userIdentifier;

@end

