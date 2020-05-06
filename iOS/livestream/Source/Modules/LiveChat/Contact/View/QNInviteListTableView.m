//
//  LSInviteListTableView.m
//  livestream
//
//  Created by test on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "QNInviteListTableView.h"


@implementation QNInviteListTableView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
        
    }
    return self;
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    [self registerNib:[UINib nibWithNibName:@"QNIniviteListTableViewCell" bundle:[LiveBundle mainBundle]] forCellReuseIdentifier:[QNIniviteListTableViewCell cellIdentifier]];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    switch(section) {
        case 0: {
            if(self.items.count > 0) {
                self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                number = self.items.count;
                
            } else {
                self.separatorStyle = UITableViewCellSeparatorStyleNone;
                number = 0;
                
            }
        }
        default:break;
    }
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = [QNIniviteListTableViewCell cellHeight];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    
    
    QNIniviteListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[QNIniviteListTableViewCell cellIdentifier]];
    result = cell;
    
    //    // 数据填充
    LSLadyRecentContactObject *item = [self.items objectAtIndex:indexPath.row];

    cell.ladyName.text = item.userName;
    [cell.imageViewLoader stop];
    cell.imageViewLoader = nil;
    // 创建新的
    cell.imageViewLoader = [LSImageViewLoader loader];
    // 加载
    [cell.imageViewLoader loadImageFromCache:cell.ladyImage options:SDWebImageRefreshCached imageUrl:item.photoURL placeholderImage:LADYDEFAULTIMG finishHandler:^(UIImage *image) {
    }];
    // 最后一条消息
    if( item.lastInviteMessage != nil && item.lastInviteMessage.length > 0 ) {
        cell.ladyLastContact.attributedText = item.lastInviteMessage;
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectContact:)]) {
            [self.tableViewDelegate tableView:self didSelectContact:[self.items objectAtIndex:indexPath.row]];
        }
    }
}
@end
