//
//  DKPaymentItem.m
//  DokuPay
//
//  Created by IHsan HUsnul on 4/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <UIKit/UIKit.h>
#import "DKPaymentItem.h"
#import "DKUIHelper.h"
#import "RSAEncryptor.h"

@implementation DKPaymentItem

-(NSString*)dataBasketEscape
{
    NSMutableString *string = [[NSMutableString alloc] init];
    for (int i=0; i<self.dataBasket.count; i++)
    {
        NSDictionary *dict = self.dataBasket[i];
        [string appendString:[NSString stringWithFormat:@"{\\\"name\\\":\\\"%@\\\", \\\"amount\\\":\\\"%@\\\", \\\"quantity\\\":\\\"%@\\\", \\\"subtotal\\\":\\\"%@\\\"}",
         [dict objectForKey:@"name"], [dict objectForKey:@"amount"], [dict objectForKey:@"quantity"], [dict objectForKey:@"subtotal"]]];
        
        if (i < self.dataBasket.count-1)
            [string appendString:@","];
    }

    return [NSString stringWithFormat:@"[%@]", string];
}


-(NSString*)generateWords
{   
    NSString *combine = [NSString stringWithFormat:@"%@%@%@%@%@%@", self.dataAmount, self.dataMerchantCode, self.sharedKey, self.dataTransactionID, self.dataCurrency, self.dataImei];
    
    NSString *result = [DKPaymentItem sha1:combine];
    
    return result;
}

+(NSString *)sha1:(NSString*)string
{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
