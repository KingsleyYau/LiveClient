//
//  UpdateDialog.h
//  livestream
//
//  Created by Calvin on 2018/1/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateDialog : UIView 

@property (nonatomic, weak) IBOutlet UILabel* tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *notBtn;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;


+ (UpdateDialog *)dialog;
- (void)showDialog:(UIView *)view  actionBlock:(void(^)())actionBlock;
- (void)showDialog:(UIView *)view cancelBlock:(void(^)())cancelBlock actionBlock:(void(^)())actionBlock;
@end
