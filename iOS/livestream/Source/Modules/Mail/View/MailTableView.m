//
//  MailTableView.m
//  livestream
//
//  Created by Randy_Fan on 2018/11/16.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "MailTableView.h"

@implementation MailTableView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
        [self registerClass:[MailTableViewCell class] forCellReuseIdentifier:[MailTableViewCell cellIdentifier]];
    }
    return self;
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;

    [self setTableFooterView:[UIView new]];
}
#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [MailTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;    
    LSHttpLetterListItemObject *item = [self.items objectAtIndex:indexPath.row];
    MailTableViewCell *cell = [MailTableViewCell getUITableViewCell:tableView];
    if (self.mailType == LSEMFTYPE_OUTBOX) {
        [cell updataOutBoxMailCell:item];
    }else {
        [cell updataMailCell:item];
    }

    tableViewCell = cell;

    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.items.count > 0) {
         LSHttpLetterListItemObject *obj = [self.items objectAtIndex:indexPath.row];
        if ([self.mailDelegate respondsToSelector:@selector(tableView:cellDidSelectRowAtIndexPath:index:)]) {
            [self.mailDelegate tableView:self cellDidSelectRowAtIndexPath:obj index:indexPath.row];
            
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.mailDelegate respondsToSelector:@selector(tableViewWillBeginDragging)]) {
        [self.mailDelegate tableViewWillBeginDragging];
    }
}

@end
