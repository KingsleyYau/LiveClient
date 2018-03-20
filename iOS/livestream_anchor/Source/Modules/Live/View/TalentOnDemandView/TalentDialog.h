//
//  TalentDialog.h
//  livestream_anchor
//
//  Created by Calvin on 2018/3/5.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalentDialog : UIView 

@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIButton *declineBtn;
@property (weak, nonatomic) IBOutlet UIButton *acceptBtn;

+ (TalentDialog *)dialog;
- (void)showDialog:(UIView *)view declineBlock:(void(^)())declineBlock acceptBlock:(void(^)())acceptBlock;

- (void)setTalentName:(NSString *)name andRequestName:(NSString *)request;
@end
