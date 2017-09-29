//
//  TalentTipView.h
//  livestream
//
//  Created by Calvin on 17/9/21.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TalentTipView : UIView
@property (weak, nonatomic) IBOutlet UILabel *talentLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *requstBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

- (void)setTalentName:(NSString *)name;
- (void)setPriceNum:(NSString *)price;
@end
