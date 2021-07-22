//
//  DKUtils.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/4/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKUtils.h"
#import "DKPaymentItem.h"
#import "DokuPay.h"
#import "DKSecure.h"

@implementation DKUtils

-(NSDictionary*)createClientResponse:(NSError*)error
{
    return @{@"res_response_code": [error localizedDescription], @"res_response_msg": [NSString stringWithFormat:@"%ld",(long)error.code]};
}

-(NSDictionary*)createErrorResponse:(NSDictionary*)dict
{
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    [mutableDict setObject:[dict objectForKey:@""] forKey:@"errorCode"];
    [mutableDict setObject:[dict objectForKey:@""] forKey:@"errorMessage"];
    
    return @{@"responseMessage": mutableDict};
}

+(NSMutableDictionary*)createRequestTokenWallet:(NSString*)doku_id pPassword:(NSString*)password
{
    NSMutableDictionary *mutable = [DKUtils dictionaryPaymentItem];
    
    [mutable setObject:[DKSecure encrypt:doku_id] forKey:@"req_doku_id"];
    [mutable setObject:[DKSecure encrypt:password] forKey:@"req_doku_pass"];
    [mutable setObject:DokuPaymentChannelTypeWallet forKey:@"req_payment_channel"];
    
    return mutable;
}

+(NSMutableDictionary*)createRequestTokenCC:(DKPaymentCC*)paymentCC
{
    NSMutableDictionary *mutableDict = [DKUtils dictionaryPaymentItem];
    
    [mutableDict setValue:DokuPaymentChannelTypeCC forKey:@"req_payment_channel"];
    
    if (paymentCC.validValue.length == 5) {
        NSString *dateSecure = [DKSecure encrypt:[paymentCC validValueClean]];
        [mutableDict setValue:dateSecure forKey:@"req_date"];
    }
    
    if (paymentCC.cardNumber.length >= 16) {
        NSString *numberSecure = [DKSecure encrypt:[paymentCC cardNumberClean]];
        [mutableDict setValue:numberSecure forKey:@"req_number"];
    }
    
    NSString *cvvSecure = [DKSecure encrypt:paymentCC.cvv];
    [mutableDict setValue:cvvSecure forKey:@"req_secret"];
    
    [mutableDict setValue:paymentCC.cardHolder forKey:@"req_name"];
    [mutableDict setValue:paymentCC.email forKey:@"req_email"];
    [mutableDict setValue:paymentCC.phoneNumber forKey:@"req_mobile_phone"];
    
    
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    if (paymentItem.customerID && paymentItem.customerID.length > 0) {
        [mutableDict setValue:paymentItem.customerID forKey:@"req_save_customer"];
    }
    
    if (paymentItem.tokenPayment && paymentItem.tokenPayment.length > 0) {
        [mutableDict setValue:paymentItem.tokenPayment forKey:@"req_token_payment"];
    }

    return mutableDict;
}

+(NSMutableDictionary*)createRequestCashWallet:(NSDictionary*)dict withPIN:(NSString*)pin withVoucher:(NSString*)voucherID
{
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    [mutableDict setObject:[dict objectForKey:@"res_token_id"] forKey:@"req_token_id"];
    [mutableDict setObject:[dict objectForKey:@"res_pairing_code"] forKey:@"req_pairing_code"];
    [mutableDict setObject:paymentItem.dataWords forKey:@"req_words"];
    
    NSDictionary *resDataDw = [DKUtils jsonStringToDictionary:[dict objectForKey:@"res_data_dw"]];
    
    NSMutableDictionary *dokuwallet = [@{@"req_channel_code": @"01",
                                 @"req_customer_pin": [DKSecure encrypt:pin],
                                 @"req_inquiry_code": [resDataDw objectForKey:@"inquiryCode"],
                                 @"req_customer_name": [resDataDw objectForKey:@"customerName"],
                                 @"req_customer_email": [DKSecure encrypt:[resDataDw objectForKey:@"customerEmail"]],
                                 @"req_doku_id": [DKSecure encrypt:[resDataDw objectForKey:@"dokuId"]]
                                 } mutableCopy];
    if (voucherID && voucherID.length > 0)
        [dokuwallet setObject:voucherID forKey:@"req_promotion_id"];
    
    [mutableDict setObject:[DKUtils stringFromDictionary:dokuwallet] forKey:@"req_dokuwallet"];
     
    return mutableDict;
}

