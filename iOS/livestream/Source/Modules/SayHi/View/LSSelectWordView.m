//
//  LSSelectWordView.m
//  livestream
//
//  Created by Randy_Fan on 2019/4/26.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSelectWordView.h"

#import "LSSayHiTextListTableViewCell.h"

#import <YYText.h>

@interface LSSelectWordView ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet LSTableView *tableView;

@property (strong, nonatomic) NSMutableArray <LSSayHiTextListItem *>*textList;

@property (assign, nonatomic) NSInteger selectIndex;

@end

@implementation LSSayHiTextListItem

@end

@implementation LSSelectWordView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        self.frame = frame;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.tableFooterView = [[UIView alloc] init];
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        self.selectIndex = -1;
    }
    return self;
}

- (void)loadWordTableView:(NSMutableArray <LSSayHiTextListItem *>*)texts selectIndex:(NSInteger)selectIndex {
    self.selectIndex = selectIndex;
    self.textList = texts;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellHeight = 0;
    if (self.textList.count > 0) {
        LSSayHiTextListItem *item = self.textList[indexPath.row];
        cellHeight = item.cellHeight;
    }
    return  cellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.textList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSSayHiTextListTableViewCell *cell = [LSSayHiTextListTableViewCell getUITableViewCell:tableView];
    
    LSSayHiTextListItem *item = self.textList[indexPath.row];
    if (self.selectIndex == indexPath.row) {
        cell.isSelect = YES;
    } else {
        cell.isSelect = NO;
    }
    [cell setupTextContent:item.textItem.text];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.selectIndex) {
        
        LSSayHiTextListItem *item = self.textList[indexPath.row];
        if ([self.delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
            [self.delegate didSelectRowAtIndexPath:item];
        }
        self.selectIndex = indexPath.row;
        
        [self.tableView reloadData];
    }
}

@end
