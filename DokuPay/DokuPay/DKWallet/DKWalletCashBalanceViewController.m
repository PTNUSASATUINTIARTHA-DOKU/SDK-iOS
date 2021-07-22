//
//  DKWalletCashBalanceViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 6/6/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKWalletCashBalanceViewController.h"
#import "DKUIHelper.h"
#import "DokuPay.h"
#import "Constant.h"
#import "DKUtils.h"
#import "DKNetworking.h"

@interface DKWalletCashBalanceViewController () <UITextFieldDelegate, IQDropDownTextFieldDelegate>
{
    NSString *voucherSelectedString;
    
    DKNetworking *networking;
    UIActivityIndicatorView *indicator;
}
@end

@implementation DKWalletCashBalanceViewController

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
    
    UIBarButtonItem *backItem = [DKUIHelper barButtonBack:self selector:@selector(back) withTintColor:self.navigationController.navigationBar.tintColor];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self setupData];
    
    [DKUIHelper setButtonRounded:_submitBtn withBorderColor:[UIColor redColor]];
    
    [DKUIHelper setupLayoutBG:self.view];
    [DKUIHelper setupLayout:_mainView];
    
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked:)]];
    [numberToolbar sizeToFit];
    _pinField.inputAccessoryView = numberToolbar;
    
    indicator = [DKUIHelper addIndicatorSubView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupDropDown];
}

-(void)setupData
{
    NSDictionary *details = [_walletChannel objectForKey:@"details"];
    
    NSDictionary *dataDw = [DKUtils jsonStringToDictionary:[_conResult objectForKey:@"res_data_dw"]];
   _nameLabel.text = [dataDw objectForKey:@"customerName"];
    
    NSNumber *number = [NSNumber numberWithInteger:[[details objectForKey:@"lastBalance"] integerValue]];
    _cashBalanceLabel.text = [NSString stringWithFormat:@"Rp %@", [DKUIHelper numberToCurrency:number]];
    
    NSNumber *amount = [NSNumber numberWithInteger:[[[DokuPay sharedInstance] paymentItem].dataAmount integerValue]];
    _pembayaranField.text = [NSString stringWithFormat:@"Rp %@", [DKUIHelper numberToCurrency:amount]];
}

-(void)setupVoucherOption
{
    if (_userDetail.listPromotion.count > 0)
    {
        _voucherView.hidden = NO;
        _voucherField.itemList = _userDetail.listPromotion;
        
        _voucherSelectedView.hidden = NO;
        _totalPembayaranView.hidden = NO;
    }
}

- (IBAction)tapSubmit:(id)sender
{
    if (![self isValid])
        return;
    
    /*
    {
        "res_amount" = "15000.00";
        "res_data_dw" = "{\"responseCode\":\"0000\",\"responseMsg\":\"SUCCESS\",\"dpMallId\":\"47\",\"transIdMerchant\":\"9963654840\",\"inquiryCode\":\"a047ab932a900d89dfadc96fa97fdd539688c232\",\"dokuId\":\"1149567889\",\"customerName\":\"Dokutest1\",\"customerEmail\":\"dokutest1@techgroup.me\",\"listPaymentChannel\":[{\"channelCode\":\"01\",\"channelName\":\"Cash Wallet\",\"details\":{\"lastBalance\":1582430.00}},{\"channelCode\":\"02\",\"channelName\":\"Credit Card\",\"details\":[{\"linkId\":\"fuR+MEEc5l9XTM7vpMkqhQ\\u003d\\u003d\",\"cardNoMasked\":\"5***********4763\",\"cardName\":\"COBA\",\"cardPhone\":\"6297875567654\",\"cardNoEncrypt\":\"IsGzsyw3IDTGyLEKu7hXwqL1xlCsE1iEFltbi5DAXFw\\u003d\",\"cardExpiryDateEncrypt\":\"/HU/nB2E2/smA1Uj9qJhbA\\u003d\\u003d\",\"cardType\":\"MASTERCARD\"}]}],\"avatar\":\"\"}";
        "res_device_id" = 9295D444FC3C4788A1B7AC360D58108D;
        "res_pairing_code" = 07061617112847307404;
        "res_payment_channel" = 04;
        "res_response_code" = 0000;
        "res_response_msg" = SUCCESS;
        "res_token_code" = 0000;
        "res_token_id" = e0072c50c129043f8a0aa136e843a0150ddc5559;
        "res_transaction_id" = 9963654840;
    }
    */
    
    NSString *voucherID = nil;
    if (voucherSelectedString && ![voucherSelectedString isEqualToString:@"Select"])
    {
        NSInteger index = [[_userDetail titleListPromotion] indexOfObject:voucherSelectedString];
        NSDictionary *promo = _userDetail.listPromotion[index];
        voucherID = [promo objectForKey:@"id"];
    }
    NSMutableDictionary *params = [DKUtils createRequestCashWallet:_conResult withPIN:_pinField.text withVoucher:voucherID];
    
    [self callWalletCashPrePayment:params];
}

