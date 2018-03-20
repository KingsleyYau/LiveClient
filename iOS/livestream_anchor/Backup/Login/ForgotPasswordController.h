//
//  ForgotPasswordController.h
//  livestream
//
//  Created by randy on 17/5/31.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordController : KKViewController
@property (weak, nonatomic) IBOutlet BLTextField *textFieldCountry;
@property (weak, nonatomic) IBOutlet BLTextField *textFieldZone;
@property (weak, nonatomic) IBOutlet BLTextField *textFieldPhone;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;

- (IBAction)forgorNext:(id)sender;

@end
