//
//  BRKViewController.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-03.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//
//

#import "BRKViewController.h"
#import "BRKDrawView.h"
#import "UIPlaceholderTextView.h"
#import "BRKLoadingView.h"

#define TOOLBAR_HEIGHT 44.0f
#define COLORPICKER_RADIUS 32.0f
#define TEXTVIEW_MARGIN 20.0f

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

@interface BRKViewController ()

@property (strong, nonatomic) UIScrollView* scrollView;
@property (strong, nonatomic) UIToolbar* bottomToolbar;
@property (strong, nonatomic) UIToolbar* topToolbar;
@property (strong, nonatomic) UIBarButtonItem* colorPickerButton;
@property (strong, nonatomic) UIButton* colorPickerButtonView;
@property (strong, nonatomic) UIBarButtonItem* nextButton;
@property (strong, nonatomic) UIBarButtonItem* cancelButton;
@property (strong, nonatomic) UIPlaceholderTextView* textView;

@property (strong, nonatomic) UIImage* screenshot;
@property (strong, nonatomic) NSString* metaInfo;

@property (strong, nonatomic) BRKDrawView* imageview;
@property (strong, nonatomic) NSDictionary* colorsDictionary;

@property NSUInteger currentPage;

@end

@implementation BRKViewController

- (id)initWithScreenshot:(UIImage *)screenshot metaInfo:(NSString*)meta {
    self = [self init];
    if (self) {
        self.screenshot = screenshot;
        self.metaInfo = meta;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    
    self.colorsDictionary = @{
                              @"Black"  :   [UIColor blackColor],
                              @"Red"    :   [UIColor redColor],
                              @"Green"  :   [UIColor greenColor],
                              @"Blue"   :   [UIColor blueColor],
                              @"White"  :   [UIColor whiteColor]
                              };
    
    
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return false;
}

- (void)setupSubviews {
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];

    self.topToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0]];
    [label setText:@"BugReportKit"];
    UIBarButtonItem* nameItem = [[UIBarButtonItem alloc] initWithCustomView:label];
    [self.topToolbar setItems:[NSArray arrayWithObjects:spacer, nameItem, spacer, nil]];
    [self.view addSubview:self.topToolbar];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, TOOLBAR_HEIGHT, self.view.frame.size.width, self.view.frame.size.height - TOOLBAR_HEIGHT * 2)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    self.bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", nil) style:UIBarButtonItemStylePlain target:self action:@selector(cancelled:)];
    
    self.colorPickerButtonView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, COLORPICKER_RADIUS, COLORPICKER_RADIUS)];
    self.colorPickerButtonView.layer.cornerRadius = COLORPICKER_RADIUS / 2;
    self.colorPickerButtonView.layer.borderWidth = 1.0;
    self.colorPickerButtonView.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.colorPickerButtonView setBackgroundColor:[UIColor redColor]];
    self.colorPickerButton = [[UIBarButtonItem alloc] initWithCustomView:self.colorPickerButtonView];
    [self.colorPickerButtonView addTarget:self action:@selector(pickColor:) forControlEvents:UIControlEventTouchUpInside];

    self.nextButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", nil) style:UIBarButtonItemStylePlain target:self action:@selector(nextButtonPressed:)];
    [self.bottomToolbar setItems:[NSArray arrayWithObjects:self.cancelButton, spacer, self.colorPickerButton, spacer, self.nextButton, nil] animated:YES];
    
    self.imageview = [[BRKDrawView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - TOOLBAR_HEIGHT * 2)];
    [self.imageview setStrokeColor:[UIColor redColor]];
    [self.imageview setContentMode:UIViewContentModeScaleAspectFit];
    [self.imageview setImage:self.screenshot];
    
    self.textView = [[UIPlaceholderTextView alloc] initWithFrame:CGRectMake(self.view.frame.size.width + TEXTVIEW_MARGIN, TEXTVIEW_MARGIN, self.view.frame.size.width - TEXTVIEW_MARGIN * 2, self.scrollView.frame.size.height - TOOLBAR_HEIGHT - TEXTVIEW_MARGIN)];
    [self.textView setPlaceholder:NSLocalizedString(@"Please enter description of the bug report or feedback here. Make sure it explains what you were doing.", nil)];
    [self.textView setPlaceholderColor:[UIColor lightGrayColor]];
    [self.textView setFont:[UIFont systemFontOfSize:18.0]];
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 2, self.view.frame.size.height - TOOLBAR_HEIGHT)];

    [self.scrollView addSubview:self.imageview];
    [self.scrollView addSubview:self.textView];
    
    [self.view addSubview:self.bottomToolbar];
    [self.view addSubview:self.scrollView];
    
    [self.view bringSubviewToFront:self.bottomToolbar];
    
    self.currentPage = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

}

