//
//  LSSayHiResponseListTableView.m
//  livestream
//
//  Created by test on 2019/4/22.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiResponseListTableView.h"
#import "LSSayHiResponseListTableViewCell.h"

@implementation LSSayHiResponseListTableView

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
    NSInteger number = 0;
    
    return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = [LSSayHiResponseListTableViewCell cellHeight];
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = [[UITableViewCell alloc] init];
    LSSayHiResponseListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[LSSayHiResponseListTableViewCell cellIdentifier]];
    result = cell;
    //    // 数据填充
    LSSayHiResponseListItemObject *item = [self.items objectAtIndex:indexPath.row];
    cell.anchorName.text = item.nickName;
    [cell.imageViewLoader stop];
    // 创建新的
    cell.imageViewLoader = [LSImageViewLoader loader];
    // 加载
    [cell.imageViewLoader loadImageFromCache:cell.headImage options:SDWebImageRefreshCached imageUrl:item.avatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {
    }];
    
    cell.contentLabel.text = [NSString stringWithFormat:@"...%@...",item.content];
    cell.photoIcon.hidden = !item.hasImg;
    cell.freeIcon.hidden = !item.isFree;
    
    NSDate *lastTime = [NSDate dateWithTimeIntervalSince1970:item.responseTime];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *usLoacal = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    [formatter setLocale:usLoacal];
    formatter.dateFormat = @"MMMM dd";
    cell.dateTime.text = [NSString stringWithFormat:@"%@",[formatter stringFromDate:lastTime]];
    
    
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"LSSayHiResponseListTableView %ld self.items.count %ld",indexPath.row,self.items.count);
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectSayHiDetail:)]) {
            [self.tableViewDelegate tableView:self didSelectSayHiDetail:[self.items objectAtIndex:indexPath.row]];
        }
    }
}

@end
