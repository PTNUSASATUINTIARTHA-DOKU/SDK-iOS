//
//  DKVAResultViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 6/2/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKVAResultViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *paymentCode;

@property (weak, nonatomic) IBOutlet UILabel *invoiceLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIView *howToPayView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) NSDictionary *conResult;

@end
