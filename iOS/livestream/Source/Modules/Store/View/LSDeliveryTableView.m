//
//  LSDeliveryTableView.m
//  livestream
//
//  Created by test on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSDeliveryTableView.h"
#import "LSDateTool.h"

@implementation LSDeliveryTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
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

- (void)reloadData {
    [super reloadData];
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;

    if (self.items.count > 0) {
        number = self.items.count;
    }

    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return [LSDeliveryListTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = [[UITableViewCell alloc] init];
    LSDeliveryListTableViewCell *cell = [LSDeliveryListTableViewCell getUITableViewCell:tableView];
    tableViewCell = cell;
    cell.deliveryDelegate = self;
    if (indexPath.row < self.items.count) {
        LSDeliveryItemObject *item = [self.items objectAtIndex:indexPath.row];
        cell.tag = indexPath.row;
        cell.giftArray = item.giftList;
        cell.anchorName.text = item.anchorNickName;
        cell.dateTime.text = [LSDateTool getMinTime:item.orderDate];
        [cell.imageViewLoader stop];
        [cell.imageViewLoader loadHDListImageWithImageView:cell.anchorIcon
                                             options:0
                                                  imageUrl:item.anchorAvatar
                                    placeholderImage:[UIImage imageNamed:@""]
                                       finishHandler:nil];
        cell.giftNote.text = item.orderNumber;
        
        NSMutableAttributedString * attributeString = [[NSMutableAttributedString alloc]initWithString:item.deliveryStatusVal];

        [attributeString addAttributes:@{
                                         NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                         }
                                 range:NSMakeRange(0, attributeString.length)];
        [cell.statusNote setAttributedTitle:attributeString forState:UIControlStateNormal];
        cell.statusNote.titleLabel.textAlignment = NSTextAlignmentRight;
        cell.statusNote.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }

    return tableViewCell;
}


#pragma mark - 列表内容点击回调
- (void)lsDeliveryListTableViewCell:(LSDeliveryListTableViewCell *)cell didClickGiftInfo:(LSFlowerGiftBaseInfoItemObject *)item {
    if ([self.tableViewDelegate respondsToSelector:@selector(lsDeliveryTableView:didClickGiftInfo:)]) {
        [self.tableViewDelegate lsDeliveryTableView:self didClickGiftInfo:item];
    }
}


- (void)lsDeliveryListTableViewCellDidClickStatusAction:(LSDeliveryListTableViewCell *)cell {
    if ([self.tableViewDelegate respondsToSelector:@selector(lsDeliveryTableViewDidClickStatusAction:)]) {
        [self.tableViewDelegate lsDeliveryTableViewDidClickStatusAction:self];
    }
}

- (void)lsDeliveryListTableViewCellDidAnchorIcon:(LSDeliveryListTableViewCell *)cell {
       LSDeliveryItemObject *item = [self.items objectAtIndex:cell.tag];
    if ([self.tableViewDelegate respondsToSelector:@selector(lsDeliveryTableView:DidClickAchorIcon:)]) {
        [self.tableViewDelegate lsDeliveryTableView:self DidClickAchorIcon:item];
    }
}

@end
