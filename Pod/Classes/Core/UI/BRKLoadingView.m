//
//  BRKLoadingView.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-07.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKLoadingView.h"
#import "BRKWindow.h"

@interface BRKLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation BRKLoadingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:7.0f];
        self.layer.masksToBounds = YES;
        self.alpha = 0.95f;
    }
    return self;
}

- (void)layoutSubviews {
    
    CGRect parentViewFrame = self.bounds;
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.spinner.color = [UIColor darkGrayColor];
    self.spinner.bounds = parentViewFrame;
    self.spinner.center = CGPointMake(CGRectGetMidX(parentViewFrame), CGRectGetMidX(parentViewFrame));
    [self.spinner startAnimating];
    
    [self addSubview:self.spinner];
    
    [super layoutSubviews];
}


+ (void)show {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    UIWindow* window;
    for (UIWindow* win in [[UIApplication sharedApplication] windows]) {
        if ([win isKindOfClass:[BRKWindow class]]) {
            window = win;
            break;
        }
    }
    BRKLoadingView* loadingView;

    for (id object in window.subviews) {
        if ([object isKindOfClass:[BRKLoadingView class]]) {
            loadingView = (BRKLoadingView*)object;
            break;
        }
    }

    if (loadingView) {
        [window bringSubviewToFront:loadingView];
    }
    else {
        loadingView = [[BRKLoadingView alloc] initWithFrame:CGRectMake(80, 80, 80, 80)];
        loadingView.center = CGPointMake(CGRectGetMidX(window.bounds), CGRectGetMidY(window.bounds));

        [window addSubview:loadingView];
    }
}

+ (void)dismiss {
    UIWindow* window;
    for (UIWindow* win in [[UIApplication sharedApplication] windows]) {
        if ([win isKindOfClass:[BRKWindow class]]) {
            window = win;
            break;
        }
    }

    for (id object in window.subviews) {
        if ([object isKindOfClass:[BRKLoadingView class]]) {
            [(BRKLoadingView*)object removeFromSuperview];
        }
    }
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
}

@end
