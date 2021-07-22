//
//  DKWalletChannelViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/9/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKWalletChannelViewController.h"
#import "DKWalletCashBalanceViewController.h"
#import "DokuPay.h"
#import "DKUIHelper.h"
#import "DKWalletCreditCardViewController.h"
#import "DKUtils.h"
#import "DKCCFormViewController.h"

@interface DKWalletChannelViewController ()
{
    NSArray *channels;
    NSDictionary *resDataDw;
}
@end

@implementation DKWalletChannelViewController

#define WalletChannelTypeCashBalance @"01"
#define WalletChannelTypeCreditCard @"02"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DOKU";
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
  
    UIBarButtonItem *backItem = [DKUIHelper barButtonBack:self selector:@selector(back) withTintColor:self.navigationController.navigationBar.tintColor];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    resDataDw = [DKUtils jsonStringToDictionary:[_conResult objectForKey:@"res_data_dw"]];
    
    [self setupData];
    
    channels = [self getChannels];
    
    
    [DKUIHelper setupLayoutBG:self.view];
    [DKUIHelper setupLayout:_mainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableView delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return channels.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = channels[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"channelCell"];
    
    UILabel *label = (UILabel*)[cell viewWithTag:2];
    [DKUIHelper setupLayoutLabel:label];
    label.text = [item objectForKey:@"channelName"];
    
    UIImageView *img = (UIImageView*)[cell viewWithTag:1];
    [img setImage:[self getIcon:[item objectForKey:@"channelCode"]]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *item = channels[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(DokuPay.class) bundle:[DKUIHelper frameworkBundle]];
    
    if ([[item objectForKey:@"channelCode"] isEqual: WalletChannelTypeCashBalance])
    {
        DKWalletCashBalanceViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKWalletCashBalanceViewController.class)];
        vc.conResult = _conResult;
        vc.walletChannel = item;
        vc.userDetail = _userDetail;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if ([[item objectForKey:@"channelCode"] isEqualToString:WalletChannelTypeCreditCard])
    {
        if ([item objectForKey:@"details"] && [[item objectForKey:@"details"] count] > 0)
        {
            DKWalletCreditCardViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKWalletCreditCardViewController.class)];
            vc.conResult = _conResult;
            vc.walletChannel = item;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            DKCCFormViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKCCFormViewController.class)];
            vc.userDetail = _userDetail;
            vc.isRegister = true;
            vc.walletChannel = item;
            vc.conResult = _conResult;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}


-(void)setupData
{
    _accountLabel.text = [resDataDw objectForKey:@"customerName"];
}

-(NSArray*)getChannels
{
    return [resDataDw objectForKey:@"listPaymentChannel"];
}

-(void)dismissDokuPay
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(UIImage*)getIcon:(NSString*)channelCode
{
    UIImage *img = nil;
    
    if ([channelCode isEqualToString:@"01"]) {
        img = [UIImage imageNamed:@"DokuPay.bundle/ico_pc_wallet.png"];
    }
    else if ([channelCode isEqualToString:@"02"])
    {
        img = [UIImage imageNamed:@"DokuPay.bundle/ico_pc_cc.png"];
    }
    
    return img;
}

@end
