//
//  SearchTableView.m
//  livestream
//
//  Created by randy on 17/6/2.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "SearchTableView.h"
#import "LSImageViewLoader.h"
#import "SearchTableViewCell.h"
#import "SearchListObject.h"

@interface SearchTableView()

@property (nonatomic, strong) SearchTableViewCell *searchCell;

@end

@implementation SearchTableView

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
//    self.canDeleteItem = NO;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)reloadData {
    [super reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.searchCell = [SearchTableViewCell getUITableViewCell:tableView];
    
    self.searchCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    SearchListObject *list = [self.items objectAtIndex:indexPath.row];
    
    [self.searchCell setTheUserMessage:list];
    
    return self.searchCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [SearchTableViewCell cellHeight];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([self.searchDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.searchDelegate scrollViewDidScroll:scrollView];
    }
}

@end
