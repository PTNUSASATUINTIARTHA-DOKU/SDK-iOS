//
//  DKMandiriClickpayViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 5/18/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DKMandiriClickpayViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *cardNumberField;
@property (weak, nonatomic) IBOutlet UITextField *challangeCode1;
@property (weak, nonatomic) IBOutlet UITextField *challangeCode2;
@property (weak, nonatomic) IBOutlet UITextField *challangeCode3;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UITextField *responseValue;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end
