//
//  LSTipsDialogView.h
//  livestream
//
//  Created by Albert on 2020/8/7.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSTipsDialogView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIView *bgView;

+ (LSTipsDialogView *)tipsDialogView;
- (void)showDialogTip:(UIView *)view tipText:(NSString *)tip;

@end

NS_ASSUME_NONNULL_END
