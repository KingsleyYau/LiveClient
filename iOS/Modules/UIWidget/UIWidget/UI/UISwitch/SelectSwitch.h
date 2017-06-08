//
//  SelectSwitch.h
//  自定义UISwitch
//
//  Created by test on 16/5/12.
//  Copyright © 2016年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectSwitch : UIControl

/** 选择 */
@property (nonatomic,assign) BOOL isYes;
/** no */
@property (nonatomic,strong) UILabel *noLabel;
/** yes */
@property (nonatomic,strong) UILabel *yesLabel;
/** 背景图 */
@property (nonatomic,strong) UIImageView *bgView;
/** 圆角 */
@property (nonatomic,assign) CGFloat cornerRadius;


- (id)initWithFrame:(CGRect)frame;




@end
