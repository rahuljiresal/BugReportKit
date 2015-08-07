//
//  BugReportKit.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-03.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BugReportKit.h"
#import "BRKWindow.h"

@interface BugReportKit() <BRKWindowDelegate>

@property (strong, nonatomic) UIWindow* originalWindow;
@property (strong, nonatomic) NSNumber* originalOrientation;

@property (strong, nonatomic) BRKWindow* brkWindow;
@property (strong, nonatomic) id<BRKReporterDelegate> brkReporter;

@end

@implementation BugReportKit

static BugReportKit *SINGLETON = nil;

static bool isFirstAccess = YES;

#pragma mark - Public Method

+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isFirstAccess = NO;
        SINGLETON = [[super allocWithZone:NULL] init];    
    });
    
    return SINGLETON;
}

#pragma mark - Life Cycle

+ (id) allocWithZone:(NSZone *)zone {
    return [self sharedInstance];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copy {
    return [[BugReportKit alloc] init];
}

- (id)mutableCopy {
    return [[BugReportKit alloc] init];
}

- (id) init {
    if(SINGLETON){
        return SINGLETON;
    }
    if (isFirstAccess) {
        [self doesNotRecognizeSelector:_cmd];
    }
    self = [super init];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)initializeWith:(id<BRKReporterDelegate>)reporter {
    NSAssert([reporter respondsToSelector:@selector(sendBugReportWithImage:text:completionHandler:)], @"Error: Invalid Instance of reporter.");
    
    BugReportKit* instance = [BugReportKit sharedInstance];
    instance.brkReporter = reporter;
    [[NSNotificationCenter defaultCenter] addObserver:instance selector:@selector(screenshotDetectedNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)screenshotDetectedNotification:(id)notification {
    UIImage* screenshot = [BugReportKit screenshot];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.originalOrientation = [[UIDevice currentDevice] valueForKey:@"orientation"];
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];

    self.originalWindow = [[UIApplication sharedApplication] keyWindow];
    
    for (UIWindow* window in [[UIApplication sharedApplication] windows]) {
        if ([window isKindOfClass:[BRKWindow class]]) {
            self.brkWindow = (BRKWindow*)window;
            break;
        }
    }
    if (!self.brkWindow) {
        self.brkWindow = [[BRKWindow alloc] initWithScreenshot:screenshot];
    }

    [self.brkWindow setWindowLevel:UIWindowLevelAlert + 1000];
    [self.brkWindow setBrkWindowDelegate:self];
    [self.brkWindow setBrkReporterDelegate:self.brkReporter];
    [self.brkWindow makeKeyAndVisible];
}

+ (UIImage *)screenshot {
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - BRKWindowDelegate

- (void)bugReportSent {
    [self.brkWindow setWindowLevel:UIWindowLevelNormal];
    [self.brkWindow setHidden:YES];
    self.brkWindow = nil;
    [self.originalWindow makeKeyAndVisible];
    
    [[UIDevice currentDevice] setValue:self.originalOrientation forKey:@"orientation"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenshotDetectedNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)bugReportCancelled {
    [self.brkWindow setWindowLevel:UIWindowLevelNormal];
    [self.brkWindow setHidden:YES];
    self.brkWindow = nil;
    [self.originalWindow makeKeyAndVisible];
    
    [[UIDevice currentDevice] setValue:self.originalOrientation forKey:@"orientation"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenshotDetectedNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}

- (void)bugReportFailedToSend {
    [self.brkWindow setWindowLevel:UIWindowLevelNormal];
    [self.brkWindow setHidden:YES];
    self.brkWindow = nil;
    [self.originalWindow makeKeyAndVisible];
    
    [[UIDevice currentDevice] setValue:self.originalOrientation forKey:@"orientation"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenshotDetectedNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}


@end
