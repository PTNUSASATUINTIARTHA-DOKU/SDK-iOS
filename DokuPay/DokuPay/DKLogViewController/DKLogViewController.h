//
//  DKLogViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 6/23/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DKLogViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (strong, nonatomic) id logObject;

@end
