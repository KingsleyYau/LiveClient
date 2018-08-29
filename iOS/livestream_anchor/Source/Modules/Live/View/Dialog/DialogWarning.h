//
//  DialogWarning.h
//  livestream
//
//  Created by Max on 2017/9/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogWarning : UIView

@property (nonatomic, weak) IBOutlet UILabel* tipsLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;


+ (DialogWarning *)dialog;
- (void)showDialog:(UIView *)view  actionBlock:(void(^)())actionBlock;

- (void)hidenDialog;
@end
