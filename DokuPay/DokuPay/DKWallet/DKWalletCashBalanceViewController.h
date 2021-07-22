//
//  DKWalletCashBalanceViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 6/6/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKUserDetail.h"
#import "IQDropDownTextField.h"

@interface DKWalletCashBalanceViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *cashBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *pinField;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) NSDictionary *conResult;
@property (nonatomic, strong) NSDictionary *walletChannel;
@property (nonatomic, strong) DKUserDetail *userDetail;
@property (strong, nonatomic) IBOutlet IQDropDownTextField *voucherField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraintPIN; // 100 & 10
@property (weak, nonatomic) IBOutlet UITextField *pembayaranField;
@property (weak, nonatomic) IBOutlet UITextField *voucherSelectedField;
@property (weak, nonatomic) IBOutlet UITextField *totalPembayaranField;
@property (weak, nonatomic) IBOutlet UIView *voucherView;
@property (weak, nonatomic) IBOutlet UIView *pembayaranView;
@property (weak, nonatomic) IBOutlet UIView *voucherSelectedView;
@property (weak, nonatomic) IBOutlet UIView *totalPembayaranView;

@end
