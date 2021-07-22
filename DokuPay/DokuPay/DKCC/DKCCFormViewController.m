//
//  DKCCFormViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 4/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKCCFormViewController.h"
#import "DKUIHelper.h"
#import "Constant.h"
#import "DKNavigationController.h"
#import "DKPaymentItem.h"
#import "DokuPay.h"
#import "DKUtils.h"
#import "DKPaymentItem.h"
#import "DKWeb3DViewController.h"
#import "Luhn.h"
#import "DKNetworking.h"

@interface DKCCFormViewController () <UITextFieldDelegate>
{
    NSString *previousTextFieldContent;
    UITextRange *previousSelection;
    NSDictionary *secondResult;
    NSDictionary *firstResult;
    
    NSString *email;
    NSString *cardHolder;
    NSString *phoneNumber;
    
    DKNetworking *networking;
    UIActivityIndicatorView *indicator;
}
@end

@implementation DKCCFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self resetFields];
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
    
    UIBarButtonItem *backItem = [DKUIHelper barButtonBack:self selector:@selector(dismissDokuPay) withTintColor:self.navigationController.navigationBar.tintColor];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    self.title = @"Credit Card";
    
    NSLog(@"Initiate Payment Data dataMerchantCode: %@",[[DokuPay sharedInstance] paymentItem].dataMerchantCode);
    NSLog(@"Initiate Payment Data dataWords: %@",[[DokuPay sharedInstance] paymentItem].dataWords);
    NSLog(@"Initiate Payment Data dataTransactionID: %@",[[DokuPay sharedInstance] paymentItem].dataTransactionID);
    NSLog(@"Initiate Payment Data dataAmount: %@",[[DokuPay sharedInstance] paymentItem].dataAmount);
    NSLog(@"Initiate Payment Data dataCurrency: %@",[[DokuPay sharedInstance] paymentItem].dataCurrency);
    NSLog(@"Initiate Payment Data dataMerchantChain: %@",[[DokuPay sharedInstance] paymentItem].dataMerchantChain);
    NSLog(@"Initiate Payment Data dataBasket: %@",[[DokuPay sharedInstance] paymentItem].dataBasket);
    NSLog(@"Initiate Payment Data dataSessionID: %@",[[DokuPay sharedInstance] paymentItem].dataSessionID);
    NSLog(@"Initiate Payment Data dataImei: %@",[[DokuPay sharedInstance] paymentItem].dataImei);
    NSLog(@"Initiate Payment Data mobilePhone: %@",[[DokuPay sharedInstance] paymentItem].mobilePhone);
    NSLog(@"Initiate Payment Data dataOptions: %@",[[DokuPay sharedInstance] paymentItem].dataOptions);
    NSLog(@"Initiate Payment Data isProduction: %c",[[DokuPay sharedInstance] paymentItem].isProduction);
    NSLog(@"Initiate Payment Data publicKey: %@",[[DokuPay sharedInstance] paymentItem].publicKey);
    NSLog(@"Initiate Payment Data customerID: %@",[[DokuPay sharedInstance] paymentItem].customerID);
    NSLog(@"Initiate Payment Data sharedKey: %@",[[DokuPay sharedInstance] paymentItem].sharedKey);
    NSLog(@"Initiate Payment Data tokenPayment: %@",[[DokuPay sharedInstance] paymentItem].tokenPayment);
    NSLog(@"Initiate Payment Data dataEmail: %@",[[DokuPay sharedInstance] paymentItem].dataEmail);
    
    self.phoneField.text = [[DokuPay sharedInstance] paymentItem].mobilePhone;
    NSString * getDataEmail = [[DokuPay sharedInstance] paymentItem].dataEmail;
    
    if (getDataEmail != nil && [getDataEmail length] != 0) {
        self.emailField.text = getDataEmail;
        [self.emailField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if (_isSecondToken)
    {   
        NSDictionary *paramsSecond = [DKUtils cardInquirySecond];
        
        [self callCheckStatusToken:paramsSecond];
        
        [DKUIHelper setupLayout:_mainSecondView];
        
        [DKUIHelper setButtonRounded:_submitSecondBtn withBorderColor:[UIColor redColor]];
        
        [self addDoneKeyboard:_cvvSecondField];
    }
    else
    {
        [self setupShowOption:NO];
        
        DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
        
        if (paymentItem.customerID.length > 0)
        {
            NSDictionary *paramsCheckMerchant = [DKUtils checkMerchantStatus];
            
            [self callCheckStatusToken:paramsCheckMerchant];
        }
        
        [DKUIHelper setupLayout:_mainView];
        
        
        UITapGestureRecognizer *tapInfo = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVccInfo:)];
        [_vccInfoView addGestureRecognizer:tapInfo];
        
        [self addDoneKeyboard:_expiryField];
        [self addDoneKeyboard:_numberField];
        [self addDoneKeyboard:_phoneField];
        [self addDoneKeyboard:_cvvField];
        [_numberField addTarget:self
                         action:@selector(reformatAsCardNumber:)
               forControlEvents:UIControlEventEditingChanged];
        _numberField.delegate = self;
        _cvvField.delegate = self;
        _expiryField.delegate = self;
        
        [DKUIHelper setButtonRounded:_submitBtn withBorderColor:[UIColor redColor]];
    }
    
    _mainSecondView.hidden = !_isSecondToken;
    _mainView.hidden = _isSecondToken;
    
    [DKUIHelper setupLayoutBG:self.view];
    
    indicator = [DKUIHelper addIndicatorSubView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

-(void)dismissDokuPay
{
    if (_isRegister)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)doneWithNumberPad
{
    [self.view endEditing:YES];
}

- (IBAction)tapSubmit:(id)sender
{
    [self.view endEditing:YES];
    
    if (![self isValid])
        return;
    
    DKPaymentCC *paymentCC = [[DKPaymentCC alloc] init];
    
    paymentCC.validValue = _expiryField.text;
    paymentCC.cardNumber = _numberField.text;
    paymentCC.cvv = _cvvField.text;
    paymentCC.cardHolder = _nameField.text;
    cardHolder = _nameField.text;
    paymentCC.email = _emailField.text;
    email = _emailField.text;
    paymentCC.phoneNumber = _phoneField.text;
    phoneNumber = _phoneField.text;
    
    
    NSMutableDictionary *params = [DKUtils createRequestTokenCC:paymentCC];
    
    if (_isFirstToken) {
        NSString *string = _saveSwitch.on ? @"SAVE" : @"UNSAVE";
        [params setObject:string forKey:@"req_save_customer"];
        
        [params setValue:[firstResult objectForKey:@"res_pairing_code"] forKey:@"req_pairing_code"];
    }
    
    if (_isRegister) {
        params = [DKUtils createRegisterCCWallet:paymentCC withUserDetail:_userDetail withConResult:_conResult withWalletChannel:_walletChannel];
        
        [params setObject:[_conResult objectForKey:@"res_pairing_code"] forKey:@"req_pairing_code"];
        [params setObject:[_conResult objectForKey:@"res_token_id"] forKey:@"req_token_id"];
        [params setObject:[[DokuPay sharedInstance] paymentItem].dataWords forKey:@"req_words"];
        
        [self callPrePayment:params];
    }
    else
    {
        [self callGetToken:params];
    }
}

- (IBAction)tapSecondSubmit:(id)sender
{
    [self.view endEditing:YES];
    
    if (![self isSecondValid])
        return;
    
    DKPaymentCC *paymentCC = [[DKPaymentCC alloc] init];
    paymentCC.cvv = _cvvSecondField.text;
    phoneNumber = [secondResult objectForKey:@"res_data_mobile_phone"];
    email = [secondResult objectForKey:@"res_data_email"];
    
    NSDictionary *params = [DKUtils createRequestTokenCC:paymentCC];
    [params setValue:[secondResult objectForKey:@"res_pairing_code"] forKey:@"req_pairing_code"];
    
    [self callGetToken:params];
}

-(void)callGetToken:(NSDictionary*)params
{
    NSString *bodyString = [NSString stringWithFormat:@"data=%@", [DKUtils stringFromDictionary:params]];
    
    NSString *urlString;
    if ([[DokuPay sharedInstance] paymentItem].isProduction)
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrlProduction, URL_getToken];
    else
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrl, URL_getToken];
    
    NSLog(@"REQUEST get token url, %@", urlString);
    NSLog(@"REQUEST get token param, %@", bodyString);
    
    if (!networking) {
        networking = [[DKNetworking alloc] init];
    }
    
    [indicator startAnimating];
    
    [networking requestParams:bodyString url:urlString withCallBack:^(NSError *err, id response) {
        NSLog(@"RESPONSE get token, %@", response);
        [indicator stopAnimating];
        
        if (response) {
            self.conResult = response;
            
            [self responseGetToken:response withError:err];
        }
        else
        {
            [[DokuPay sharedInstance] onError:err];
        }
    }];
}


