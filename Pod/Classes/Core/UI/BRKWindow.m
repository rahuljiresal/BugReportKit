//
//  BRKWindow.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKWindow.h"

@implementation BRKWindow

- (id)initWithScreenshot:(UIImage*)screenshot {
    self = [self initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
    }
    return self;
}

@end
