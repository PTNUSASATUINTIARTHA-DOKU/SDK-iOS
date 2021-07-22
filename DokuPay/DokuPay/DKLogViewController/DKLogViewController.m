//
//  DKLogViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 6/23/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKLogViewController.h"

@interface DKLogViewController ()

@end

@implementation DKLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _logView.text = [NSString stringWithFormat:@"%@", _logObject];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
