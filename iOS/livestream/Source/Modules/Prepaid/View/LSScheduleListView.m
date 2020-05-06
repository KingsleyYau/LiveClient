//
//  LSScheduleListView.m
//  livestream
//
//  Created by Randy_Fan on 2020/4/13.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSScheduleListView.h"
#import "LSScheduleListBottomView.h"
#import "LSPendingTitleView.h"
#import "LSPrePaidPickerView.h"

#import "LSScheduleInvitedCell.h"
#import "LSScheduleRequestCell.h"

@interface LSScheduleListView()<UITableViewDelegate,UITableViewDataSource,LSScheduleInvitedCellDelegate,LSScheduleListBottomViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *borderView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *borderViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *schedulesArray;
@property (nonatomic, strong) NSMutableArray *myConfirmArray;
@property (nonatomic, strong) NSMutableArray *herConfirmArray;

@property (nonatomic, assign) NSInteger scheduleItemRow;

@property (nonatomic, assign) CGFloat sectionHeaderHeight;
@property (nonatomic, assign) CGFloat sectionFooterHeight;
@end

@implementation LSScheduleListView

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSScheduleListView" owner:self options:0].firstObject;
        
        self.borderView.layer.borderWidth = 1;
        self.borderView.layer.borderColor = COLOR_WITH_16BAND_RGB(0xda9fd7).CGColor;
        self.borderView.layer.masksToBounds = YES;
        self.borderView.layer.cornerRadius = 4;
        
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0.001)];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = view;
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        self.schedulesArray = [NSMutableArray array];
        self.myConfirmArray = [NSMutableArray array];
        self.herConfirmArray = [NSMutableArray array];
        
        self.scheduleItemRow = -1;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    CGRect rect = self.tableView.tableFooterView.frame;
//    rect.size.height = [LSScheduleListBottomView viewHeight];
//    self.tableView.tableFooterView.frame = rect;
}

- (void)setupBorderHeight:(NSArray *)array {
    if (self.invitedStatus == INVITEDSTATUS_CONFIRM) {
        self.titleLabel.text = NSLocalizedStringFromSelf(@"wJd-RU-HF3.text");
    } else {
        self.titleLabel.text = NSLocalizedStringFromSelf(@"PENDING_VIEW_TITLE");
    }
    
    CGFloat height = 0;
    switch (self.invitedStatus) {
        case INVITEDSTATUS_CONFIRM:{
            height = array.count * [LSScheduleRequestCell cellHeight] + [LSScheduleListBottomView viewHeight] + 44;
            height = height > 487 ? 487 : height;
        }break;
            
        case INVITEDSTATUS_PENDING_HER:{
            height = array.count * [LSScheduleRequestCell cellHeight] + [LSScheduleListBottomView viewHeight] + [LSPendingTitleView viewHeight] + 44;
            height = height > 487 ? 487 : height;
        }break;
            
        case INVITEDSTATUS_PENDING_ME:{
            height = array.count * [LSScheduleInvitedCell cellHeight] + [LSScheduleListBottomView viewHeight] + [LSPendingTitleView viewHeight] + 44;
            height = height > 487 ? 487 : height;
        }break;
            
        default:{
            height = 487;
        }break;
    }
    self.borderViewHeight.constant = height;
}

