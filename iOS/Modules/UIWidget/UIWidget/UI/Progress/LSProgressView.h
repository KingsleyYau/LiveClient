//
//  LSProgressView.h
//
//
//  Created by lance on 2018/2/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSProgressView : UIView
/**
 *  进度条高度
 */
@property (nonatomic) CGFloat progressHeight;

/**
 *  进度值
 */
@property (nonatomic) CGFloat progressValue;

/**
 *  进度条 progressView
 */
@property (nonatomic, strong) UIView *progressView;

@end
