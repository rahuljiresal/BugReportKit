//
//  BRKWindow.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BugReportKit.h"

@protocol BRKWindowDelegate <NSObject>

- (void)bugReportSent;
- (void)bugReportFailedToSend;
- (void)bugReportCancelled;

@end


@interface BRKWindow : UIWindow

@property (strong, nonatomic) id<BRKWindowDelegate> brkWindowDelegate;
@property (strong, nonatomic) id<BRKReporterDelegate> brkReporterDelegate;

- (id)initWithScreenshot:(UIImage*)screenshot;

@end
