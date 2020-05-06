//
//  LSChatPrepaidView.h
//  livestream
//
//  Created by Calvin on 2020/3/27.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPrepaidDateView.h"
#import "LSScheduleInviteItem.h"

@protocol LSChatPrepaidViewDelegate <NSObject>
@optional;
- (void)chatPrepaidViewDidTimeBtn:(UIButton *)button;
- (void)chatPrepaidViewDidClose;
- (void)chatPrepaidViewDidLessen:(UIButton *)button;
- (void)chatPrepaidViewDidSend:(LSScheduleInviteItem *)item;
- (void)chatPrepaidViewDidHowWork;
@end

@interface LSChatPrepaidView : UIView 

@property (weak, nonatomic) IBOutlet UIView *inviteView;

@property (weak, nonatomic) IBOutlet UIButton *lessenBtn;

@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;

@property (weak, nonatomic) IBOutlet LSPrepaidDateView *deteView;

@property (weak, nonatomic) id<LSChatPrepaidViewDelegate> delegate;
@property (nonatomic, assign) NSInteger selectedRow;//选中的国家
@property (nonatomic, assign) NSInteger selectedZoneRow;//选中的时区
@property (nonatomic, assign) NSInteger selectedDurationRow;//选中的时长
@property (nonatomic, assign) NSInteger selectedYearRow;//选中的日期
@property (nonatomic, assign) NSInteger selectedBeginTimeRow;//选中的开始时间
- (void)pickerViewSelectedRow:(NSInteger)row;
- (NSInteger)getSelectedRow:(UIButton *)button;
- (NSArray *)getPickerData:(UIButton *)button;
@end

 