- (void)setListData:(NSMutableArray *)scheduleList {
    [self.schedulesArray removeAllObjects];
    [self.myConfirmArray removeAllObjects];
    [self.myConfirmArray removeAllObjects];
    
    if (self.invitedStatus == INVITEDSTATUS_CONFIRM) {
        [self setupBorderHeight:scheduleList];
        self.schedulesArray = scheduleList;
        
    } else if (self.invitedStatus == INVITEDSTATUS_PENDING) {
        BOOL isHerConfirm = NO;
        BOOL isMyConfirm = NO;
        for (LSScheduleLiveInviteItemObject *item in scheduleList) {
            if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_MAN) {
                isHerConfirm = YES;
                [self.herConfirmArray addObject:item];
            } else if (item.sendFlag == LSSCHEDULESENDFLAGTYPE_ANCHOR) {
                isMyConfirm = YES;
                [self.myConfirmArray addObject:item];
            }
        }
        
        if (isHerConfirm && isMyConfirm) {
            [self setupBorderHeight:scheduleList];
        } else {
            if (isHerConfirm) {
                self.invitedStatus = INVITEDSTATUS_PENDING_HER;
                [self setupBorderHeight:self.herConfirmArray];
            } else if (isMyConfirm) {
                self.invitedStatus = INVITEDSTATUS_PENDING_ME;
                [self setupBorderHeight:self.myConfirmArray];
            }
        }
    }
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.invitedStatus == INVITEDSTATUS_PENDING) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!section) {
        switch (self.invitedStatus) {
            case INVITEDSTATUS_PENDING:
            case INVITEDSTATUS_PENDING_ME:{
                return self.myConfirmArray.count;
            }break;
                
            case INVITEDSTATUS_PENDING_HER:{
                return self.herConfirmArray.count;
            }break;
            
            default:{
                return self.schedulesArray.count;
            }break;
        }
    } else {
        return self.herConfirmArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath.section) {
        if (self.invitedStatus == INVITEDSTATUS_PENDING || self.invitedStatus == INVITEDSTATUS_PENDING_ME) {
            return [LSScheduleInvitedCell cellHeight];
        }
    }
    return [LSScheduleRequestCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@""];
    switch (self.invitedStatus) {
        case INVITEDSTATUS_CONFIRM:{
            LSScheduleLiveInviteItemObject *item = self.schedulesArray[indexPath.row];
            LSScheduleRequestCell *setCell = [LSScheduleRequestCell getUITableViewCell:tableView];
            [setCell setupData:item];
            cell = setCell;
        }break;
        
        case INVITEDSTATUS_PENDING_HER:{
            LSScheduleLiveInviteItemObject *item = self.herConfirmArray[indexPath.row];
            LSScheduleRequestCell *setCell = [LSScheduleRequestCell getUITableViewCell:tableView];
            [setCell setupData:item];
            cell = setCell;
        }break;
        
        case INVITEDSTATUS_PENDING_ME:{
            LSScheduleLiveInviteItemObject *item = self.myConfirmArray[indexPath.row];
            LSScheduleInvitedCell *setCell = [LSScheduleInvitedCell getUITableViewCell:tableView];
            setCell.delegate = self;
            [setCell setupData:item];
            cell = setCell;
        }break;
        
        case INVITEDSTATUS_PENDING:{
            if (!indexPath.section) {
                LSScheduleLiveInviteItemObject *item = self.myConfirmArray[indexPath.row];
                LSScheduleInvitedCell *setCell = [LSScheduleInvitedCell getUITableViewCell:tableView];
                setCell.delegate = self;
                [setCell setupData:item];
                cell = setCell;
            } else {
                LSScheduleLiveInviteItemObject *item = self.herConfirmArray[indexPath.row];
                LSScheduleRequestCell *setCell = [LSScheduleRequestCell getUITableViewCell:tableView];
                [setCell setupData:item];
                cell = setCell;
            }
        }break;
            
        default:{
        }break;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LSPendingTitleView *view = [[LSPendingTitleView alloc] init];
    switch (self.invitedStatus) {
        case INVITEDSTATUS_PENDING:{
            view.titleView.hidden = NO;
            if (!section) {
                view.tipLabel.text = NSLocalizedStringFromSelf(@"MY_PENDING_TITEL");
            } else {
                view.tipLabel.text = NSLocalizedStringFromSelf(@"HER_PENDING_TITEL");
            }
        }break;
        
        case INVITEDSTATUS_PENDING_ME:{
            view.numView.hidden = NO;
            view.numLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.myConfirmArray.count];
            view.pendLabel.text = NSLocalizedStringFromSelf(@"MY_PENDING_NUM");
        }break;
            
        case INVITEDSTATUS_PENDING_HER:{
            view.numView.hidden = NO;
            view.numLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.herConfirmArray.count];
            view.pendLabel.text = NSLocalizedStringFromSelf(@"HER_PENDING_NUM");
        }break;
            
        default:{
        }break;
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    self.sectionHeaderHeight = [LSPendingTitleView viewHeight];
    if (self.invitedStatus == INVITEDSTATUS_CONFIRM) {
        self.sectionHeaderHeight = 0;
    }
    return self.sectionHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    LSScheduleListBottomView *view = [[LSScheduleListBottomView alloc] init];
    view.delegate = self;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    self.sectionFooterHeight = [LSScheduleListBottomView viewHeight];
    if (self.invitedStatus == INVITEDSTATUS_PENDING && !section) {
        self.sectionFooterHeight = 0.001;
    }
    return self.sectionFooterHeight;
}

- (void)reloadSelectTime:(LSScheduleDurationItemObject *)item {
    LSScheduleLiveInviteItemObject *obj = self.myConfirmArray[self.scheduleItemRow];
    obj.duration = item.duration;
    [self.tableView reloadData];
}

#pragma mark - LSScheduleInvitedCellDelegate
- (void)selectDurationWithRow:(LSScheduleInvitedCell *)cell {
    self.scheduleItemRow = [self.tableView indexPathForCell:cell].row;
    LSScheduleLiveInviteItemObject *item = self.myConfirmArray[self.scheduleItemRow];
    
    if ([self.delegate respondsToSelector:@selector(changeDurationForItem:)]) {
        [self.delegate changeDurationForItem:item];
    }
}

- (void)acceptScheduleInvite:(NSString *)inviteId duration:(int)duration item:(LSScheduleInviteItem *)item {
    if ([self.delegate respondsToSelector:@selector(sendAcceptSchedule:duration:item:)]) {
        [self.delegate sendAcceptSchedule:inviteId duration:duration item:item];
    }
}

#pragma mark - 界面事件
- (IBAction)closeBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closeScheduleListView)]) {
        [self.delegate closeScheduleListView];
    }
}

#pragma mark - LSScheduleListBottomViewDelegate
- (void)didHowWorkAction {
    if ([self.delegate respondsToSelector:@selector(howWorkScheduleListView)]) {
        [self.delegate howWorkScheduleListView];
    }
}

@end
