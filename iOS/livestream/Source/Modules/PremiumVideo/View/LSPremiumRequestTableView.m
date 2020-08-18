//
//  LSPremiumRequestTableView.m
//  livestream
//
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumRequestTableView.h"
#import "LSPremiumRequestListItemObject.h"
#import "LSRequestVideoKeyTableViewCell.h"
#import "LSPremiumVideoinfoItemObject.h"
#import "LSPremiumTipsTableViewCell.h"
#import "LSDateTool.h"

#define FootViewHeight (110.f)

@implementation LSPremiumRequestTableView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
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
    //footView = [[LSPremiumRequestFooterView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, FootViewHeight)];
    //[self setTableFooterView:footView];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

-(void)setTipsType:(LSAccessKeyType)type
{
    if (type == LSACCESSKEYTYPES_REPLY) {
        //已回复
    }else{
        
    }
}

-(void)reloadData
{
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
    return self.items.count==0?0:self.items.count+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0.0;
    height = [LSRequestVideoKeyTableViewCell cellHeight];
    if (indexPath.row == self.items.count) {
        //自定义尾部的一条cell
        NSString *str = @"";
        if (self.type == LSACCESSKEYTYPES_REPLY) {
            str = NSLocalizedString(@"Premium_Video_Tip_Access", nil);
            
        }else if (self.type == LSACCESSKEYTYPE_UNREPLY){
            str = NSLocalizedString(@"Premium_Video_Tip_Pending", nil);
        }else{
            str = NSLocalizedString(@"Premium_Video_Tip_Unlock", nil);
        }
        CGRect rect = [str boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 40.f, MAXFLOAT) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:[UIFont fontWithName:@"ArialMT" size:12]} context:nil];
        height = ceil(rect.size.height)+47.f;
        return height;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = [[UITableViewCell alloc] init];

    if (indexPath.row == self.items.count) {
        //自定义尾部的一条cell
        LSPremiumTipsTableViewCell *cell = [LSPremiumTipsTableViewCell getUITableViewCell:tableView];
        if (self.type == LSACCESSKEYTYPES_REPLY) {
            [cell setTipText:NSLocalizedString(@"Premium_Video_Tip_Access", nil)];
        }else if (self.type == LSACCESSKEYTYPE_UNREPLY){
            [cell setTipText:NSLocalizedString(@"Premium_Video_Tip_Pending", nil)];
        }else{
            [cell setTipText:NSLocalizedString(@"Premium_Video_Tip_Unlock", nil)];
        }
        if ([cell.richLabel gestureRecognizers].count == 0) {
            [cell.richLabel addTapGesture:self sel:@selector(richLabelTap)];
        }
        result = cell;
        return result;
    }
    LSRequestVideoKeyTableViewCell *cell = [LSRequestVideoKeyTableViewCell getUITableViewCell:tableView];

    cell.delegate = self;
    cell.tag = indexPath.row;
    result = cell;
    if (indexPath.row < self.items.count) {
        // 数据填充
        NSString *txt = @"";
        
        LSPremiumVideoinfoItemObject *videoitem = [[LSPremiumVideoinfoItemObject alloc] init];
        if (self.type == LSACCESSKEYTYPES_REPLY){
            //已回复
            LSPremiumVideoAccessKeyItemObject *item = [self.items objectAtIndex:indexPath.row];
            videoitem = item.premiumVideoInfo;
            
            txt = @"View Key";
            //是否已读
            if (item.emfReadStatus) {
                [cell.viewKeyBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                [cell.viewKeyBtn setTitleColor:[UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:1] forState:UIControlStateNormal];
            }else{
                [cell.viewKeyBtn setBackgroundImage:[UIImage imageNamed:@"Home_BlueShadeBg"] forState:UIControlStateNormal];
                [cell.viewKeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
            
            [cell.statusImgView setHidden:item.emfReadStatus];
            
            [cell.expiryLabel setText:[NSString stringWithFormat:@"Expiry Date:%@",[LSDateTool getTime:item.validTime]]];
        }else if( self.type == LSACCESSKEYTYPE_UNREPLY) {
            //未回复
            LSPremiumVideoAccessKeyItemObject *item = [self.items objectAtIndex:indexPath.row];
            videoitem = item.premiumVideoInfo;
            
            [cell.statusImgView setHidden:YES];
            txt = @"Send Reminder";
            //判断最后请求时间，是否超过24小时
            [cell.viewKeyBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            if (item.currentTime-item.lastSendTime>24*60*60) {
                //已超过24小时，可再次请求
//                [cell.viewKeyBtn setBackgroundImage:[UIImage imageNamed:@"Home_BlueShadeBg"] forState:UIControlStateNormal];
                [cell.viewKeyBtn setBackgroundColor:[UIColor whiteColor]];
                [cell.viewKeyBtn setTitleColor:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1.0] forState:UIControlStateNormal];
            }else{
                //[cell.viewKeyBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
                [cell.viewKeyBtn setBackgroundColor:[UIColor colorWithRed:248/255.0 green:249/255.0 blue:250/255.0 alpha:1/1.0]];
                [cell.viewKeyBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0] forState:UIControlStateNormal];
            }
            [cell.expiryLabel setText:[NSString stringWithFormat:@"Last Request:%@",[LSDateTool getTime:item.lastSendTime]]];
        }else{
            //已解锁
            [cell.statusImgView setHidden:YES];
            
            LSPremiumVideoRecentlyWatchedItemObject *item = [self.items objectAtIndex:indexPath.row];
            videoitem = item.premiumVideoInfo;
            
            txt = @"View Video";

            [cell.viewKeyBtn setBackgroundImage:[UIImage imageNamed:@"Home_ChatNowBg"] forState:UIControlStateNormal];
            
            [cell.expiryLabel setText:[NSString stringWithFormat:@"Date Unlocked:%@",[LSDateTool getTime:item.addTime]]];
        }
        
        [[LSImageViewLoader loader] loadImageWithImageView:cell.corverImgView options:SDWebImageRefreshCached imageUrl:videoitem.coverUrlPng placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"] finishHandler:^(UIImage *image) {
        }];
        [[LSImageViewLoader loader] loadImageFromCache:cell.headImgView options:SDWebImageRefreshCached imageUrl:videoitem.anchorAvatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_HangOut"] finishHandler:^(UIImage *image) {
        }];
        
        cell.titleLabel.text = videoitem.title;
        cell.nameLabel.text = videoitem.anchorNickname;
        cell.collectBtn.selected = videoitem.isInterested;
        [cell.durationLabel setDuration:videoitem.duration];
        
        [cell.viewKeyBtn setTitle:txt forState:UIControlStateNormal];
        CGSize size = [txt sizeWithAttributes:@{NSFontAttributeName:cell.viewKeyBtn.titleLabel.font}];
        cell.viewKeyBtnW.constant = ceil(size.width)+cell.viewKeyBtn.bounds.size.height;
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"%@ %lu self.items.count %lu", [self class],(long)indexPath.row,(long)self.items.count);
    if (indexPath.row < self.items.count) {
        if(self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectPremiumRequestDetail:)]) {
            LSPremiumVideoinfoItemObject *videoitem = [[LSPremiumVideoinfoItemObject alloc] init];
            if (self.type == LSACCESSKEYTYPES_REPLY || self.type == LSACCESSKEYTYPE_UNREPLY){
                videoitem = ((LSPremiumVideoAccessKeyItemObject *)[self.items objectAtIndex:indexPath.row]).premiumVideoInfo;
            }else{
                videoitem = ((LSPremiumVideoRecentlyWatchedItemObject *)[self.items objectAtIndex:indexPath.row]).premiumVideoInfo;
            }
            [self.tableViewDelegate tableView:self didSelectPremiumRequestDetail:videoitem];
        }
    }else{
        if(self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:didSelectPremiumRequestDetail:)]) {
            [self.tableViewDelegate tableView:self didSelectPremiumRequestDetail:nil];
        }
    }
}

