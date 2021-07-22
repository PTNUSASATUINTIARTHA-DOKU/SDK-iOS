//
//  DKMandiriClickpayViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/18/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKMandiriClickpayViewController.h"
#import "DKUIHelper.h"
#import "DKUtils.h"
#import "DokuPay.h"

@interface DKMandiriClickpayViewController () <UITextFieldDelegate>
{
    NSString *previousTextFieldContent;
    UITextRange *previousSelection;
}
@end

@implementation DKMandiriClickpayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Mandiri Clickpay";
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
    
    UIBarButtonItem *backItem = [DKUIHelper barButtonBack:self selector:@selector(dismissDokuPay) withTintColor:self.navigationController.navigationBar.tintColor];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.items = @[[[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)]];
    [numberToolbar sizeToFit];
    _responseValue.inputAccessoryView = numberToolbar;
    _cardNumberField.inputAccessoryView = numberToolbar;
    
    [_cardNumberField addTarget:self
                     action:@selector(reformatAsCardNumber:)
           forControlEvents:UIControlEventEditingChanged];
    
    _challangeCode3.text = [DKUtils getRandomNumber:8];
    
    DKPaymentItem *paymentItem = [[DokuPay sharedInstance] paymentItem];
    _challangeCode2.text = [NSString stringWithFormat:@"%ld", (long)[paymentItem.dataAmount integerValue]];
    
    
    [DKUIHelper setButtonRounded:_submitBtn withBorderColor:[UIColor redColor]];
    
    
    [DKUIHelper setupLayoutBG:self.view];
    [DKUIHelper setupLayout:_mainView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)doneWithNumberPad
{
    [_cardNumberField resignFirstResponder];
    [_responseValue resignFirstResponder];
}

-(void)dismissDokuPay
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tapSubmit:(id)sender
{
    if (![self isValid])
        return;
    
    NSString *amount = [[_challangeCode2.text componentsSeparatedByCharactersInSet:
      [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
     componentsJoinedByString:@""];
    
    NSDictionary *dict = @{@"challenge1": _challangeCode1.text,
                           @"challenge2": amount,
                           @"challenge3": _challangeCode3.text,
                           @"debitCard": [_cardNumberField.text stringByReplacingOccurrencesOfString:@"-" withString:@""],
                           @"responseValue": _responseValue.text};
    [[DokuPay sharedInstance] onMandiriSuccess:dict];
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
    if ([textField isEqual:_cardNumberField])
    {
        previousTextFieldContent = textField.text;
        previousSelection = textField.selectedTextRange;
        
        NSString *number = [textField.text stringByAppendingString:string];
        NSString *numberClean = [number stringByReplacingOccurrencesOfString:@"-" withString:@""];
        if (numberClean.length == 16) {
            _challangeCode1.text = [numberClean substringWithRange:NSMakeRange(6, 10)];
        }
    }
    
    return YES;
}

-(BOOL)isValid
{
    if (_cardNumberField.text.length != 19)
    {
        UIAlertController *alertControl;
        if (_cardNumberField.text.length == 0) {
            alertControl = [DKUIHelper alertView:@"This field is required" withTitle:nil];
        }
        else
        {
            alertControl = [DKUIHelper alertView:@"Debit number is invalid" withTitle:nil];
        }
        
        [_cardNumberField becomeFirstResponder];
        [self presentViewController:alertControl animated:YES completion:nil];
        
        return NO;
    }
    
    return YES;
}


#pragma mark - handle keyboard
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:_responseValue]) {
        [textField resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:_responseValue]) {
        [self animateTextField:textField up:YES];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:_responseValue]) {
        [self animateTextField:textField up:NO];
    }
}

-(void)animateTextField:(UITextField*)textField up:(BOOL)up
{
    const int movementDistance = -230; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

@end
