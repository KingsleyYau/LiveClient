//
//  LSCreditView.h
//  livestream
//
//  Created by Calvin on 2019/9/6.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSCreditViewDelegate <NSObject>

- (void)creditViewDidAddCredit;

@end

@interface LSCreditView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) id<LSCreditViewDelegate> delegate;


+ (instancetype)initLSCreditView;
- (void)showLSCreditViewInView:(UIView *)view;
- (void)removeShowCreditView;
@end

