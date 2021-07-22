//
//  DKSecure.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKSecure.h"
#import <CommonCrypto/CommonCrypto.h>
#import "RSAEncryptor.h"
#import "DKPaymentItem.h"
#import "DokuPay.h"

@implementation DKStringUtils
-(NSString*)stringFromBytes:(uint8_t *)bytes length:(int)length
{
    NSMutableString *strM = [NSMutableString string];
    
    for (int i = 0; i < length; i++) {
        [strM appendFormat:@"%02x", bytes[i]];
    }
    
    return [strM copy];
}
@end

@implementation DKSecure

-(NSString*)sha1String:(NSString*)string
{
    DKStringUtils *dkString = (DKStringUtils*)string;
    const char *str = dkString.UTF8String;
    uint8_t buffer[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(str, (CC_LONG)strlen(str), buffer);
    
    return [dkString stringFromBytes:buffer length:CC_SHA1_DIGEST_LENGTH];
}

-(NSString*)convertToHex:(NSData*)data
{
    const unsigned char *dataBuffer = (const unsigned char *)[data bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger dataLength = [data length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    
    return [NSString stringWithString:hexString];
}

+(NSString*)encrypt:(NSString*)plainText
{
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    NSString *resString = [RSAEncryptor encryptString:plainText publicKey:paymentItem.publicKey];

    return resString;
}

@end
