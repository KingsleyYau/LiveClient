//
//  LSChatTableView.m
//  livestream
//
//  Created by Calvin on 2018/7/3.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSChatTableView.h"

@implementation LSChatTableView


- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
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
    switch (item.type) {
        case MessageTypeText:
        {
            if (item.sender == MessageSenderSelf) {
                CGSize viewSize = CGSizeMake(self.frame.size.width, [LSChatTextSelfTableViewCell cellHeight:self.frame.size.width detailString:item.attText]);
                height = viewSize.height;
            }
            else
            {
                CGSize viewSize = CGSizeMake(self.frame.size.width, [LSChatTextLadyTableViewCell cellHeight:self.frame.size.width detailString:item.attText]);
                height = viewSize.height;
            }
        }
            break;
        case MessageTypeSystemTips:
        {
            CGSize viewSize = CGSizeMake(self.frame.size.width, [LSChatSystemTipsTableViewCell cellHeight:self.frame.size.width detailString:item.attText]);
            height = viewSize.height;
        }
            break;
        case MessageTypeWarningTips:
        {
            height = [LSChatAddCreditsTableViewCell cellHeight];
        }
        default:
        {
            height = 50;
        }
            break;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    LSMessage* item = [self.msgArray objectAtIndex:indexPath.row];
    switch (item.type) {
        case MessageTypeText:
        {
            if (item.sender == MessageSenderSelf) {
                LSChatTextSelfTableViewCell* cell = [LSChatTextSelfTableViewCell getUITableViewCell:tableView];
                result = cell;
                // 用于点击重发按钮
                result.tag = indexPath.row;
                cell.delegate = self;
                cell.detailLabel.attributedText = item.attText;
                //cell.detailLabel.text = item.text;
                switch (item.status) {
                    case MessageStatusProcessing: {
                        // 发送中
                        cell.activityIndicatorView.hidden = NO;
                        [cell.activityIndicatorView startAnimating];
                        cell.retryButton.hidden = YES;
                    }break;
                    case MessageStatusFinish: {
                        // 发送成功
                        cell.activityIndicatorView.hidden = YES;
                        cell.retryButton.hidden = YES;
                    }break;
                    case MessageStatusFail:{
                        // 发送失败
                        cell.activityIndicatorView.hidden = YES;
                        cell.retryButton.hidden = NO;
                        cell.delegate = self;
                    }break;
                    default: {
                        // 未知
                        cell.activityIndicatorView.hidden = YES;
                        cell.retryButton.hidden = YES;
                        cell.delegate = self;
                    }break;
                }
            }
            else
            {
                LSChatTextLadyTableViewCell* cell = [LSChatTextLadyTableViewCell getUITableViewCell:tableView];
                result = cell;
                cell.detailLabel.attributedText = item.attText;
            }
        }
            break;
        case MessageTypeSystemTips:
        {
            LSChatSystemTipsTableViewCell * cell = [LSChatSystemTipsTableViewCell getUITableViewCell:tableView];
            result = cell;
            
        }
            break;
        case MessageTypeWarningTips:
        {
            LSChatAddCreditsTableViewCell * cell = [LSChatAddCreditsTableViewCell getUITableViewCell:tableView];
            result = cell;
        }
            break;
        default:
        {
            LSChatTextSelfTableViewCell* cell = [LSChatTextSelfTableViewCell getUITableViewCell:tableView];
            result = cell;
            cell.detailLabel.attributedText = item.attText;
        }
            break;
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
- (void)chatTextSelfRetryButtonClick:(LSChatTextSelfTableViewCell *)cell {
    NSIndexPath * path = [self indexPathForCell:cell];
    [self handleErrorMsg:path.row];
}

- (void)handleErrorMsg:(NSInteger)index {
    
}

@end
