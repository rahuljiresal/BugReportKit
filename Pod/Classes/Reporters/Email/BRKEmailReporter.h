//
//  BRKEmailReporter.h
//  Pods
//
//  Created by Rahul Jiresal on 2015-08-04.
//  Copyright (c) 2015 Rahul Jiresal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSInteger, BRKEmailReporterConnectionType) {
    /** Clear-text connection for the protocol.*/
    BRKEmailConnectionTypeClear             = 1 << 0,
    /** Clear-text connection at the beginning, then switch to encrypted connection using TLS/SSL*/
    /** on the same TCP connection.*/
    BRKEmailConnectionTypeStartTLS          = 1 << 1,
    /** Encrypted connection using TLS/SSL.*/
    BRKEmailConnectionTypeTLS               = 1 << 2,
};


@interface BRKEmailReporter : NSObject


- (id)initWithHostname:(NSString*)hostname
                  port:(NSUInteger)port
              username:(NSString*)username
              password:(NSString*)password
        connectionType:(BRKEmailReporterConnectionType)type
             toAddress:(NSString*)to;

@end
