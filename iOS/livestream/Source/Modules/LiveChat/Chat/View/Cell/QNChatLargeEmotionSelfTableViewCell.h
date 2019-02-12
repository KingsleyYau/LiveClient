//
//  QNChatLargeEmotionSelfTableViewCell.h
//  dating
//
//  Created by test on 16/9/22.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QNLargeEmotionShowView.h"

@class QNChatLargeEmotionSelfTableViewCell;
@protocol ChatLargeEmotionSelfTableViewCellDelegate <NSObject>

@optional
/**  点击重试   */
- (void)chatLargeEmotionSelfTableViewCell:(QNChatLargeEmotionSelfTableViewCell *)cell DidClickRetryBtn:(UIButton *)retryBtn;

@end


@interface QNChatLargeEmotionSelfTableViewCell : UITableViewCell


/** 代理 */
@property (nonatomic,weak) id<ChatLargeEmotionSelfTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet QNLargeEmotionShowView *largeEmotionImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *sendingLoadingView;
@property (weak, nonatomic) IBOutlet UIButton *retryBtn;
+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
