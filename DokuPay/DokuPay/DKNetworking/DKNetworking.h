//
//  DKNetworking.h
//  DokuPay
//
//  Created by IHsan HUsnul on 7/23/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DKNetworking : NSObject

-(void)requestParams:(NSString *)string url:(NSString *)urlString withCallBack:(void(^)(NSError *, id))resultCallBac;

@end
