//
//  BRKDrawView.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@interface BRKDrawView : UIView

@property (nonatomic, retain) UIColor *strokeColor;

- (UIImage *)image;
- (void)setImage:(UIImage*)image;

@end