- (void)keyboardDidShow: (NSNotification *) notification{
    CGFloat keyboardHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    if (self.currentPage == 1) {
        CGRect textviewFrame = self.textView.frame;
        textviewFrame.size.height = self.scrollView.frame.size.height - TOOLBAR_HEIGHT - TEXTVIEW_MARGIN - keyboardHeight;
        [self.textView setFrame:textviewFrame];
       [self.bottomToolbar setFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT - keyboardHeight, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    }
}

- (void)keyboardDidHide: (NSNotification *) notification{
    [self.textView setFrame:CGRectMake(self.view.frame.size.width + TEXTVIEW_MARGIN, TEXTVIEW_MARGIN, self.view.frame.size.width - TEXTVIEW_MARGIN * 2, self.scrollView.frame.size.height - TOOLBAR_HEIGHT - TEXTVIEW_MARGIN)];
    [self.bottomToolbar setFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pickColor:(id)sender {
    NSArray *colorNames = [self.colorsDictionary allKeys];
    
    UIAlertController * controller = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Pick Color", nil) preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString* colorName in colorNames) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(colorName, nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIColor* color = [self.colorsDictionary objectForKey:colorName];
            [self.imageview setStrokeColor:color];
            [self.colorPickerButtonView setBackgroundColor:color];
        }];
        [controller addAction:action];
    }
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    [controller addAction:cancel];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)cancelled:(id)sender {
    if (self.currentPage == 0) {
        if ([self.parentWindow.brkWindowDelegate respondsToSelector:@selector(bugReportCancelled)]) {
            [self.parentWindow.brkWindowDelegate bugReportCancelled];
        }
    }
    else if (self.currentPage == 1) {
        [self.textView resignFirstResponder];
        CGPoint contentOffset = CGPointMake(0, self.scrollView.contentOffset.y);
        [self.scrollView setContentOffset:contentOffset animated:YES];
        [self.colorPickerButtonView setHidden:NO];
        [self.colorPickerButtonView setEnabled:YES];
        [self.nextButton setTitle:NSLocalizedString(@"Next", nil)];
        [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
        self.currentPage = 0;
    }
}

- (void)nextButtonPressed:(id)sender {
    if (self.currentPage == 0) {
        CGPoint contentOffset = CGPointMake(self.view.frame.size.width * 1, self.scrollView.contentOffset.y);
        [self.scrollView setContentOffset:contentOffset animated:YES];
        [self.nextButton setTitle:NSLocalizedString(@"Submit", nil)];
        [self.cancelButton setTitle:NSLocalizedString(@"Back", nil)];
        [self.colorPickerButtonView setHidden:YES];
        [self.colorPickerButtonView setEnabled:NO];
        self.currentPage = 1;
        [self.textView becomeFirstResponder];
    }
    else if (self.currentPage == 1) {
        if (self.textView.text.length == 0) {
            [self showAlertWithTitle:NSLocalizedString(@"Description",nil) message:NSLocalizedString(@"Please enter a description for the bug report.", nil) handler:nil];
            return;
        }
        [self.textView resignFirstResponder];
        if ([self.parentWindow.brkReporterDelegate respondsToSelector:@selector(sendBugReportWithImage:text:completionHandler:)]) {
            [BRKLoadingView show];
            [self.parentWindow.brkReporterDelegate sendBugReportWithImage:self.imageview.image text:[self.textView.text stringByAppendingString:self.metaInfo] completionHandler:^(NSError *error) {
                [BRKLoadingView dismiss];
                if (error) {
                    [self showAlertWithTitle:NSLocalizedString(@"Error", nil) message:error.localizedDescription handler:^(UIAlertAction *action) {
                        if ([self.parentWindow.brkWindowDelegate respondsToSelector:@selector(bugReportFailedToSend)]) {
                            [self.parentWindow.brkWindowDelegate bugReportFailedToSend];
                        }
                    }];
                }
                else {
                    if ([self.parentWindow.brkWindowDelegate respondsToSelector:@selector(bugReportSent)]) {
                        [self.parentWindow.brkWindowDelegate bugReportSent];
                    }
                }
            }];
        }
    }
}
             
 - (void)showAlertWithTitle:(NSString*)title message:(NSString*)message handler:(void(^)(UIAlertAction*))handler{
     
     if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
         dispatch_async(dispatch_get_main_queue(), ^{
             UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
             
             UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:handler];
             
             [alert addAction:defaultAction];
             [self presentViewController:alert animated:YES completion:nil];
         });
     }
     else {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
         [alert show];
     }
 }

@end
