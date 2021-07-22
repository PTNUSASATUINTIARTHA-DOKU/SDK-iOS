//
//  DKPaymentCC.h
//  DokuPay
//
//  Created by IHsan HUsnul on 5/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKPaymentCC : NSObject

@property (nonatomic, strong) NSString *cardHolder;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, strong) NSString *cvv;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *validValue;
@property (nonatomic, strong) NSString *saveCard;
@property (nonatomic, strong) NSString *pairingCode;

-(NSString*)validValueClean;
-(NSString*)cardNumberClean;

@end
