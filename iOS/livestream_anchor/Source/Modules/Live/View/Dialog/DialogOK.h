//
//  DialogOK.h
//  livestream
//
//  Created by Max on 2017/9/11.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogOK : UIView

@property (nonatomic, weak) IBOutlet UILabel* tipsLabel;
@property (nonatomic, weak) IBOutlet UIButton *okButton;

+ (DialogOK *)dialog;
- (void)showDialog:(UIView *)view actionBlock:(void(^)())actionBlock;

@end
