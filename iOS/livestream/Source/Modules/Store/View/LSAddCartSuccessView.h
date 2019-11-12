//
//  LSAddCartSuccessView.h
//  livestream
//
//  Created by Calvin on 2019/10/12.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSAddCartSuccessViewDelegate <NSObject>

- (void)addCartSuccessViewDidCheckoutBtn;
- (void)addCartSuccessViewDidContiuneBtn;
@end
 

@interface LSAddCartSuccessView : UIView 

@property (weak, nonatomic) IBOutlet UIView *tipContentView;
@property (weak, nonatomic) IBOutlet UIButton *tipCheckoutBtn;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *successIconW;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) id<LSAddCartSuccessViewDelegate> delegate;
@end

 
