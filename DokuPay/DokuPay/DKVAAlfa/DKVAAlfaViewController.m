//
//  DKVAAlfaViewController.m
//  DokuPay
//
//  Created by IHsan HUsnul on 5/18/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import "DKVAAlfaViewController.h"
#import "DKUIHelper.h"
#import "Constant.h"
#import "DokuPay.h"
#import "DKVAAlfaResultViewController.h"
#import "DKNetworking.h"

@interface DKVAAlfaViewController ()
{
    DKNetworking *networking;
    UIActivityIndicatorView *indicator;
}
@end

@implementation DKVAAlfaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Convenience Store";
    
//    self.navigationItem.rightBarButtonItem = [DKUIHelper barButtonPrice];
    
    UIBarButtonItem *backItem = [DKUIHelper barButtonBack:self selector:@selector(dismissDokuPay) withTintColor:self.navigationController.navigationBar.tintColor];
    
    self.navigationItem.leftBarButtonItem = backItem;
    
    [DKUIHelper setButtonRounded:_getCodeBtn withBorderColor:[UIColor redColor]];
    
    [DKUIHelper setupLayoutBG:self.view];
    [DKUIHelper setupLayout:_mainView];
    
    indicator = [DKUIHelper addIndicatorSubView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissDokuPay
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)tapGetPaymentCode:(id)sender
{
    [self doGetPaymentCode];
}

-(void)doGetPaymentCode
{
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *bodyString = [NSString stringWithFormat:@"data={\"req_device_id\": \"%@\"}", uuid];
    
    if (!networking) {
        networking = [[DKNetworking alloc] init];
    }
    
    [indicator startAnimating];
    
    [networking requestParams:bodyString url:URL_RequestVACode withCallBack:^(NSError *err, id response) {
        
        NSLog(@"RESPONSE va code, %@", response);
        [indicator stopAnimating];
        
        if (response) {
            NSDictionary *responseDict = (NSDictionary*)response;
            if (![responseDict isEqual:[NSNull null]] &&
                [[responseDict objectForKey:@"res_response_code"] isEqualToString:@"0000"])
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:NSStringFromClass(DokuPay.class) bundle:[DKUIHelper frameworkBundle]];
                DKVAAlfaResultViewController *vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(DKVAAlfaResultViewController.class)];
                vc.conResult = responseDict;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else
        {
            [[DokuPay sharedInstance] onError:err];
        }
    }];
}

@end
