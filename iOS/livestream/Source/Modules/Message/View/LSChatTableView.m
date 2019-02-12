//
//  LSChatTableView.m
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatTableView.h"
#import "LSDateTool.h"
#import "LSChatEmotionManager.h"

@implementation LSChatTableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
        [self registerClass:[LSChatSystemTipsTableViewCell class] forCellReuseIdentifier:[LSChatSystemTipsTableViewCell cellIdentifier]];
        [self registerClass:[LSChatAddCreditsTableViewCell class] forCellReuseIdentifier:[LSChatAddCreditsTableViewCell cellIdentifier]];
        [self registerClass:[LSChatTimeTableViewCell class] forCellReuseIdentifier:[LSChatTimeTableViewCell cellIdentifier]];
        [self registerClass:[LSChatSelfMessageCell class] forCellReuseIdentifier:[LSChatSelfMessageCell cellIdentifier]];
        [self registerClass:[LSChatLadyMessageCell class] forCellReuseIdentifier:[LSChatLadyMessageCell cellIdentifier]];
    }
    return self;
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.msgArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    LSMessage* item = [self.msgArray objectAtIndex:indexPath.row];
    switch (item.msgType) {
        case LMMT_Text: {
            NSMutableAttributedString *attributeStr = [[LSChatEmotionManager emotionManager] parseMessageAttributedTextEmotion:[[NSMutableAttributedString alloc] initWithAttributedString:item.attText] font:[UIFont boldSystemFontOfSize:15]];
            if (item.sendType == LMSendType_Send) {
                height = [LSChatSelfMessageCell cellHeight:self.frame.size.width detailString:attributeStr];
            } else {
                height = [LSChatLadyMessageCell cellHeight:self.frame.size.width detailString:attributeStr];
            }
        }break;
            
        case LMMT_SystemWarn: {
            height = [LSChatSystemTipsTableViewCell cellHeight:self.frame.size.width detailString:item.attText];
        }break;
            
        case LMMT_Warning: {
            height = [LSChatAddCreditsTableViewCell cellHeight];
        } break;
            
        case LMMT_Time: {
            height = [LSChatTimeTableViewCell cellHeight];
        }break;
            
        default: {
            height = 50;
        }break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    LSMessage* item = [self.msgArray objectAtIndex:indexPath.row];
    switch (item.msgType) {
        case LMMT_Text: {
            // 文本转换
            NSMutableAttributedString *attributeStr = [[LSChatEmotionManager emotionManager] parseMessageAttributedTextEmotion:[[NSMutableAttributedString alloc] initWithAttributedString:item.attText] font:[UIFont boldSystemFontOfSize:15]];
            
            if (item.sendType == LMSendType_Send) {
                LSChatSelfMessageCell *cell = [LSChatSelfMessageCell getUITableViewCell:tableView];
                [cell updataChatMessage:self.frame.size.width detailString:attributeStr];
                
                result = cell;
                // 用于点击重发按钮
                result.tag = indexPath.row;
                cell.delegate = self;
                switch (item.statusType) {
                    case LMStatusType_Processing: {
                        // 发送中
                        cell.activityIndicatorView.hidden = NO;
                        [cell.activityIndicatorView startAnimating];
                        cell.retryButton.hidden = YES;
                    }break;
                    case LMStatusType_Finish: {
                        // 发送成功
                        cell.activityIndicatorView.hidden = YES;
                        cell.retryButton.hidden = YES;
                    }break;
                    case LMStatusType_Fail:{
                        // 发送失败
                        cell.activityIndicatorView.hidden = YES;
                        cell.retryButton.hidden = NO;
                        cell.retryButton.tag = item.sendErr;
                    }break;
                    default: {
                        // 未知
                        cell.activityIndicatorView.hidden = YES;
                        cell.retryButton.hidden = YES;
                    }break;
                }
            } else {
                LSChatLadyMessageCell *cell = [LSChatLadyMessageCell getUITableViewCell:tableView];
                [cell updataChatMessage:self.frame.size.width detailString:attributeStr];
                result = cell;
            }
        }break;
            
        case LMMT_SystemWarn: {
            LSChatSystemTipsTableViewCell *cell = [LSChatSystemTipsTableViewCell getUITableViewCell:tableView];
            if (item.attText.length > 0) {
                cell.detailLabel.attributedText = item.attText;
            }
            result = cell;
        }break;
            
        case LMMT_Warning: {
            LSChatAddCreditsTableViewCell *cell = [LSChatAddCreditsTableViewCell getUITableViewCell:tableView];
            cell.delegate = self;
            result = cell;
        }break;
            
        case LMMT_Time: {
            LSChatTimeTableViewCell *cell = [LSChatTimeTableViewCell getUITableViewCell:tableView];
            if (item.timeMsgItem.msgTime > 0) {
                NSDate *date = [NSDate dateWithTimeIntervalSince1970:item.timeMsgItem.msgTime];
                LSDateTool *tool =  [[LSDateTool alloc] init];
                cell.timeLabel.text = [tool showChatListTimeTextOfDate:date];
            }
            result = cell;
        }break;
            
        default: {
            LSChatSelfMessageCell *cell = [LSChatSelfMessageCell getUITableViewCell:tableView];
            result = cell;
        }break;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.tableViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}

#pragma mark - 点击消息提示按钮
- (void)chatTextSelfRetryButtonClick:(LSChatSelfMessageCell *)cell sendErr:(NSInteger)sendErr{
    if ([self.tableViewDelegate respondsToSelector:@selector(chatTextSelfRetryMessage:sendErr:)]) {
        [self.tableViewDelegate chatTextSelfRetryMessage:cell sendErr:sendErr];
    }
}

#pragma mark - LSChatAddCreditsTableViewCellDelegate
- (void)pushToAddCredites {
    if ([self.tableViewDelegate respondsToSelector:@selector(pushToAddCreditVC)]) {
        [self.tableViewDelegate pushToAddCreditVC];
    }
}

- (void)handleErrorMsg:(NSInteger)index {
    
}

@end