-(void)callCheckStatusToken:(NSDictionary*)params
{
    NSString *bodyString = [NSString stringWithFormat:@"data=%@", [DKUtils stringFromDictionary:params]];
    
    NSString *urlString;
    if ([[DokuPay sharedInstance] paymentItem].isProduction)
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrlProduction, URL_doCheckStatusToken];
    else
        urlString = [NSString stringWithFormat:@"%@%@", ConfigUrl, URL_doCheckStatusToken];
    
    if (!networking) {
        networking = [[DKNetworking alloc] init];
    }
    
    [indicator startAnimating];
    
    [networking requestParams:bodyString url:urlString withCallBack:^(NSError *err, id response) {
        
        NSLog(@"RESPONSE do check status token, %@", response);
        [indicator stopAnimating];
        
        if ([[response objectForKey:@"res_response_code"] isEqualToString:@"0000"])
        {
            if (_isSecondToken)
            {
                secondResult = response;
                
                _numberSecondField.text = [secondResult objectForKey:@"res_cc_number"];
                if (_numberSecondField.text.length > 0) {
                    _icoSecondSuccess.hidden = NO;
                }
            }
            else
            {
                firstResult = response;
                
                BOOL showSave = [[firstResult objectForKey:@"res_service_two_click"] isEqualToString:@"true"];
                [self setupShowOption:showSave];
            }
        }
        else
        {
            NSError *error;
            if (response)
            {
                error = [[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                   code:[[response objectForKey:@"res_response_code"] intValue]
                                               userInfo:@{NSLocalizedDescriptionKey: [response objectForKey:@"res_response_msg"]}];
            }
            
            [[DokuPay sharedInstance] onError:error];
        }
    }];
}


