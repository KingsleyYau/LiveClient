//
//  LSSayHiAllTableView.m
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiAllTableView.h"
#import "LSSayHiAllTableViewCell.h"
#import "LSDateTool.h"

@implementation LSSayHiAllTableView


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
    int count = 1;
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = [LSSayHiAllTableViewCell cellHeight];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = [[UITableViewCell alloc] init];
    if (indexPath.row < self.items.count) {
        LSSayHiAllTableViewCell *cell = [LSSayHiAllTableViewCell getUITableViewCell:tableView];
        result = cell;
        //    // 数据填充
        LSSayHiAllListItemObject *item = [self.items objectAtIndex:indexPath.row];
        cell.anchorName.text = item.nickName;
        [cell.imageViewLoader stop];
        // 创建新的
        cell.imageViewLoader = [LSImageViewLoader loader];
        // 加载
        [cell.imageViewLoader loadImageFromCache:cell.headImage options:SDWebImageRefreshCached imageUrl:item.avatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"] finishHandler:^(UIImage *image) {
        }];
        
        cell.freeIcon.hidden = item.isFree?NO:YES;
        
        NSDate *lastTime = [NSDate dateWithTimeIntervalSince1970:item.sendTime];
        cell.dateTime.text = [LSDateTool showSayHiListTimeTextOfDate:lastTime];
        
        [cell cellUpdateIsHasRead:item.unreadNum];
        
        if (item.content.length > 0) {
            cell.content.text = item.content;
            cell.content.textColor = COLOR_WITH_16BAND_RGB(0x383838);
            
        }else {
            cell.content.text = @"No responses yet.";
            cell.content.textColor = COLOR_WITH_16BAND_RGB(0x8B8B8B);
            cell.content.font = [UIFont italicSystemFontOfSize:16];
        }
        

    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"LSSayHiAllTableView %lu self.items.count %lu",(long)indexPath.row,(long)self.items.count);
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectSayHiDetail:)]) {
            [self.tableViewDelegate tableView:self didSelectSayHiDetail:[self.items objectAtIndex:indexPath.row]];
        }
    }
}
@end
