//
//  DKPaymentCC.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKPaymentCC.h"

@implementation DKPaymentCC

-(NSString*)validValueClean
{
    NSArray *dates = [self.validValue componentsSeparatedByString:@"/"];
    
    return [NSString stringWithFormat:@"%@%@", dates[1], dates[0]];
}

-(NSString*)cardNumberClean
{
    return [self.cardNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

@end
