//
//  DKUIHelper.h
//  DokuPay
//
//  Created by IHsan HUsnul on 4/27/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DKUIHelper : NSObject

+(UIAlertController*)alertView:(NSString *)message withTitle:(NSString *)title;
+(UIColor *)colorFromHexColor:(NSString *)hexColor;
+ (void)setButtonRounded:(UIView *)view withBorderColor:(UIColor *)color;
+(NSBundle *)frameworkBundle;


// cache
+(void)saveCachePairingCode:(NSString*)string;
+(NSString*)getCachePairingCode;

+(void)saveCacheTokenID:(NSString*)string;
+(NSString*)getCacheTokenID;
+(NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint fromDictionary:(NSDictionary*)dict;
+(BOOL)emailValidation:(UIViewController*)viewControl textField:(UITextField*)emailField;
+(NSString*)numberToCurrency:(NSNumber*)number;
+(UIBarButtonItem*)barButtonPrice;
+(void)setupLayoutBG:(UIView*)view;
+(void)setupLayout:(UIView*)mainView;
+(void)setupLayoutViewButton:(UIView*)button;
+(void)setupLayoutLabel:(UILabel*)label;
+(UIBarButtonItem*)barButtonBack:(id)target selector:(SEL)selector withTintColor:(UIColor*)tintColor;
+(UIActivityIndicatorView*)addIndicatorSubView:(UIView*)view;

-(void)textField:(UITextField*)textField asCardNumber:(NSString*)previousTextFieldContent withPrevRange:(UITextRange*)previousSelection;

@end
