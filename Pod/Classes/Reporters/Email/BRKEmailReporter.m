//
//  BRKEmailReporter.m
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import "BRKEmailReporter.h"
#import "BugReportKit.h"

#import <MailCore/MCOMessageBuilder.h>
#import <MailCore/MCOMessageHeader.h>
#import <MailCore/MCOAddress.h>
#import <MailCore/MCOSMTP.h>
#import <MailCore/MCOAttachment.h>

@interface BRKEmailReporter() <BRKReporterDelegate>

@property MCOSMTPSession* smtpSession;
@property NSString* username;
@property NSString* toAddress;

@end

@implementation BRKEmailReporter

- (id)initWithHostname:(NSString*)hostname
                  port:(NSUInteger)port
              username:(NSString*)username
              password:(NSString*)password
        connectionType:(BRKEmailReporterConnectionType)type
             toAddress:(NSString*)to {
    self = [self init];
    if (self) {
        self.smtpSession = [[MCOSMTPSession alloc] init];
        self.smtpSession.hostname = hostname;
        self.smtpSession.port = port;
        self.smtpSession.username = username;
        self.smtpSession.password = password;
        self.smtpSession.connectionType = [self mcoConnectionTypeFromBRKEmailReporterConnectionType:type];
        
        self.username = username;
        self.toAddress = to;
    }
    return self;
}

- (MCOConnectionType)mcoConnectionTypeFromBRKEmailReporterConnectionType:(BRKEmailReporterConnectionType)type {
    switch (type) {
        case BRKEmailConnectionTypeClear:
            return MCOConnectionTypeClear;
            break;
            
            case BRKEmailConnectionTypeStartTLS:
            return MCOConnectionTypeStartTLS;
            
        case BRKEmailConnectionTypeTLS:
            return MCOConnectionTypeTLS;
            
        default:
            return MCOConnectionTypeClear;
            break;
    }
}

- (void)sendBugReportWithImage:(UIImage*)image text:(NSString *)text completionHandler:(void (^)(NSError *, NSString *url))handler {
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:@"BugReportKit" mailbox:self.username]];
    NSMutableArray *to = [[NSMutableArray alloc] init];
    
    MCOAddress *newAddress = [MCOAddress addressWithMailbox:self.toAddress];
    [to addObject:newAddress];
    [[builder header] setTo:to];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *appDisplayName = [infoDictionary objectForKey:@"CFBundleDisplayName"];


    [[builder header] setSubject:[NSString stringWithFormat:@"BugReportKit: %@ v%@ (%@)", appDisplayName, majorVersion, minorVersion]];
    NSString* body = [NSString stringWithFormat:@"The bug report included the following text:\n\n=======================\n\n%@", text];
    [builder setTextBody:body];

    MCOAttachment *attachment = [MCOAttachment attachmentWithData:UIImagePNGRepresentation(image) filename:@"bugreport.png"];
    [builder setAttachments:[NSArray arrayWithObject:attachment]];
    
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation = [self.smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
        if(error) {
            handler(error, nil);
        } else {
            handler(nil, nil);
        }
    }];
    
}

@end
