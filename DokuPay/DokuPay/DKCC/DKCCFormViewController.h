//
//  DKCCFormViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 4/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DKUserDetail.h"


@interface DKCCFormViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *cvvField;
@property (weak, nonatomic) IBOutlet UITextField *expiryField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIImageView *vccInfoView;
@property (weak, nonatomic) IBOutlet UISwitch *saveSwitch;
@property (nonatomic, assign) BOOL isFirstToken;
@property (nonatomic, assign) BOOL isSecondToken;
@property (nonatomic, strong) NSDictionary *conResult;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *saveLabel;

@property (weak, nonatomic) IBOutlet UIView *mainSecondView;
@property (weak, nonatomic) IBOutlet UITextField *numberSecondField;
@property (weak, nonatomic) IBOutlet UITextField *cvvSecondField;
@property (weak, nonatomic) IBOutlet UIButton *submitSecondBtn;
@property (weak, nonatomic) IBOutlet UIImageView *icoSecondSuccess;
@property (strong, nonatomic) DKUserDetail *userDetail;

@property (nonatomic, assign) BOOL isRegister;
@property (nonatomic, strong) NSDictionary *walletChannel;

@end
