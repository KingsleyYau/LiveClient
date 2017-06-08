//
//  HotTableView.m
//  livestream
//
//  Created by Max on 16/2/15.
//  Copyright (c) 2013年 net.qdating. All rights reserved.
//

#import "HotTableView.h"

#import "HotTableViewCell.h"

#import "ImageViewLoader.h"
#import "FileCacheManager.h"

@interface HotTableView() <ImageViewLoaderDelegate>

@end

@implementation HotTableView
@synthesize tableViewDelegate;
@synthesize items;

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
    self.canDeleteItem = NO;
        
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
                number = self.items.count;
            }
        }
        default:break;
    }
	return number;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = self.frame.size.width;
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *tableViewCell = nil;

    HotTableViewCell *cell = [HotTableViewCell getUITableViewCell:tableView];
    tableViewCell = cell;
    
    // 数据填充
    LiveRoomInfoItemObject *item = [self.items objectAtIndex:indexPath.row];
    
    // 人数
    cell.labelViewers.text = item.roomId;
    
    // 国家
    cell.labelCountry.text = item.country;
    
    // 头像
    [cell.imageViewHeader setImage:nil];
    // 停止旧的
    if( cell.imageViewLoader ) {
        [cell.imageViewLoader stop];
    }
    // 创建新的
    cell.imageViewLoader = [ImageViewLoader loader];
    cell.imageViewLoader.sdWebImageView = cell.imageViewHeader;
    cell.imageViewLoader.url = item.photoUrl;
//    cell.imageViewLoader.path = [[FileCacheManager manager] imageCachePathWithUrl:cell.imageViewLoader.url];
    [cell.imageViewLoader loadImageWithOptions:SDWebImageRefreshCached placeholderImage:[UIImage imageNamed:@""]];
    
    return tableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.items.count) {
        if([self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectItem:)]) {
            [self.tableViewDelegate tableView:self didSelectItem:[self.items objectAtIndex:indexPath.row]];
        }
    }

}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.canDeleteItem)
        return UITableViewCellEditingStyleDelete;
    else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            if (indexPath.row < self.items.count) {
                if([self.tableViewDelegate respondsToSelector:@selector(tableView:willDeleteItem:)]) {
                    [self.tableViewDelegate tableView:self willDeleteItem:[self.items objectAtIndex:indexPath.row]];
                }
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - 滚动界面回调 (UIScrollViewDelegate)
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.tableViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.tableViewDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.tableViewDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

@end
