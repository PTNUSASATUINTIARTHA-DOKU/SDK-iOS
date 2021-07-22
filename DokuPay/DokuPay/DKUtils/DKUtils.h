//
//  DKUtils.h
//  DokuPay
//
//  Created by IHsan HUsnul on 5/4/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DKPaymentCC.h"
#import "DKPaymentItem.h"
#import "DKUserDetail.h"

@interface DKUtils : NSObject

+(NSMutableDictionary*)dictionaryPaymentItem;

+(NSMutableDictionary*)createRequestTokenWallet:(NSString*)doku_id pPassword:(NSString*)password;

+(NSDictionary*)createRequestCCWallet:(NSDictionary*)dict withWalletChannel:(NSDictionary*)walletChannel pCVV:(NSString*)cvv;

+(NSMutableDictionary*)createRequestTokenCC:(DKPaymentCC*)paymentCC;

+(NSMutableDictionary*)createRequestCashWallet:(NSDictionary*)dict withPIN:(NSString*)pin withVoucher:(NSString*)voucherID;

+(NSMutableDictionary*)createRequest3D:(NSDictionary*)dict;

+(BOOL)isEmail:(NSString*)email;

+(NSDictionary*)jsonStringToDictionary:(NSString*)jsonString;

+(NSString*)stringFromDictionary:(NSDictionary*)dict;

+(NSMutableDictionary*)createResponseCashWallet:(NSDictionary*)dict withWalletChannel:(NSDictionary*)walletChannel;

+(NSString *)getRandomNumber:(NSInteger)length;

+(NSMutableDictionary*)cardInquirySecond;

+(NSMutableDictionary*)checkMerchantStatus;

+(NSMutableDictionary*)createResponseCCReguler:(NSDictionary*)dict;

+(NSMutableDictionary*)createRegisterCCWallet:(DKPaymentCC*)paymentCC withUserDetail:(DKUserDetail*)userDetail withConResult:(NSDictionary*)conResult withWalletChannel:(NSDictionary*)walletChannel;

@end