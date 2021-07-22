//
//  DKWalletLoginViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 5/9/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKUserDetail.h"

@interface DKWalletLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic, strong) NSDictionary *conResult;
@property (nonatomic, strong) DKUserDetail *userDetail;

@end
