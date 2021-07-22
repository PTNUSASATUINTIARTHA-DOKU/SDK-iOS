//
//  DKUserDetail.m
//  DokuPay
//
//  Created by IHsan HUsnul on 6/20/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKUserDetail.h"
#import "DKUtils.h"
#import "DokuPay.h"

@implementation DKUserDetail

-(id)initWithString:(NSString *)jsonString
{
    self = [super init];
    if (self) {
        if (jsonString.length > 0)
        {
            NSDictionary *dict = [DKUtils jsonStringToDictionary:jsonString];
            
            self.responseCode = [dict objectForKey:@"responseCode"];
            self.responseMsg  = [dict objectForKey:@"responseMsg"];
            self.dpMallID = [dict objectForKey:@"dpMallId"];
            self.transIDMerchant = [dict objectForKey:@"transIdMerchant"];
            self.dokuID = [dict objectForKey:@"dokuId"];
            self.customerName = [dict objectForKey:@"customerName"];
            self.customerEmail = [dict objectForKey:@"customerEmail"];
            self.paymentChannel = DokuPaymentChannelTypeWallet;
            self.inquiryCode = [dict objectForKey:@"inquiryCode"];
            self.listPromotion = [dict objectForKey:@"listPromotion"];
            self.avatar = [dict objectForKey:@"avatar"];
            self.listPaymentChannel = [dict objectForKey:@"listPaymentChannel"];
        }
    }
    
    return  self;
}

-(NSArray*)titleListPromotion
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.listPromotion.count];
    for (NSDictionary *dict in self.listPromotion) {
        [array addObject:[NSString stringWithFormat:@"%@(%@)", [dict objectForKey:@"name"], [dict objectForKey:@"amount"]]];
    }
    return array;
}

@end
