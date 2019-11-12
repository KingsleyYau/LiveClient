//
//  LSUserSettingHeadView.h
//  livestream
//
//  Created by Calvin on 2018/9/25.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LSUserSettingHeadViewDelegate <NSObject>

- (void)settingHeadViewBackDid;
- (void)settingBackgroundDid;
- (void)settingHeadImageDid;
- (void)settingHeadEditDid;

@end

@interface LSUserSettingHeadView : UIView 
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) id<LSUserSettingHeadViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *headBackground;
- (void)reloadHeadImage:(NSString *)photoUrl;
@end
