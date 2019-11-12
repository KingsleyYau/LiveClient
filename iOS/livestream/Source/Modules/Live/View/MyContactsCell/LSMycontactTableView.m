//
//  LSMycontactTableView.m
//  livestream
//
//  Created by Calvin on 2019/6/20.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMycontactTableView.h"
#import "LSMyContactsListCell.h"
#import "LSRecommendAnchorItemObject.h"

@interface LSMycontactTableView ()<LSMyContactsListCellDelegate>
@property (nonatomic,assign) NSInteger oldRow;
@end

@implementation LSMycontactTableView

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
    
    [self registerNib:[UINib nibWithNibName:@"LSMyContactsListCell" bundle:[LiveBundle mainBundle]] forCellReuseIdentifier:[LSMyContactsListCell cellIdentifier]];
    
    [self setTableFooterView:[UIView new]];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [LSMyContactsListCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = nil;
    
    LSMyContactsListCell *cell = [tableView dequeueReusableCellWithIdentifier:[LSMyContactsListCell cellIdentifier]];
    result = cell;
    cell.cellDelegate = self;
    cell.tag = indexPath.row;
    LSRecommendAnchorItemObject * item = self.items[indexPath.row];
    [cell setFavoitesCellMoreView:item];
        
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableViewDelegate respondsToSelector:@selector(mycontactTableViewDidSelectItem:)]) {
        [self.tableViewDelegate mycontactTableViewDidSelectItem:self.items[indexPath.row]];
    }
}

- (void)myContactListTableViewCellDidClickInviteBtn:
(LSMyContactsListCell *)cell {
    if ([self.tableViewDelegate respondsToSelector:@selector(mycontactTableViewDidClickInviteBtn:)]) {
        [self.tableViewDelegate mycontactTableViewDidClickInviteBtn:self.items[cell.tag]];
    }
}

- (void)myContactListTableViewCellDidClickBookBtn:
(LSMyContactsListCell *)cell {
    if ([self.tableViewDelegate respondsToSelector:@selector(mycontactTableViewDidClickBookBtn:)]) {
        [self.tableViewDelegate mycontactTableViewDidClickBookBtn:self.items[cell.tag]];
    }
}

- (void)myContactListTableViewCellDidClickMailBtn:
(LSMyContactsListCell *)cell {
    if ([self.tableViewDelegate respondsToSelector:@selector(mycontactTableViewDidClickMailBtn:)]) {
        [self.tableViewDelegate mycontactTableViewDidClickMailBtn:self.items[cell.tag]];
    }
}

- (void)myContactListTableViewCellDidClickChatBtn:
(LSMyContactsListCell *)cell {
    if ([self.tableViewDelegate respondsToSelector:@selector(mycontactTableViewDidClickChatBtn:)]) {
        [self.tableViewDelegate mycontactTableViewDidClickChatBtn:self.items[cell.tag]];
    }
}

@end