-(void)callWalletCashPrePayment:(NSDictionary*)params
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
        
        if (response){
            [self responseGetToken:response withError:err];
        }
        else
        {
            [[DokuPay sharedInstance] onError:err];
        }
    }];
}

-(void)popNavigation
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)responseGetToken:(NSDictionary*)responseObject withError:(NSError*)error
{
    if ([[responseObject objectForKey:@"res_response_code"] isEqual:@"0000"])
    {
        NSDictionary *responseSDK = [DKUtils createResponseCashWallet:_conResult withWalletChannel:_walletChannel];
        [[DokuPay sharedInstance] onSuccess:responseSDK];
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
    UIAlertController *alertControl = nil;
    if (_pinField.text.length == 0)
    {
        alertControl = [DKUIHelper alertView:@"PIN is required" withTitle:nil];
    }
    else if (_pinField.text.length < 4)
    {
        alertControl = [DKUIHelper alertView:@"Invalid format" withTitle:nil];
    }
    
    if (alertControl) {
        [_pinField becomeFirstResponder];
        
        [self presentViewController:alertControl animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}

-(void)setupDropDown
{
    UIView *view = [_voucherView viewWithTag:1];
    _voucherField = [[IQDropDownTextField alloc] initWithFrame:view.frame];
    _voucherField.delegate = self;
    _voucherField.font = [UIFont systemFontOfSize:12];
    _voucherField.placeholder = @"Pilih";
    [_voucherField setBorderStyle:UITextBorderStyleNone];
    [_voucherField setTextAlignment:NSTextAlignmentLeft];
    _voucherField.itemList = [_userDetail titleListPromotion];
    [view addSubview:_voucherField];
    
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar setBarStyle:UIBarStyleBlackTranslucent];
    [toolbar sizeToFit];
    UIBarButtonItem *buttonflexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneClicked:)];
    
    [toolbar setItems:[NSArray arrayWithObjects:buttonflexible, buttonDone, nil]];
    _voucherField.inputAccessoryView = toolbar;
    
    [self setupVoucherView];
}

-(void)setupVoucherView
{
    if (voucherSelectedString == nil || [voucherSelectedString isEqualToString:@"Select"])
    {
        _voucherSelectedView.hidden = YES;
        _totalPembayaranView.hidden = YES;
        _topConstraintPIN.constant = 10;
    }
    else
    {
        _voucherSelectedView.hidden = NO;
        _totalPembayaranView.hidden = NO;
        _topConstraintPIN.constant = 100;
    }
    
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    NSInteger pembayaran = [paymentItem.dataAmount integerValue];
    
    if (voucherSelectedString && ![voucherSelectedString isEqualToString:@"Select"])
    {
        NSInteger index = [[_userDetail titleListPromotion] indexOfObject:voucherSelectedString];
        NSDictionary *promo = _userDetail.listPromotion[index];
        NSInteger voucher = [[promo objectForKey:@"amount"] integerValue];
        
        NSNumber *voucherNumber = [NSNumber numberWithInteger:voucher];
        _voucherSelectedField.text = [NSString stringWithFormat:@"- Rp %@", voucherNumber];
        
        NSInteger total = pembayaran - voucher;
        if (total < 0)
            total = 0;
        
        NSNumber *totalNumber = [NSNumber numberWithInteger:total];
        _totalPembayaranField.text = [NSString stringWithFormat:@"Rp %@", [DKUIHelper numberToCurrency:totalNumber]];
    }
}

#pragma mark - textfield IODropDown delegate
-(void)textField:(nonnull IQDropDownTextField*)textField didSelectItem:(nullable NSString*)item
{
    voucherSelectedString = item;
    
    [self setupVoucherView];
}

-(void)doneClicked:(UIBarButtonItem*)button
{
    [self.view endEditing:YES];
}


#pragma mark - Textfield delegate
-(BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string
{
    if ([textField isEqual:_pinField])
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


#pragma mark - handle keyboard on textfield
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO];
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -130; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
