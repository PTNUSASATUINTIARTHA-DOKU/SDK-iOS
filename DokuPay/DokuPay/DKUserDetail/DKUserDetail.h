//
//  DKUserDetail.h
//  DokuPay
//
//  Created by IHsan HUsnul on 6/20/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DKUserDetail : NSObject

@property (nonatomic, strong) NSString *responseCode;
@property (nonatomic, strong) NSString *responseMsg;
@property (nonatomic, strong) NSString *dpMallID;
@property (nonatomic, strong) NSString *transIDMerchant;
@property (nonatomic, strong) NSString *dokuID;
@property (nonatomic, strong) NSString *customerName;
@property (nonatomic, strong) NSString *customerEmail;
@property (nonatomic, strong) NSString *customerPhone;
@property (nonatomic, strong) NSString *paymentChannel;
@property (nonatomic, strong) NSString *inquiryCode;
@property (nonatomic, strong) NSArray *listPromotion;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, strong) NSArray *listPaymentChannel;


-(id)initWithString:(NSString*)jsonString;
-(NSArray *)titleListPromotion;

@end
