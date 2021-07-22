//
//  DKSecure.h
//  DokuPay
//
//  Created by IHsan HUsnul on 5/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKStringUtils : NSString
-(NSString*)stringFromBytes:(uint8_t *)bytes length:(int)length;
@end


@class DKStringUtils;

@interface DKSecure : NSObject

+(NSString*)encrypt:(NSString*)plainText;

@end
