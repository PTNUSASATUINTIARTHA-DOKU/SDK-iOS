//
//  DKNetworking.m
//  DokuPay
//
//  Created by IHsan HUsnul on 7/23/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKNetworking.h"

@implementation DKNetworking

-(void)requestParams:(NSString *)string url:(NSString *)urlString withCallBack:(void(^)(NSError *, id))resultCallBac{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    [request setHTTPMethod:@"POST"]; //Set the request for POST, the default is GET
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[NSData dataWithBytes:[string UTF8String] length:strlen([string UTF8String])]];
    
    /* Connect to the server */
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!connectionError && data) {
            NSError *error = nil;
            NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:data
                                                                        options:kNilOptions
                                                                          error:&error];
            if (![responseDic objectForKey:@"error"]) {
                resultCallBac (nil, responseDic);
            }
            else{
                resultCallBac (error, nil);
            }
        }else{
            resultCallBac (connectionError, nil);
        }
    }];
}

@end
