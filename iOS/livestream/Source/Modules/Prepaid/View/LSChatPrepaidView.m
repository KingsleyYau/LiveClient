//
//  LSChatPrepaidView.m
//  livestream
//
//  Created by Calvin on 2020/3/27.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatPrepaidView.h"
#import "LSConfigManager.h"
#import "LSShadowView.h"
@interface LSChatPrepaidView ()<LSPrepaidDateViewDelegate>

@property (nonatomic, strong) LSScheduleInviteItem *item;
@end

@implementation LSChatPrepaidView

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSChatPrepaidView" owner:self options:0].firstObject;
        self.lessenBtn.hidden = YES;
        self.item = [[LSScheduleInviteItem alloc] init];
    }
    return self;
}
 
- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
    self.titleLabel.layer.shadowOffset = CGSizeMake(0, 1);
    self.titleLabel.layer.shadowOpacity = 0.5;
    
    self.deteView.layer.cornerRadius = 4;
    self.deteView.layer.masksToBounds = YES;
    
    LSShadowView * view = [[LSShadowView alloc]init];
    [view showShadowAddView:self.deteView];
    
    self.sendBtn.layer.masksToBounds = YES;
    self.sendBtn.layer.cornerRadius = self.sendBtn.tx_height / 2;
    
    LSShadowView * view1 = [[LSShadowView alloc]init];
    [view1 showShadowAddView:self.sendBtn];
    
    self.inviteView.layer.masksToBounds = YES;
    self.inviteView.layer.cornerRadius = 4;
    
    self.deteView.delegate = self;
    self.selectedRow = 0;
    
    for (int i = 0; i < [LSPrePaidManager manager].countriesArray.count; i++) {
        LSCountryTimeZoneItemObject * item =[LSPrePaidManager manager].countriesArray[i];
        if (item.isDefault) {
            self.selectedRow = i;
            LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:self.selectedRow];
            [self.deteView updateCountries:item];
            break;
        }
    }
    
    for (int i = 0; i < [LSPrePaidManager manager].creditsArray.count; i++) {
        LSScheduleDurationItemObject * item = [LSPrePaidManager manager].creditsArray[i];
        if (item.isDefault) {
            self.selectedDurationRow = i;
            [self.deteView updateCredits:item];
            break;
        }
    }
    
    NSString * upStr = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"discount_num"),[LSConfigManager manager].item.scheduleSaveUp];
    NSString * title = [NSString stringWithFormat:NSLocalizedStringFromSelf(@"TITLE"),upStr];
    
    NSMutableAttributedString * attr = [[NSMutableAttributedString alloc]initWithString:title];
    [attr addAttributes:@{NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} range:[title rangeOfString:upStr]];
    
    self.subLabel.attributedText = attr;
}

- (IBAction)lessenBenDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatPrepaidViewDidLessen:)]) {
        [self.delegate chatPrepaidViewDidLessen:sender];
    }
}

- (IBAction)closeBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatPrepaidViewDidClose)]) {
        [self.delegate chatPrepaidViewDidClose];
    }
}

- (IBAction)sendBtndid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatPrepaidViewDidSend:)]) {
        [self.delegate chatPrepaidViewDidSend:self.item];
    }
}

- (IBAction)infoLabelTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatPrepaidViewDidHowWork)]) {
        [self.delegate chatPrepaidViewDidHowWork];
    }
}

- (void)prepaidDateViewBtnDid:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(chatPrepaidViewDidTimeBtn:)]) {
        [self.delegate chatPrepaidViewDidTimeBtn:button];
    }
}

