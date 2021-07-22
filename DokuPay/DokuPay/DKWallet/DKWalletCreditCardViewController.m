//
//  DKWalletCreditCardViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 6/6/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKWalletCreditCardViewController.h"
#import "DKUtils.h"
#import "DKUIHelper.h"
#import "Constant.h"
#import "DokuPay.h"
#import "DKWeb3DViewController.h"
#import "DKNetworking.h"

@interface DKWalletCreditCardViewController () <UITextFieldDelegate>
{
    DKNetworking *networking;
    UIActivityIndicatorView *indicator;
}
@end

@implementation DKWalletCreditCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DOKU";
    
    [self setupData];
    
    UIBarButtonItem *backItem = [DKUIHelper barButtonBack:self selector:@selector(back) withTintColor:self.navigationController.navigationBar.tintColor];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
    
    [DKUIHelper setButtonRounded:_submitBtn withBorderColor:[UIColor redColor]];
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    _cvvField.inputAccessoryView = numberToolbar;
    
    [DKUIHelper setupLayoutBG:self.view];
    [DKUIHelper setupLayout:_mainView];
    
    indicator = [DKUIHelper addIndicatorSubView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)tapSubmit:(id)sender
{
    if (![self isValid])
        return;
    
    [self.view endEditing:YES];
    
    NSDictionary *params = [DKUtils createRequestCCWallet:_conResult withWalletChannel:_walletChannel pCVV:_cvvField.text];
    
    [self callWalletCCPrePayment:params];
}

-(void)callWalletCCPrePayment:(NSDictionary*)params
{
    NSString *bodyString = [NSString stringWithFormat:@"data=%@", [DKUtils stringFromDictionary:params]];
    
    NSString *urlString;
    if ([[DokuPay sharedInstance] paymentItem].isProduction)
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrlProduction, URL_prePayment];
    else
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrl, URL_prePayment];
    
    
    if (!networking) {
        networking = [[DKNetworking alloc] init];
    }
    
    [indicator startAnimating];
    
    [networking requestParams:bodyString url:urlString withCallBack:^(NSError *err, id response) {
        
        NSLog(@"RESPONSE pre payment, %@", response);
        [indicator stopAnimating];
        
        if (response)
        {
            [self responseGetToken:response withError:err];
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
        if ([responseObject objectForKey:@"res_result_3D"])
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(DokuPay.class) bundle:[DKUIHelper frameworkBundle]];
            DKWeb3DViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKWeb3DViewController.class)];
            vc.delegate = self;
            vc.result3D = [DKUtils jsonStringToDictionary:[responseObject objectForKey:@"res_result_3D"]];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            NSDictionary *response = [DKUtils createResponseCashWallet:_conResult withWalletChannel:_walletChannel];
            
            [[DokuPay sharedInstance] onSuccess:response];
        }
    }
    else
    {
        if (responseObject) {
            error = [[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                        code:[[responseObject objectForKey:@"res_response_code"] integerValue]
                                                    userInfo:@{NSLocalizedDescriptionKey: [responseObject objectForKey:@"res_response_msg"]}];
        }
        
        // error api
        [[DokuPay sharedInstance] onError:error];
    }
}

-(BOOL)isValid
{
    NSString *message = nil;
    
    if (_cvvField.text.length == 0)
    {
        message = @"CVV is required";
    }
    else if (_cvvField.text.length < 3)
    {
        message = @"Invalid format";
    }
    
    if (message) {
        [_cvvField becomeFirstResponder];
        
        UIAlertController *alertControl = [DKUIHelper alertView:message withTitle:nil];
        [self presentViewController:alertControl animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

-(void)setupData
{
    NSDictionary *dataDw = [DKUtils jsonStringToDictionary:[_conResult objectForKey:@"res_data_dw"]];
    _nameLabel.text = [dataDw objectForKey:@"customerName"];
    
    // CC can be multiple (array)
    NSDictionary *details = [_walletChannel objectForKey:@"details"][0];
    
    _numberField.text = [details objectForKey:@"cardNoMasked"];
}

-(void)doneWithNumberPad
{
    [_cvvField resignFirstResponder];
}

-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if ([textField isEqual:_cvvField])
    {
        if (range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 4;
    }
    return YES;
}

#pragma mark - handle keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_cvvField]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:_cvvField]) {
        [self animateTextField:textField up:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_cvvField]) {
        [self animateTextField:textField up:NO];
    }
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -230; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}


#pragma mark - delegate
-(void)doChecking3DSecure:(NSDictionary*)response
{
    [self checking3DSecure:response];
}

-(void)checking3DSecure:(NSDictionary*)response
{
    if ([[response objectForKey:@"res_response_code"] isEqualToString:@"0000"])
    {
        NSDictionary *params = [DKUtils createRequest3D:_conResult];
        
        NSString *bodyString = [NSString stringWithFormat:@"data=%@", [DKUtils stringFromDictionary:params]];
        
        NSString *urlString;
        if ([[DokuPay sharedInstance] paymentItem].isProduction)
            urlString = [NSString stringWithFormat:@"%@%@", ConfigUrlProduction, URL_Check3DStatus];
        else
            urlString = [NSString stringWithFormat:@"%@%@", ConfigUrl, URL_Check3DStatus];
        
        
        if (!networking) {
            networking = [[DKNetworking alloc] init];
        }
        
        [indicator startAnimating];
        
        [networking requestParams:bodyString url:urlString withCallBack:^(NSError *err, id response) {
            
            NSLog(@"RESPONSE check 3ds: %@", response);
            [indicator stopAnimating];
            
            // development handle
            if ([[response objectForKey:@"res_response_code"] isEqual:@"0000"])
                //            if (true)
            {
                NSDictionary *responseSDK = [DKUtils createResponseCashWallet:_conResult withWalletChannel:_walletChannel];
                [[DokuPay sharedInstance] onSuccess:responseSDK];
            }
            else
            {
                if (response) {
                    err = [[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                       code:[[response objectForKey:@"res_response_code"] integerValue]
                                                   userInfo:@{NSLocalizedDescriptionKey: [response objectForKey:@"res_response_msg"]}];
                }
                
                // error api
                [[DokuPay sharedInstance] onError:err];
            }
        }];
    }
    else
    {
        NSError *error = [[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                    code:[[response objectForKey:@"res_response_code"] intValue]
                                                userInfo:@{NSLocalizedDescriptionKey: [response objectForKey:@"res_response_msg"]}];
        [[DokuPay sharedInstance] onError:error];
    }
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
