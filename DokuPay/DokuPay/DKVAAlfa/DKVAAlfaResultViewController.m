//
//  DKVAAlfaResultViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/28/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKVAAlfaResultViewController.h"
#import "DKUIHelper.h"
#import "DokuPay.h"

@interface DKVAAlfaResultViewController ()

@end

@implementation DKVAAlfaResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
    
    [DKUIHelper setButtonRounded:_howToPayView withBorderColor:[UIColor redColor]];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHowToPay:)];
    [_howToPayView addGestureRecognizer:tap];
    
    UIBarButtonItem *leftBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                style:UIBarButtonItemStylePlain
                                                               target:self
                                                               action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBtn;
    
    [self setupViewData];
    
    [DKUIHelper setupLayoutBG:self.view];
    [DKUIHelper setupLayout:_mainView];
//    [DKUIHelper setupLayout:[_mainView viewWithTag:1]];
    [DKUIHelper setupLayout:[_mainView viewWithTag:2]];
    [DKUIHelper setupLayoutViewButton:_howToPayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapHowToPay:(id)sender
{
    NSString *url = @"http://doku.com";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

-(void)setupViewData
{   
    _paymentCode.text = [_conResult objectForKey:@"res_pay_code"];
    
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    _invoiceLabel.text = paymentItem.dataTransactionID;
    
    NSNumber *amount = [NSNumber numberWithInteger:[paymentItem.dataAmount integerValue]];
    _totalLabel.text = [NSString stringWithFormat:@"Rp %@", [DKUIHelper numberToCurrency:amount]];
}

-(void)back
{
    [[[DokuPay sharedInstance] navController] dismissViewControllerAnimated:YES completion:nil];
}

@end
