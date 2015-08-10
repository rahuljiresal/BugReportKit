//
//  BRKViewController.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-03.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//
//

#import <UIKit/UIKit.h>
#import "BRKWindow.h"

@interface BRKViewController : UIViewController

@property (strong, nonatomic) BRKWindow* parentWindow;

- (id)initWithScreenshot:(UIImage*)screenshot metaInfo:(NSString*)meta;

@end
