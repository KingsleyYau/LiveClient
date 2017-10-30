//
//  ListViewController.h
//  UIWidget
//
//  Created by test on 2017/9/25.
//  Copyright © 2017年 drcom. All rights reserved.
//

#import "LSViewController.h"

@interface LSListViewController : LSViewController


/** 错误页 */
@property (nonatomic, strong) UIView* failView;

/** 错误提示 */
@property (nonatomic, strong) UILabel *failTips;

/** 重试按钮 */
@property (nonatomic, strong) UIButton *failBtn;

/** 错误提示文字 */
@property (nonatomic, copy) NSString *failTipsText;
/** 错误按钮文字 */
@property (nonatomic, copy) NSString *failBtnText;
@property (nonatomic, assign) SEL delegateSelect;
- (void)reloadFailViewContent;

@end