+(NSMutableDictionary*)createResponseCashWallet:(NSDictionary*)dict withWalletChannel:(NSDictionary*)walletChannel
{
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    [mutableDict setObject:[dict objectForKey:@"res_token_id"] forKey:@"res_token_id"];
    [mutableDict setObject:[dict objectForKey:@"res_pairing_code"] forKey:@"res_pairing_code"];
    [mutableDict setObject:[dict objectForKey:@"res_response_msg"] forKey:@"res_response_msg"];
    [mutableDict setObject:[dict objectForKey:@"res_response_code"] forKey:@"res_response_code"];
    [mutableDict setObject:[dict objectForKey:@"res_device_id"] forKey:@"res_device_id"];
    [mutableDict setObject:[dict objectForKey:@"res_amount"] forKey:@"res_amount"];
    [mutableDict setObject:[dict objectForKey:@"res_token_code"] forKey:@"res_token_code"];
    [mutableDict setObject:[dict objectForKey:@"res_transaction_id"] forKey:@"res_transaction_id"];
    [mutableDict setObject:[dict objectForKey:@"res_payment_channel"] forKey:@"res_payment_channel"];
    
    NSDictionary *dataDw = [DKUtils jsonStringToDictionary:[dict objectForKey:@"res_data_dw"]];
    [mutableDict setObject:[dataDw objectForKey:@"customerName"] forKey:@"res_name"];
    [mutableDict setObject:[dataDw objectForKey:@"customerEmail"] forKey:@"res_data_email"];
    [mutableDict setObject:paymentItem.mobilePhone forKey:@"res_data_mobile_phone"];
    
    return mutableDict;
}

+(NSMutableDictionary*)createRequest3D:(NSDictionary*)dict
{
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    [mutableDict setObject:[dict objectForKey:@"res_token_id"] forKey:@"req_token_id"];
    [mutableDict setObject:[dict objectForKey:@"res_pairing_code"] forKey:@"req_pairing_code"];
    [mutableDict setObject:paymentItem.dataWords forKey:@"req_words"];
    
    return mutableDict;
}

+(NSMutableDictionary*)createResponseCCReguler:(NSDictionary*)dict
{   
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    [mutableDict setObject:[dict objectForKey:@"res_token_id"] forKey:@"res_token_id"];
    [mutableDict setObject:[dict objectForKey:@"res_pairing_code"] forKey:@"res_pairing_code"];
    [mutableDict setObject:[dict objectForKey:@"res_response_msg"] forKey:@"res_response_msg"];
    [mutableDict setObject:[dict objectForKey:@"res_response_code"] forKey:@"res_response_code"];
    [mutableDict setObject:[dict objectForKey:@"res_device_id"] forKey:@"res_device_id"];
    [mutableDict setObject:[dict objectForKey:@"res_amount"] forKey:@"res_amount"];
    [mutableDict setObject:[dict objectForKey:@"res_token_code"] forKey:@"res_token_code"];
    [mutableDict setObject:[dict objectForKey:@"res_transaction_id"] forKey:@"res_transaction_id"];
    [mutableDict setObject:[dict objectForKey:@"res_payment_channel"] forKey:@"res_payment_channel"];
    
    if (dict[@"res_data_email"]) {
        [mutableDict setObject:dict[@"res_data_email"] forKey:@"res_data_email"];
    }
    
    if (dict[@"res_data_mobile_phone"]) {
        [mutableDict setObject:[dict objectForKey:@"res_data_mobile_phone"] forKey:@"res_data_mobile_phone"];
    }
    
    return mutableDict;
}


