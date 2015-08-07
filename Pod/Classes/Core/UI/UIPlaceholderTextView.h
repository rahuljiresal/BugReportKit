//
//  UIPlaceholderTextView.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-03.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceholderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
