//
//  DokuPay.m
//  DokuPay
//
//  Created by IHsan HUsnul on 4/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DokuPay.h"
#import "DKUIHelper.h"
#import "Constant.h"
#import "DKCCFormViewController.h"
#import "DKWalletChannelViewController.h"
#import "DKMandiriClickpayViewController.h"
#import "DKVAAlfaViewController.h"
#import "DKWalletLoginViewController.h"
#import "DKVAViewController.h"
#import "DKUtils.h"

@implementation DokuPay

static DokuPay *sharedInstance = nil;
+ (void) setSharedInstance:(DokuPay*)instance
{
    sharedInstance = instance;
}

+(DokuPay*)sharedInstance
{
    static DokuPay *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

// DokuPay wallet
// email: jauhaf@nsiapay.net
// pass: 123456
// param getToken
//{"req_merchant_code":"1","req_transaction_id":"1154705856","req_payment_channel":"04","req_amount":"15000.00","req_currency":"360","req_chain_merchant":"NA","req_access_type":"M","req_basket":"[{\"name\":\"sayur\",\"amount\":\"10000.00\",\"quantity\":\"1\",\"subtotal\":\"10000.00\"},{\"name\":\"buah\",\"amount\":\"10000.00\",\"quantity\":\"1\",\"subtotal\":\"10000.00\"}]","req_words":"d89c5160e7a405cfa1770e181922d260b21c7e31","req_session_id":"858515562","req_device_id":"000000000000000","req_doku_id":"jauhaf@nsiapay.net","req_doku_pass":"123456"}

-(void)presentPayment
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(DokuPay.class) bundle:[DKUIHelper frameworkBundle]];
    _navController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKNavigationController.class)];
    
    [self setupLayout];
    
//    self.userDetail = [[DKUserDetail alloc] init];
    
    if ([self.paymentChannel isEqual:DokuPaymentChannelTypeCC])
    {
        DKCCFormViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKCCFormViewController.class)];
        _navController.viewControllers = @[vc];
    }
    else if ([self.paymentChannel isEqual:DokuPaymentChannelTypeCCFirst])
    {
        DKCCFormViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKCCFormViewController.class)];
        vc.isFirstToken = YES;
        _navController.viewControllers = @[vc];
    }
    else if ([self.paymentChannel isEqual:DokuPaymentChannelTypeCCSecond])
    {
        DKCCFormViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKCCFormViewController.class)];
        vc.isSecondToken = YES;
        _navController.viewControllers = @[vc];
    }
    else if ([self.paymentChannel isEqual:DokuPaymentChannelTypeWallet])
    {
        DKWalletLoginViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKWalletLoginViewController.class)];
        _navController.viewControllers = @[vc];
    }
    else if ([self.paymentChannel isEqual:DokuPaymentChannelTypeMandiriClickPay])
    {
        DKMandiriClickpayViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKMandiriClickpayViewController.class)];
        _navController.viewControllers = @[vc];
    }
    else if ([self.paymentChannel isEqual:DokuPaymentChannelTypeVirtualAccount])
    {
        DKVAViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKVAViewController.class)];
        _navController.viewControllers = @[vc];
    }
    else if ([self.paymentChannel isEqual:DokuPaymentChannelTypeVirtualMini])
    {
        DKVAAlfaViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKVAAlfaViewController.class)];
        _navController.viewControllers = @[vc];
    }
    
    
    [(UIViewController*)self.delegate presentViewController:_navController animated:YES completion: nil];
}

- (void)onError:(NSError *)error
{
    [_navController dismissViewControllerAnimated:YES completion:^{
        
        if ([self.delegate respondsToSelector:@selector(onDokuPayError:)])
        {
            [self.delegate onDokuPayError:error];
        }
    }];
    
    [[DokuPay sharedInstance] resetVariables];
}

-(void)onSuccess:(NSDictionary*)response
{   
    [_navController dismissViewControllerAnimated:YES completion:^{

        if ([self.delegate respondsToSelector:@selector(onDokuPaySuccess:)])
        {
            [self.delegate onDokuPaySuccess:response];
        }
        
    }];
    
    [[DokuPay sharedInstance] resetVariables];
}

-(void)onMandiriSuccess:(NSDictionary*)dictData
{
    [_navController dismissViewControllerAnimated:YES completion:^{
    
        if ([self.delegate respondsToSelector:@selector(onDokuMandiriPaySuccess:)])
        {
            [self.delegate onDokuMandiriPaySuccess:dictData];
        }
    }];
}

-(NSArray*)checkDataValidation
{
    NSMutableArray *errors = [[NSMutableArray alloc] init];
    
    if ([self.paymentItem isEqual:[NSNull null]]) {
        [errors addObject:@"Payment"];
    }
    else if([self.paymentItem.dataMerchantCode isEqual:[NSNull null]]) {
        [errors addObject:@"Merchant Code"];
    }
    else if([self.paymentItem.dataAmount isEqual:[NSNull null]]) {
        [errors addObject:@"Amount"];
    }
    else if([self.paymentItem.dataBasket isEqual:[NSNull null]]) {
        [errors addObject:@"Basket"];
    }
    else if([self.paymentItem.dataCurrency isEqual:[NSNull null]]) {
        [errors addObject:@"Currency"];
    }
    else if([self.paymentItem.dataMerchantChain isEqual:[NSNull null]]) {
        [errors addObject:@"Merchant Chain"];
    }
    else if([self.paymentItem.dataSessionID isEqual:[NSNull null]]) {
        [errors addObject:@"Session ID"];
    }
    else if([self.paymentItem.dataTransactionID isEqual:[NSNull null]]) {
        [errors addObject:@"Transaction ID"];
    }
    else if([self.paymentItem.dataWords isEqual:[NSNull null]]) {
        [errors addObject:@"Words"];
    }
    
    return errors;
}

-(void)setupLayout
{
    if (self.layout.toolbarColor)
        _navController.navigationBar.barTintColor = self.layout.toolbarColor;
    
    if (self.layout.toolbarTintColor)
        _navController.navigationBar.tintColor = self.layout.toolbarTintColor;
    
    if (self.layout.toolbarTextColor)
        _navController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: self.layout.toolbarTextColor};
}

-(void)resetVariables
{
    self.layout = nil;
    self.paymentItem = nil;
    self.paymentChannel = nil;
    
    [self.timer invalidate];
    self.timer = nil;
    
//    self.userDetail = nil;
}

-(void)startWalletTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 60*10
                                                  target: self
                                                selector: @selector(doLogoutWallet)
                                                userInfo: nil
                                                 repeats: YES];
}

-(void)doLogoutWallet
{
    NSError *error = [[NSError alloc] initWithDomain: [[NSBundle mainBundle] bundleIdentifier]
                                                code: 0
                                            userInfo: @{NSLocalizedDescriptionKey: @"Session Expired"}];
    [self onError:error];
}

@end
