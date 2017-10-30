//
//  JDAlertView.h
//  livestream
//
//  Created by Calvin on 17/10/13.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JDAlertView : UIView

@property (weak, nonatomic) IBOutlet UIView *alertView;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UIButton *noBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (instancetype)initWithMessage:(NSString *)message noButtonTitle:(NSString *)noMsg yesButtonTitle:(NSString *)yesMsg onBlock:(void(^)())onBlock yesBlock:(void(^)())yesBlock;
- (void)show;
@end
