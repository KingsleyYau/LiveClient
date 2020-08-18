//
//  LSPurchaseCreditsView.h
//  livestream
//
//  Created by Randy_Fan on 2020/4/9.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LSPurchaseCreditsViewDelegate <NSObject>

- (void)purchaseDidAction;

@end

@interface LSPurchaseCreditsView : UIView
@property (weak, nonatomic) IBOutlet UILabel *bigTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *purchaseView;

@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UILabel *creditLabel;

@property (weak, nonatomic) IBOutlet UIButton *purchaseBtn;

@property (weak, nonatomic) IBOutlet UIButton *laterBtn;


@property (weak, nonatomic) id<LSPurchaseCreditsViewDelegate> delegate;

- (void)showLSCreditViewInView:(UIView *)view;
- (void)removeShowCreditView;

- (void)setupCreditView:(NSString *)url;
- (void)setupCreditTipIsAccept:(BOOL)isAccept name:(NSString *)name credit:(double)credit;
@end

NS_ASSUME_NONNULL_END