+(NSDictionary*)createRequestCCWallet:(NSDictionary*)dict withWalletChannel:(NSDictionary*)walletChannel pCVV:(NSString*)cvv
{
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    NSMutableDictionary *mutableDwDict = [[NSMutableDictionary alloc] init];
    NSDictionary *dataDw = [DKUtils jsonStringToDictionary:[dict objectForKey:@"res_data_dw"]];

    [mutableDwDict setObject:[dataDw objectForKey:@"inquiryCode"] forKey:@"req_inquiry_code"];
    [mutableDwDict setObject:[DKSecure encrypt:[dataDw objectForKey:@"dokuId"]] forKey:@"req_doku_id"];
    NSDictionary *detail = [walletChannel objectForKey:@"details"][0];
    [mutableDwDict setObject:[detail valueForKey:@"linkId"] forKey:@"req_link_id"];
    [mutableDwDict setObject:[detail valueForKey:@"cardNoEncrypt"] forKey:@"req_number"];
    [mutableDwDict setObject:[detail valueForKey:@"cardExpiryDateEncrypt"] forKey:@"req_date"];
    [mutableDwDict setObject:[DKSecure encrypt:cvv] forKey:@"req_cvv"];
    [mutableDwDict setObject:[DKSecure encrypt:[dataDw objectForKey:@"customerEmail"]] forKey:@"req_customer_email"];
    [mutableDwDict setObject:[dataDw objectForKey:@"customerName"] forKey:@"req_customer_name"];
    [mutableDwDict setObject:[walletChannel objectForKey:@"channelCode"] forKey:@"req_channel_code"];


    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    [mutableDict setObject:[dict objectForKey:@"res_token_id"] forKey:@"req_token_id"];
    [mutableDict setObject:[dict objectForKey:@"res_pairing_code"] forKey:@"req_pairing_code"];
    [mutableDict setObject:paymentItem.dataWords forKey:@"req_words"];
    [mutableDict setObject:mutableDwDict forKey:@"req_dokuwallet"];

    return mutableDict;
}


+(NSMutableDictionary*)createRegisterCCWallet:(DKPaymentCC*)paymentCC withUserDetail:(DKUserDetail*)userDetail withConResult:(NSDictionary*)conResult withWalletChannel:(NSDictionary*)walletChannel
{
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    NSMutableDictionary *dokuWallet = [[NSMutableDictionary alloc] init];
    [dokuWallet setObject:[DKSecure encrypt:userDetail.dokuID] forKey:@"req_doku_id"];
    [dokuWallet setObject:[DKSecure encrypt:paymentCC.email] forKey:@"CC_EMAIL"];
    [dokuWallet setObject:[DKSecure encrypt:[paymentCC validValueClean]] forKey:@"CC_EXPIRYDATE"];
    [dokuWallet setObject:paymentCC.cardHolder forKey:@"CC_NAME"];
    [dokuWallet setObject:userDetail.inquiryCode forKey:@"req_inquiry_code"];
    [dokuWallet setObject:[DKSecure encrypt:[paymentCC cardNumberClean]] forKey:@"CC_CARDNUMBER"];
    [dokuWallet setObject:paymentCC.phoneNumber forKey:@"CC_MOBILEPHONE"];
    [dokuWallet setObject:[DKSecure encrypt:paymentCC.cvv] forKey:@"CC_CVV"];
    [dokuWallet setObject:[walletChannel objectForKey:@"channelCode"] forKey:@"req_channel_code"];

    [mutableDict setObject:dokuWallet forKey:@"req_dokuwallet"];

    return mutableDict;
}

+(NSMutableDictionary*)dictionaryPaymentItem
{
    NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] init];
    
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    [mutableDict setObject:paymentItem.dataMerchantCode forKey:@"req_merchant_code"];
    [mutableDict setObject:paymentItem.dataTransactionID forKey:@"req_transaction_id"];
//    [mutableDict setValue:[[DokuPay sharedInstance] paymentChannel] forKey:@"req_payment_channel"];
    [mutableDict setObject:paymentItem.dataAmount forKey:@"req_amount"];
    [mutableDict setObject:paymentItem.dataCurrency forKey:@"req_currency"];
    [mutableDict setObject:paymentItem.dataMerchantChain forKey:@"req_chain_merchant"];
    [mutableDict setValue:@"M" forKey:@"req_access_type"];
    [mutableDict setObject:[paymentItem dataBasketEscape] forKey:@"req_basket"];
    [mutableDict setObject:paymentItem.dataWords forKey:@"req_words"];
    [mutableDict setObject:paymentItem.dataSessionID forKey:@"req_session_id"];
    [mutableDict setObject:paymentItem.dataImei forKey:@"req_device_id"];
    
    return mutableDict;
}

