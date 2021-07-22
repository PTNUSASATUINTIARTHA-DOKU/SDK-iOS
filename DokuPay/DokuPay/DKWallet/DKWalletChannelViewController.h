//
//  DKWalletChannelViewController.h
//  DokuPay
//
//  Created by IHsan HUsnul on 5/9/16.
//  Copyright © 2016 Doku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKUserDetail.h"

@interface DKWalletChannelViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSDictionary *conResult;
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic, strong) DKUserDetail *userDetail;

@end
