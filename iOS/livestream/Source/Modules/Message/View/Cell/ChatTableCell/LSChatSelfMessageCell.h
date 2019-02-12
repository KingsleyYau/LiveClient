//
//  LSChatSelfMessageCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/9/28.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYText.h>

@class LSChatSelfMessageCell;
@protocol LSChatSelfMessageCellDelegate <NSObject>
@optional
- (void)chatTextSelfRetryButtonClick:(LSChatSelfMessageCell *)cell sendErr:(NSInteger)sendErr;
@end

@interface LSChatSelfMessageCell : UITableViewCell

@property (nonatomic, strong) YYLabel *messageLabel;

@property (nonatomic, strong) UIActivityIndicatorView* activityIndicatorView;
@property (nonatomic, strong) UIButton* retryButton;
@property (nonatomic, strong) UIImageView* backgroundImageView;

/** 代理 */
@property (nonatomic,weak) id<LSChatSelfMessageCellDelegate> delegate;

/**
 *  cell标识符
 */
+ (NSString *)cellIdentifier;

/**
 计算cell的高度
 
 @param width 列表宽度
 @param detailString 富文本
 @return cell高度
 */
+ (NSInteger)cellHeight:(CGFloat)width detailString:(NSAttributedString *)detailString;

/**
 更新文本frame值以及显示文本
 
 @param subWidth 列表宽度
 @param detailString 富文本
 */
- (void)updataChatMessage:(CGFloat)subWidth detailString:(NSAttributedString *)detailString;

/**
 *  cell的重用
 */
+ (id)getUITableViewCell:(UITableView*)tableView;

@end