#pragma mark - LSRequestVideoKeyTableViewCellDelegate
- (void)requestVideoKeyCellCollectBtnOnDid:(NSInteger)row
{
    NSLog(@"%@ %lu self.items.count %lu", [self class],(long)row,(long)self.items.count);
    if (row < self.items.count) {
        if(self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:didCollectPremiumRequestDetail:)]) {
            [self.tableViewDelegate tableView:self didCollectPremiumRequestDetail:row];
        }
    }
}

- (void)requestVideoKeyCellViewKeyBtnOnDid:(NSInteger)row
{
    NSLog(@"%@ %lu self.items.count %lu", [self class],(long)row,(long)self.items.count);
    if (row < self.items.count) {
        if(self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:didViewAllPremiumRequestDetail:)]) {
            [self.tableViewDelegate tableView:self didViewAllPremiumRequestDetail:row];
        }
    }
}

- (void)requestVideoKeyCellUserBtnOnDid:(NSInteger)row
{
    NSLog(@"%@ %lu self.items.count %lu", [self class],(long)row,(long)self.items.count);
    if (row < self.items.count) {
        if(self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(tableView:didUserHeadPremiumRequestDetail:)]) {
            [self.tableViewDelegate tableView:self didUserHeadPremiumRequestDetail:row];
        }
    }
}

-(void)richLabelTap
{
    if(self.tableViewDelegate && [self.tableViewDelegate respondsToSelector:@selector(didTapTipLabel)]) {
        [self.tableViewDelegate didTapTipLabel];
    }
}

@end
