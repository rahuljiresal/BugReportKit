//
//  BugReportKit.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-03.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BugReportKit.h"
#import "BRKWindow.h"
#import "BRKViewController.h"
#import "mach/mach.h"


#import <GBDeviceInfo/GBDeviceInfo.h>

vm_size_t usedMemory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

vm_size_t freeMemory(void) {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    (void) host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size);
    return vm_stat.free_count * pagesize;
}


@interface BugReportKit() <BRKWindowDelegate>

@property (strong, nonatomic) UIWindow* originalWindow;
@property (strong, nonatomic) NSNumber* originalOrientation;

@property (strong, nonatomic) BRKWindow* brkWindow;
@property (strong, nonatomic) id<BRKReporterDelegate> brkReporter;
@property (strong, nonatomic) id<BugReportKitDelegate> bugReportKitDelegate;

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

+ (void)initializeWithReporter:(id<BRKReporterDelegate>)reporter delegate:(id<BugReportKitDelegate>)bugReportKitDelegate {
    NSAssert([reporter respondsToSelector:@selector(sendBugReportWithImage:text:completionHandler:)], @"Error: Invalid Instance of reporter.");
    
    BugReportKit* instance = [BugReportKit sharedInstance];
    instance.brkReporter = reporter;
    instance.bugReportKitDelegate = bugReportKitDelegate;
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
        self.brkWindow = [[BRKWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    }

    [self.brkWindow setWindowLevel:UIWindowLevelAlert + 1000];
    [self.brkWindow setBrkWindowDelegate:self];
    [self.brkWindow setBrkReporterDelegate:self.brkReporter];
    
    BRKViewController *vc = [[BRKViewController alloc] initWithScreenshot:screenshot metaInfo:[self populateMetaInfo]];
    vc.parentWindow = self.brkWindow;
    self.brkWindow.rootViewController = vc;

    [self.brkWindow makeKeyAndVisible];
}

- (NSString*)populateMetaInfo {
    NSMutableString* meta = [NSMutableString stringWithFormat:@"\n\n\n============= %@ =============\n\n", NSLocalizedString(@"Device Metadata", nil)];
    
    [meta appendString:[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Device", nil), [GBDeviceInfo deviceInfo].modelString]];
    [meta appendString:[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"iOS Version", nil), [NSString stringWithFormat:@"%lu.%lu.%lu", (unsigned long)[GBDeviceInfo deviceInfo].osVersion.major, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.minor, (unsigned long)[GBDeviceInfo deviceInfo].osVersion.patch]]];
    [meta appendString:[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Jailbroken", nil), [GBDeviceInfo deviceInfo].isJailbroken ? NSLocalizedString(@"Yes", nil) : NSLocalizedString(@"No", nil)]];
    [meta appendString:[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Memory", nil), [NSString stringWithFormat:@"%5.1f MB Used (App), %5.1f MB Free (App), %5.1f GB Total (System)", usedMemory()/1000000.0f, freeMemory()/1000000.0f, [GBDeviceInfo deviceInfo].physicalMemory]]];
    
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        [meta appendString:[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Disk Space", nil), [NSString stringWithFormat:@"%llu MB Free, %llu MB Total", ((totalFreeSpace/1024ll)/1024ll), ((totalSpace/1024ll)/1024ll)]]];
    }
    
    UIDevice *device = [UIDevice currentDevice];
    [device setBatteryMonitoringEnabled:YES];
    float batLeft = [device batteryLevel];
    int batinfo = (batLeft * 100);
    NSString* batteryStatus;
    switch ([device batteryState]) {
        case UIDeviceBatteryStateUnplugged: {
            batteryStatus = NSLocalizedString(@"Unplugged", nil);
            break;
        }
        case UIDeviceBatteryStateCharging: {
            batteryStatus = NSLocalizedString(@"Charging", nil);
            break;
        }
        case UIDeviceBatteryStateFull: {
            batteryStatus = NSLocalizedString(@"Full", nil);
            break;
        }
        default: {
            batteryStatus = NSLocalizedString(@"Unknown", nil);
            break;
        }
    }

    [meta appendString:[NSString stringWithFormat:@"%@: %@\n", NSLocalizedString(@"Battery", nil), [NSString stringWithFormat:@"%d%% (%@)", batinfo, batteryStatus]]];
    
    [meta appendString:[NSString stringWithFormat:@"\n=================== %@ ===================\n", NSLocalizedString(@"-", nil)]];
    
    return meta;
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
    [self dismissBRKWindow];
    if ([self.bugReportKitDelegate respondsToSelector:@selector(bugReportSentSuccessfully)]) {
        [self.bugReportKitDelegate bugReportSentSuccessfully];
    }
}

- (void)bugReportCancelled {
    [self dismissBRKWindow];
    if ([self.bugReportKitDelegate respondsToSelector:@selector(bugReportCancelled)]) {
        [self.bugReportKitDelegate bugReportCancelled];
    }
}

- (void)bugReportFailedToSend {
    [self dismissBRKWindow];
    if ([self.bugReportKitDelegate respondsToSelector:@selector(bugReportFailedToSend)]) {
        [self.bugReportKitDelegate bugReportFailedToSend];
    }
}

- (void)dismissBRKWindow {
    [self.brkWindow setWindowLevel:UIWindowLevelNormal];
    [self.brkWindow setHidden:YES];
    self.brkWindow.rootViewController = nil;
    self.brkWindow = nil;
    [self.originalWindow makeKeyAndVisible];

    [[UIDevice currentDevice] setValue:self.originalOrientation forKey:@"orientation"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenshotDetectedNotification:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
}


@end
