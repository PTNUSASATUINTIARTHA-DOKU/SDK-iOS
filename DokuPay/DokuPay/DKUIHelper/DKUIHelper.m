//
//  DKUIHelper.m
//  DokuPay
//
//  Created by IHsan HUsnul on 4/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKUIHelper.h"
#import "DKUtils.h"
#import "DokuPay.h"

@implementation DKUIHelper

+(UIAlertController*)alertView:(NSString *)message withTitle:(NSString *)title
{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    
    [alertController addAction:okAction];
    
    return alertController;
}

+ (UIColor *)colorFromHexColor: (NSString *) hexColor
{
    NSUInteger red, green, blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0) green:(float)(green/255.0) blue:(float)(blue/255.0) alpha:1.0];
}

+ (void)setButtonRounded:(UIView *)view withBorderColor:(UIColor *)color
{
    view.layer.cornerRadius = 5;
    if (color == nil)
        view.layer.borderColor = color.CGColor;
    else
        view.layer.borderColor = [UIColor redColor].CGColor;
    
    view.layer.borderWidth = 1.0;
    view.layer.masksToBounds = YES;
}

+(NSBundle *)frameworkBundle
{
    static NSBundle* frameworkBundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        NSString* mainBundlePath = [[NSBundle mainBundle] resourcePath];
        NSString* frameworkBundlePath = [mainBundlePath stringByAppendingPathComponent:@"DokuPay.bundle"];
        frameworkBundle = [NSBundle bundleWithPath:frameworkBundlePath];
        [frameworkBundle load];
    });
    
    return frameworkBundle;
}

+(void)saveCachePairingCode:(NSString*)string
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:string forKey:@"res_pairing_code"];
    [user synchronize];
}

+(NSString*)getCachePairingCode
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *pairingCode = [user objectForKey:@"res_pairing_code"];
    return pairingCode.length > 0 ? pairingCode : @"";
}

+(void)saveCacheTokenID:(NSString *)string
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:string forKey:@"res_token_id"];
    [user synchronize];
}

+(NSString*)getCacheTokenID
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *pairingCode = [user objectForKey:@"res_token_id"];
    return pairingCode.length > 0 ? pairingCode : @"";
}

+(NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint fromDictionary:(NSDictionary*)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"error :%@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+(BOOL)emailValidation:(UIViewController*)viewControl textField:(UITextField*)emailField
{
    BOOL valid = YES;
    
    valid = [DKUtils isEmail:emailField.text];
    if (!valid) {
        UIAlertController *alertControl = [UIAlertController
                                           alertControllerWithTitle:nil
                                           message:@"This email address is invalid"
                                           preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action)
                                   {
                                       [emailField becomeFirstResponder];
                                       
                                       [alertControl dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        [alertControl addAction:okAction];
        [viewControl presentViewController:alertControl animated:YES completion:nil];
    }
    
    return valid;
}

+(NSString*)numberToCurrency:(NSNumber*)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"id_ID"];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
//    formatter.maximumIntegerDigits = 3;
//    formatter.minimumFractionDigits = 3;
//    formatter.maximumFractionDigits = 8;
//    formatter.usesSignificantDigits = NO;
//    formatter.usesGroupingSeparator = YES;
//    formatter.groupingSeparator = @",";
//    formatter.decimalSeparator = @".";
    
    return [formatter stringFromNumber:number];
}


#pragma mark - UITextField 
-(void)textField:(UITextField*)textField asCardNumber:(NSString*)previousTextFieldContent withPrevRange:(UITextRange*)previousSelection
{
    // In order to make the cursor end up positioned correctly, we need to
    // explicitly reposition it after we inject spaces into the text.
    // targetCursorPosition keeps track of where the cursor needs to end up as
    // we modify the string, and at the end we set the cursor position to it.
    NSUInteger targetCursorPosition =
    [textField offsetFromPosition:textField.beginningOfDocument
                  toPosition:textField.selectedTextRange.start];
    
    NSString *cardNumberWithoutSpaces =
    [self removeNonDigits:textField.text
andPreserveCursorPosition:&targetCursorPosition];
    
    if ([cardNumberWithoutSpaces length] > 16) {
        // If the user is trying to enter more than 19 digits, we prevent
        // their change, leaving the text field in  its previous state.
        // While 16 digits is usual, credit card numbers have a hard
        // maximum of 19 digits defined by ISO standard 7812-1 in section
        // 3.8 and elsewhere. Applying this hard maximum here rather than
        // a maximum of 16 ensures that users with unusual card numbers
        // will still be able to enter their card number even if the
        // resultant formatting is odd.
        [textField setText:previousTextFieldContent];
        textField.selectedTextRange = previousSelection;
        return;
    }
    
    NSString *cardNumberWithSpaces =
    [self insertSpacesEveryFourDigitsIntoString:cardNumberWithoutSpaces
                      andPreserveCursorPosition:&targetCursorPosition];
    
    textField.text = cardNumberWithSpaces;
    UITextPosition *targetPosition =
    [textField positionFromPosition:[textField beginningOfDocument]
                        offset:targetCursorPosition];
    
    [textField setSelectedTextRange:
     [textField textRangeFromPosition:targetPosition
                      toPosition:targetPosition]
     ];
}

// Removes non-digits from the string, decrementing `cursorPosition` as
// appropriate so that, for instance, if we pass in `@"1111 1123 1111"`
// and a cursor position of `8`, the cursor position will be changed to
// `7` (keeping it between the '2' and the '3' after the spaces are removed).
- (NSString *)removeNonDigits:(NSString *)string
    andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSUInteger originalCursorPosition = *cursorPosition;
    NSMutableString *digitsOnlyString = [NSMutableString new];
    for (NSUInteger i=0; i<[string length]; i++) {
        unichar characterToAdd = [string characterAtIndex:i];
        if (isdigit(characterToAdd)) {
            NSString *stringToAdd =
            [NSString stringWithCharacters:&characterToAdd
                                    length:1];
            
            [digitsOnlyString appendString:stringToAdd];
        }
        else {
            if (i < originalCursorPosition) {
                (*cursorPosition)--;
            }
        }
    }
    
    return digitsOnlyString;
}

