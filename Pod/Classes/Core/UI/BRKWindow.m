//
//  BRKWindow.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKWindow.h"
#import "BRKViewController.h"

@implementation BRKWindow

- (id)initWithScreenshot:(UIImage*)screenshot {
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        BRKViewController *vc = [[BRKViewController alloc] initWithScreenshot:screenshot];
        vc.parentWindow = self;
        self.rootViewController = vc;
    }
    return self;
}

@end
