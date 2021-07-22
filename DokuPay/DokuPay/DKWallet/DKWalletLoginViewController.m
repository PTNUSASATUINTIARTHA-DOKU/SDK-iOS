//
//  DKWalletLoginViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/9/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKWalletLoginViewController.h"
#import "DKUIHelper.h"
#import "Constant.h"
#import "DokuPay.h"
#import "DKUtils.h"
#import "RSAEncryptor.h"
#import "DKWalletChannelViewController.h"
#import "DKNetworking.h"

@interface DKWalletLoginViewController () <UITextFieldDelegate>
{
    DKNetworking *networking;
    UIActivityIndicatorView *indicator;
}
@end

@implementation DKWalletLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self resetFieldTesting];
    
    self.title = @"DOKU";
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
    
    UIBarButtonItem *backItem = [DKUIHelper barButtonBack:self selector:@selector(dismissDokuPay) withTintColor:self.navigationController.navigationBar.tintColor];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [DKUIHelper setButtonRounded:_loginBtn withBorderColor:[UIColor redColor]];
    
    [DKUIHelper setupLayoutBG:self.view];
    [DKUIHelper setupLayout:_mainView];
    
    indicator = [DKUIHelper addIndicatorSubView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)resetFieldTesting
{
    _emailField.text = @"";
    _passwordField.text = @"";
    
//    _emailField.text = @"1314693141";
//    _passwordField.text = @"Dokupay123";
    // pin 1122
}

- (IBAction)tapLogin:(id)sender
{
    if (![self isValid])
        return;
    
    NSDictionary *params = [DKUtils createRequestTokenWallet:_emailField.text pPassword:_passwordField.text];
    
    [self callWalletLogin:params];
}

-(void)dismissDokuPay
{
    [[[DokuPay sharedInstance] navController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)callWalletLogin:(NSDictionary*)params
{
    NSString *bodyString = [NSString stringWithFormat:@"data=%@", [DKUtils stringFromDictionary:params]];
    
    NSString *urlString;
    if ([[DokuPay sharedInstance] paymentItem].isProduction)
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrlProduction, URL_getToken];
    else
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrl, URL_getToken];
    
    
    if (!networking) {
        networking = [[DKNetworking alloc] init];
    }
    
    [indicator startAnimating];
    
    [networking requestParams:bodyString url:urlString withCallBack:^(NSError *err, id response) {
        NSLog(@"RESPONSE get token: %@", response);
        [indicator stopAnimating];
        
        self.conResult = response;
        
        if (response)
        {
            [self responseGetToken:response withError:err];
            
            [[DokuPay sharedInstance] startWalletTimer];
        }
        else
        {
            [[DokuPay sharedInstance] onError:err];
        }
    }];
}

-(void)responseGetToken:(NSDictionary*)responseObject withError:(NSError*)error
{
    if ([[responseObject objectForKey:@"res_response_code"] isEqual:@"0000"])
    {
        if ([responseObject objectForKey:@"res_data_dw"] && [[responseObject objectForKey:@"res_data_dw"] length] > 0)
        {
            _userDetail = [[DKUserDetail alloc] initWithString:[responseObject objectForKey:@"res_data_dw"]];
        }

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(DokuPay.class) bundle:[DKUIHelper frameworkBundle]];
        DKWalletChannelViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKWalletChannelViewController.class)];
        vc.userDetail = _userDetail;
        vc.conResult = responseObject;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if (responseObject) {
            error = [[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                               code:[[responseObject objectForKey:@"res_response_code"] integerValue]
                                           userInfo:@{NSLocalizedDescriptionKey: [responseObject objectForKey:@"res_response_msg"]}];
        }
        
        if ([[responseObject objectForKey:@"res_response_code"] isEqualToString:@"4001"])
        {
            UIAlertController *alertControl = [DKUIHelper alertView:[responseObject objectForKey:@"res_response_msg"] withTitle:nil];
            [self presentViewController:alertControl animated:YES completion:nil];
        }
        else
        {
            [[DokuPay sharedInstance] onError:error];
        }
    }
}

-(BOOL)isValid
{
    NSString *message = nil;
    
    if (_emailField.text.length == 0) {
        message = @"Email is required";
        
        [_emailField becomeFirstResponder];
    }
//    else if (![DKUIHelper emailValidation:self textField:_emailField])
//    {
//        message = @"Email address is invalid";
//        
//        [_emailField becomeFirstResponder];
//    }
    
    if (_passwordField.text.length == 0) {
        message = @"Password is required";
        
        [_passwordField becomeFirstResponder];
    }
    
    if (message) {
        UIAlertController *alertControl = [DKUIHelper alertView:message withTitle:nil];
        [self presentViewController:alertControl animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

//-(void)setupUserDetail:(NSString*)data_dw
//{
//    NSDictionary *dict = [DKUtils jsonStringToDictionary:data_dw];
//    
//    DKUserDetail *user = [[DokuPay sharedInstance] userDetail];
//    
//    user.customerName = dict[@"customerName"];
//    user.customerEmail = dict[@"customerEmail"];
//}

#pragma mark - uitextfield delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}


@end
