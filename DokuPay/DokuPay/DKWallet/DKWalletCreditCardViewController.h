//
//  DKWalletCreditCardViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 6/6/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKWalletCreditCardViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *numberField;
@property (weak, nonatomic) IBOutlet UITextField *cvvField;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic, strong) NSDictionary *walletChannel;
@property (nonatomic, strong) NSDictionary *conResult;

-(void)doChecking3DSecure:(NSDictionary*)response;

@end
