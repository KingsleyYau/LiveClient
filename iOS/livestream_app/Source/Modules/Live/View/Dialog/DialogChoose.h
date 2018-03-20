//
//  DialogChoose.h
//  livestream
//
//  Created by Max on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMCheckBox.h"

@interface DialogChoose : UIView

@property (nonatomic, weak) IBOutlet UILabel* tipsLabel;
@property (nonatomic, weak) IBOutlet BEMCheckBox *checkBox;
@property (nonatomic, weak) IBOutlet UIButton *okButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *checkLabel;

+ (DialogChoose *)dialog;
- (void)hiddenCheckView;
- (void)showDialog:(UIView *)view cancelBlock:(void(^)())cancelBlock actionBlock:(void(^)())actionBlock;

@end