+(NSMutableDictionary*)cardInquirySecond
{
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    NSMutableDictionary *mutable = [[NSMutableDictionary alloc] init];
    
    [mutable setObject:paymentItem.dataAmount forKey:@"req_amount"];
    [mutable setObject:paymentItem.dataCurrency forKey:@"req_currency"];
    [mutable setObject:paymentItem.dataImei forKey:@"req_device_id"];
    [mutable setObject:paymentItem.dataTransactionID forKey:@"req_transaction_id"];
    [mutable setObject:paymentItem.dataMerchantCode forKey:@"req_merchant_code"];
    [mutable setObject:paymentItem.dataMerchantChain forKey:@"req_chain_merchant"];
    [mutable setObject:DokuPaymentChannelTypeCC forKey:@"req_payment_channel"];
    
    if (paymentItem.customerID && paymentItem.customerID.length > 0) {
        [mutable setObject:[DKSecure encrypt:paymentItem.customerID] forKey:@"req_customer_id"];
    }
    
    [mutable setObject:paymentItem.dataWords forKey:@"req_words"];
    [mutable setObject:[DKSecure encrypt:paymentItem.tokenPayment] forKey:@"req_token_payment"];
    
    return mutable;
}

+(NSMutableDictionary*)checkMerchantStatus
{
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    
    NSMutableDictionary *mutable = [[NSMutableDictionary alloc] init];
    
    [mutable setObject:paymentItem.dataAmount forKey:@"req_amount"];
    [mutable setObject:paymentItem.dataCurrency forKey:@"req_currency"];
    [mutable setObject:paymentItem.dataImei forKey:@"req_device_id"];
    [mutable setObject:paymentItem.dataTransactionID forKey:@"req_transaction_id"];
    [mutable setObject:paymentItem.dataMerchantCode forKey:@"req_merchant_code"];
    [mutable setObject:paymentItem.dataMerchantChain forKey:@"req_chain_merchant"];
    [mutable setObject:DokuPaymentChannelTypeCC forKey:@"req_payment_channel"];
    [mutable setObject:paymentItem.dataWords forKey:@"req_words"];
    
    if (paymentItem.customerID && paymentItem.customerID.length > 0) {
        [mutable setObject:[DKSecure encrypt:paymentItem.customerID] forKey:@"req_customer_id"];
    }

    return mutable;
}

//-(NSString*)EYDNumberFormat:(NSString*)string
//{
//    BigDecimal newtext = new BigDecimal(amount);
//    DecimalFormatSymbols otherSymbols = new DecimalFormatSymbols(Locale.US);
//    otherSymbols.setDecimalSeparator(',');
//    otherSymbols.setGroupingSeparator('.');
//    DecimalFormat df = new DecimalFormat("#,###,###.##", otherSymbols);
//    return df.format(newtext);
//}

+(BOOL)isEmail:(NSString*)email
{
    NSString *emailRegex = @"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    return isValid;
}
                       
+(NSDictionary*)jsonStringToDictionary:(NSString*)jsonString
{
   NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
   NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                               options:NSJSONReadingMutableContainers
                                                 error:nil];
    return dict;
}

+(NSString*)stringFromDictionary:(NSDictionary*)dict
{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+(NSString *)getRandomNumber:(NSInteger)length
{
    NSMutableString *returnString = [NSMutableString stringWithCapacity:length];
    
    NSString *numbers = @"0123456789";
    
    // First number cannot be 0
    [returnString appendFormat:@"%C", [numbers characterAtIndex:(arc4random() % ([numbers length]-1))+1]];
    
    for (int i = 1; i < length; i++)
    {
        [returnString appendFormat:@"%C", [numbers characterAtIndex:arc4random() % [numbers length]]];
    }
    
    return returnString;
}

@end

