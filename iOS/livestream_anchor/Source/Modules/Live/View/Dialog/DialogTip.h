//
//  DialogTip.h
//  livestream
//
//  Created by randy on 2017/9/15.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogTip : UIView

@property (nonatomic, weak) IBOutlet UILabel* tipsLabel;

@property (nonatomic, assign) BOOL isShow;

+ (DialogTip *)dialogTip;
- (void)showDialogTip:(UIView *)view tipText:(NSString *)tip;
- (void)removeShow;
- (void)stopTimer;

@end
