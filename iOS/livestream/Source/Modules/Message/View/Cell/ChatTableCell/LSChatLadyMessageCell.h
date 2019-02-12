//
//  LSChatLadyMessageCell.h
//  livestream
//
//  Created by Randy_Fan on 2018/9/29.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYText.h>

@interface LSChatLadyMessageCell : UITableViewCell

@property (nonatomic, strong) YYLabel *messageLabel;

@property (nonatomic, strong) UIImageView* backgroundImageView;

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