- (void)pickerViewSelectedRow:(NSInteger)row {
    if (self.deteView.countriesButton.isSelected) {
        if ([LSPrePaidManager manager].countriesArray.count > row) {
            self.deteView.countriesButton.selected = NO;
            self.selectedRow = row;
            LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:row];
            [self.deteView updateCountries:item];
            [self.deteView updateTimeZone:[item.timeZoneList firstObject]];
        }
        
    }else if (self.deteView.timeZoneButton.isSelected) {
        if ([LSPrePaidManager manager].countriesArray.count > row) {
            self.deteView.timeZoneButton.selected = NO;
             LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:self.selectedRow];
            LSTimeZoneItemObject * tiemItem = [item.timeZoneList objectAtIndex:row];
            self.selectedZoneRow = row;
            [self.deteView updateTimeZone:tiemItem];
        }
    }else if (self.deteView.creditsButton.isSelected) {
        if ([LSPrePaidManager manager].creditsArray.count > row) {
            self.deteView.creditsButton.selected = NO;
            LSScheduleDurationItemObject * item = [[LSPrePaidManager manager].creditsArray objectAtIndex:row];
            self.selectedDurationRow = row;
            [self.deteView updateCredits:item];
        }
    }
    else if (self.deteView.timeButton.isSelected) {
        if ([[LSPrePaidManager manager]getYearArray].count > row) {
            self.deteView.timeButton.selected = NO;
            self.selectedYearRow = row;
            [self.deteView updateDate:[[[LSPrePaidManager manager]getYearArray] objectAtIndex:row]];
        }
    }else if (self.deteView.beginTimeButton.isSelected) {
        if ([[LSPrePaidManager manager]getTimeArray].count > row) {
            self.deteView.beginTimeButton.selected = NO;
            self.selectedBeginTimeRow = row;
            NSArray * array = [[LSPrePaidManager manager]getTimeArray];
            [self.deteView updateBeginTime:[array objectAtIndex:row]];
        }
    }
}

- (NSInteger)getSelectedRow:(UIButton *)button {
    if ([button isEqual:self.deteView.countriesButton]) {
       return self.selectedRow;
    }else if ([button isEqual:self.deteView.timeZoneButton]) {
        return self.selectedZoneRow;
    }else if ([button isEqual:self.deteView.creditsButton]) {
        return self.selectedDurationRow;
    }else if ([button isEqual:self.deteView.timeButton]) {
        self.selectedYearRow = [[[LSPrePaidManager manager]getYearArray] indexOfObject:button.titleLabel.text];
       return self.selectedYearRow;
    }else if ([button isEqual:self.deteView.beginTimeButton]) {
        if ([[[LSPrePaidManager manager]getTimeArray] containsObject:button.titleLabel.text]) {
           self.selectedBeginTimeRow = [[[LSPrePaidManager manager]getTimeArray] indexOfObject:button.titleLabel.text];
        }else {
            self.selectedBeginTimeRow = 0;
        }
       return self.selectedBeginTimeRow;
    }
    return 0;
}

- (NSArray *)getPickerData:(UIButton *)button {
    button.selected = YES;
    if ([button isEqual:self.deteView.countriesButton]) {
       NSMutableArray * array = [NSMutableArray array];
        for (LSCountryTimeZoneItemObject * item in [LSPrePaidManager manager].countriesArray) {
            [array addObject:item.countryName];
        }
        return array;
    }
    else if ([button isEqual:self.deteView.timeZoneButton]) {
        NSMutableArray * array = [NSMutableArray array];
        LSCountryTimeZoneItemObject * item = [[LSPrePaidManager manager].countriesArray objectAtIndex:self.selectedRow];
        for (LSTimeZoneItemObject * timeItem in item.timeZoneList) {
            [array addObject:[[LSPrePaidManager manager] getTimeZoneText:timeItem]];
        }
        return array;
    }
    else if ([button isEqual:self.deteView.creditsButton]) {
        return [[LSPrePaidManager manager]getCreditArray];
    }else if ([button isEqual:self.deteView.timeButton]) {
         return [[LSPrePaidManager manager]getYearArray];
    }else if ([button isEqual:self.deteView.beginTimeButton]) {
        return [[LSPrePaidManager manager]getTimeArray];
    }
    return @[];
}

@end