-(void)responseGetToken:(NSDictionary*)responseObject withError:(NSError*)error
{
    if ([[responseObject objectForKey:@"res_response_code"] isEqual:@"0000"])
    {
        if ([responseObject objectForKey:@"res_result_3D"] && [[responseObject objectForKey:@"res_result_3D"] length] > 0)
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(DokuPay.class) bundle:[DKUIHelper frameworkBundle]];
            DKWeb3DViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKWeb3DViewController.class)];
            vc.delegate = self;
            vc.result3D = [DKUtils jsonStringToDictionary:[responseObject objectForKey:@"res_result_3D"]];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            NSMutableDictionary *responseSDK = [[NSMutableDictionary alloc] init];
            
            if (_walletChannel)
            {
                responseSDK = [DKUtils createResponseCashWallet:_conResult withWalletChannel:_walletChannel];
            }
            else
            {
                responseSDK = [DKUtils createResponseCCReguler:_conResult];
                [responseSDK setObject:_nameField.text forKey:@"res_name"];
                
                if (_isSecondToken)
                {
//                    DKUserDetail *user = [[DokuPay sharedInstance] userDetail];
                    responseSDK[@"res_data_mobile_phone"] = secondResult[@"res_data_mobile_phone"];
                    responseSDK[@"res_data_email"] = secondResult[@"res_data_email"];
                }
            }
            
            
            [[DokuPay sharedInstance] onSuccess:responseSDK];
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

-(void)callPrePayment:(NSDictionary*)params
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
    
    [networking requestParams:bodyString url:URL_RequestVACode withCallBack:^(NSError *err, id response) {
        
        NSLog(@"RESPONSE pre payment, %@", response);
        [indicator stopAnimating];
        
        if (response) {
            [self responseGetToken:response withError:err];
        }
        else
        {
            [[DokuPay sharedInstance] onError:err];
        }
    }];
}


- (IBAction)changeSave:(id)sender
{

}

-(void)setupShowOption:(BOOL)yOrNo
{
    _buttonTopConstraint.constant = yOrNo ? 60 : 20;
    _saveLabel.hidden = !yOrNo;
    _saveSwitch.hidden = !yOrNo;
    _saveSwitch.on = yOrNo;
}


#pragma mark - reformat CC number
-(void)reformatAsCardNumber:(UITextField *)textField
{
    DKUIHelper *uiHelper = [[DKUIHelper alloc] init];
    [uiHelper textField:textField asCardNumber:previousTextFieldContent withPrevRange:previousSelection];
}