// Inserts spaces into the string to format it as a credit card number,
// incrementing `cursorPosition` as appropriate so that, for instance, if we
// pass in `@"111111231111"` and a cursor position of `7`, the cursor position
// will be changed to `8` (keeping it between the '2' and the '3' after the
// spaces are added).
- (NSString *)insertSpacesEveryFourDigitsIntoString:(NSString *)string
                          andPreserveCursorPosition:(NSUInteger *)cursorPosition
{
    NSMutableString *stringWithAddedSpaces = [NSMutableString new];
    NSUInteger cursorPositionInSpacelessString = *cursorPosition;
    for (NSUInteger i=0; i<[string length]; i++) {
        if ((i>0) && ((i % 4) == 0)) {
            [stringWithAddedSpaces appendString:@"-"];
            if (i < cursorPositionInSpacelessString) {
                (*cursorPosition)++;
            }
        }
        unichar characterToAdd = [string characterAtIndex:i];
        NSString *stringToAdd =
        [NSString stringWithCharacters:&characterToAdd length:1];
        
        [stringWithAddedSpaces appendString:stringToAdd];
    }
    
    return stringWithAddedSpaces;
}

+(UIBarButtonItem*)barButtonPrice
{
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    rightLabel.font = [UIFont systemFontOfSize:14];
    NSInteger amountInt = [[[DokuPay sharedInstance] paymentItem].dataAmount integerValue];
    NSNumber *amount = [NSNumber numberWithInteger:amountInt];
    rightLabel.text = [NSString stringWithFormat:@"Rp %@", [DKUIHelper numberToCurrency:amount]];
    [rightLabel sizeToFit];
    rightLabel.textColor = [[DokuPay sharedInstance] navController].navigationBar.tintColor;
    return [[UIBarButtonItem alloc] initWithCustomView:rightLabel];
}

+(void)setupLayoutBG:(UIView*)view
{
    DKLayout *layout = [[DokuPay sharedInstance] layout];
    
    if (layout.BGColor) {
        [view setBackgroundColor:layout.BGColor];
    }
}

+(void)setupLayout:(UIView*)mainView
{
    DKLayout *layout = [[DokuPay sharedInstance] layout];
    
    mainView.backgroundColor = [UIColor clearColor];
    for (id view in [mainView subviews])
    {
        if ([view isKindOfClass:[UILabel class]])
        {
            [DKUIHelper setupLayoutLabel:view];
        }
        
        if ([view isKindOfClass:[UITextField class]])
        {
            if (layout.fontType) {
                [view setFont:layout.fontType];
            }
            
            if (layout.fieldTextColor) {
                [[UITextField appearance] setTextColor:layout.fieldTextColor];
            }
        }
        
        if ([view isKindOfClass:[UIButton class]])
        {
            if (layout.fontType) {
                [view setFont:layout.fontType];
            }
            
            if (layout.buttonTextColor) {
                [view setTitleColor:layout.buttonTextColor forState:UIControlStateNormal];
            }
            
            if (layout.buttonBGColor) {
                [view setBackgroundColor:layout.buttonBGColor];
            }
        }
    }
}

+(void)setupLayoutViewButton:(UIView*)button
{
    DKLayout *layout = [[DokuPay sharedInstance] layout];
    
    button.backgroundColor = layout.buttonBGColor;
    for (id view in [button subviews])
    {
        if ([view isKindOfClass:[UILabel class]])
        {
            [DKUIHelper setupLayoutLabel:view];
        }
    }
}

+(void)setupLayoutLabel:(UILabel*)label
{
    DKLayout *layout = [[DokuPay sharedInstance] layout];
    
    if (layout.fontType) {
        [label setFont:layout.fontType];
    }
    
    if (layout.buttonTextColor) {
        [label setTextColor:layout.buttonTextColor];
        [label setBackgroundColor:[UIColor clearColor]];
    }
}



+(UIBarButtonItem*)barButtonBack:(id)target selector:(SEL)selector withTintColor:(UIColor*)tintColor
{
    UIImage *icon = [[UIImage imageNamed:@"DokuPay.bundle/back.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:icon forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 52, 41)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 44)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 1.1, 50, 40)];
    [label setTextColor:tintColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:@"Back"];
    [button addSubview:label];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    return backItem;
}

+(UIActivityIndicatorView*)addIndicatorSubView:(UIView*)view
{
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.backgroundColor = [UIColor lightGrayColor];
    
    CGRect frame = indicator.frame;
    frame.size = CGSizeMake(125, 110);
    indicator.frame = frame;
    
    indicator.layer.cornerRadius = 15;
    indicator.layer.masksToBounds = YES;
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13];
    label.text = @"Mohon Tunggu...";
    [label sizeToFit];
    label.center = indicator.center;
    CGRect frameLbl = label.frame;
    frameLbl.origin.y += 32;
    label.frame = frameLbl;
    
    [indicator addSubview:label];
    
    indicator.center = view.center;
    [view addSubview:indicator];
    
    return indicator;
}


@end
