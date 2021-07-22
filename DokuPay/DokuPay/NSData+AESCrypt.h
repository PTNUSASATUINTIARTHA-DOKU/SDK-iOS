//
//  NSData+AESCrypt.h
//  DokuPay
//
//  Created by IHsan HUsnul on 5/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData_AESCrypt : NSData

- (NSData *)AES256EncryptWithKey:(NSString *)key;
- (NSData *)AES256DecryptWithKey:(NSString *)key;

+ (NSData *)dataWithBase64EncodedString:(NSString *)string;
- (id)initWithBase64EncodedString:(NSString *)string;

- (NSString *)base64Encoding;
- (NSString *)base64EncodingWithLineLength:(NSUInteger)lineLength;

- (BOOL)hasPrefixBytes:(const void *)prefix length:(NSUInteger)length;
- (BOOL)hasSuffixBytes:(const void *)suffix length:(NSUInteger)length;

@end
