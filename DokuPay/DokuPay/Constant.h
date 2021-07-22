//
//  Constant.h
//  DokuPay
//
//  Created by IHsan HUsnul on 4/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

//#define ConfigUrl @"http://luna2.nsiapay.com"
#define ConfigUrl @"https://staging.doku.com"
#define ConfigUrlProduction @"https://pay.doku.com"

#define URL_getToken @"/api/payment/getToken"
#define URL_Check3DStatus @"/api/payment/doCheck3DStatus"
#define URL_RequestVACode @"http://demomerchant.doku.com/va_generate.php"
#define URL_prePayment @"/api/payment/PrePayment"
#define URL_doCheckStatusToken @"/api/payment/doGetDataMerchantTokenization"


#define kOFFSET_FOR_KEYBOARD 80.0

#endif /* Constant_h */
