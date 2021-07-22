//
//  DKWeb3DViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 6/8/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DKWeb3DViewControllerDelegate <NSObject>
-(void)doChecking3DSecure:(nullable NSDictionary*)response;
@end

@interface DKWeb3DViewController : UIViewController

@property (nonnull, nonatomic, assign) id<DKWeb3DViewControllerDelegate>delegate;

@property (nonnull, nonatomic, strong) NSDictionary *result3D;
@property (nullable, weak, nonatomic) IBOutlet UIWebView *webView;

@end
