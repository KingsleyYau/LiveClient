//
//  RegisterPhoneViewController.h
//  livestream
//
//  Created by Max on 2017/5/22.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"

@interface RegisterPhoneViewController : KKViewController

@property (weak) IBOutlet BLTextField* textFieldCountry;
@property (weak) IBOutlet BLTextField* textFieldZone;
@property (weak) IBOutlet BLTextField* textFieldPhone;
@property (weak) IBOutlet UIButton* btnNext;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;

/**
 *  点击下一步
 *
 *  @param sender 响应控件
 */
- (IBAction)nextAction:(id)sender;

@end