-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if ([textField isEqual:_numberField])
    {
        // Note textField's current state before performing the change, in case
        // reformatTextField wants to revert it
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
    }
    else if ([textField isEqual:_cvvField] ||
             [textField isEqual:_cvvSecondField])
    {
        // Prevent crashing undo bug – see note below.
        if (range.length + range.location > textField.text.length)
        {
            return NO;
        }
        
        NSUInteger newLength = [textField.text length] + [string length] - range.length;
        return newLength <= 4;
    }
    else if ([textField isEqual:_expiryField])
    {
        NSString *str = textField.text;
        
        if ([str isEqualToString:@""] && [string intValue] > 1) {
            textField.text = @"0";
            return YES;
        }
        
        if ([str isEqualToString:@"0"] && [string isEqualToString:@"0"]) {
            return NO;
        }
        
        if ([str isEqualToString:@"1"] && ![string isEqualToString:@""])
        {
            if ([string intValue] <= 2) {
                return YES;
            }
            else
            {
                UIAlertController *alertControl = [DKUIHelper alertView:@"Enter a valid date MM/YY" withTitle:nil];
                [self presentViewController:alertControl animated:YES completion:nil];
                
                return NO;
            }
        }
        
        if (str.length <= 4 || string.length == 0)
        {
            if (str.length == 2 && ![string isEqualToString:@""]) {
                textField.text = [NSString stringWithFormat:@"%@/", str];
            }
            
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)tapVccInfo:(id)sender
{
    UIAlertController *alertControl = [DKUIHelper alertView:@"Insert the last 3 numbers from the back of your credit card" withTitle:nil];
    
    [self presentViewController:alertControl animated:YES completion:nil];
}

-(void)resetFields
{
    _nameField.text = @"";
    _numberField.text = @"";
    _cvvField.text = @"";
    _emailField.text = @"";
    _phoneField.text = @"";
    _expiryField.text = @"";
}

-(BOOL)isValid
{
    if (_numberField.text.length == 0)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Card number field is required"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    else if (![Luhn validateString:_numberField.text])
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Invalid card number"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    if (_cvvField.text.length == 0)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"CVV field is required"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    else if (_cvvField.text.length < 3 || _cvvField.text.length > 4)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Invalid CVV"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    if (_nameField.text.length == 0)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Name field is required"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    if (_expiryField.text.length == 0)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Expiry field is required"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    else if (_expiryField.text.length != 5)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Invalid expiry date"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    if (![DKUIHelper emailValidation:self textField:_emailField])
    {
        [_emailField becomeFirstResponder];
        
        return NO;
    }
    
    if (_phoneField.text.length == 0)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Phone number field is required"];
        [self presentViewController:alert animated:YES completion:nil];

        return NO;
    }
    
    return YES;
}

-(BOOL)isSecondValid
{
    if (_cvvSecondField.text.length == 0)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"CVV field is required"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    else if (_cvvSecondField.text.length < 3 || _cvvSecondField.text.length > 4)
    {
        UIAlertController *alert = [DKUIHelper alertView:nil withTitle:@"Invalid CVV"];
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

-(void)addDoneKeyboard:(UITextField*)field
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    
    field.inputAccessoryView = numberToolbar;
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
        
        //NSLog(@"Dedye URL_RequestVACode :%@",URL_RequestVACode);
        
        if (!networking) {
            networking = [[DKNetworking alloc] init];
        }
        
        [indicator startAnimating];
        
        //[networking requestParams:bodyString url:URL_RequestVACode withCallBack:^(NSError *err, id response) {
        [networking requestParams:bodyString url:urlString withCallBack:^(NSError *err, id response) {
            
            NSLog(@"RESPONSE check 3ds, %@", response);
            [indicator stopAnimating];
            
            if ([[response objectForKey:@"res_response_code"] isEqualToString:@"0000"])
            {
                NSMutableDictionary *responseSDK = [[NSMutableDictionary alloc] init];
                if (_walletChannel)
                {
                    if (_isRegister)
                        responseSDK = [DKUtils createResponseCashWallet:_conResult withWalletChannel:_walletChannel];
                    else
                        responseSDK = [DKUtils createResponseCashWallet:response withWalletChannel:_walletChannel];
                }
                else
                {
                    responseSDK = [DKUtils createResponseCCReguler:_conResult];
                    [responseSDK setObject:_nameField.text forKey:@"res_name"];
                    if (_isSecondToken) {
                        [responseSDK setObject:secondResult[@"res_data_email"] forKey:@"res_data_email"];
                        [responseSDK setObject:secondResult[@"res_data_mobile_phone"] forKey:@"res_data_mobile_phone"];
                    }
                }
                
                [[DokuPay sharedInstance] onSuccess:responseSDK];
            }
            else
            {
                NSError *error;
                if (response)
                {
                    error = [[NSError alloc] initWithDomain:[[NSBundle mainBundle] bundleIdentifier]
                                                       code:[[response objectForKey:@"res_response_code"] intValue]
                                                   userInfo:@{NSLocalizedDescriptionKey: [response objectForKey:@"res_response_msg"]}];
                }
                
                [[DokuPay sharedInstance] onError:error];
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

@end
