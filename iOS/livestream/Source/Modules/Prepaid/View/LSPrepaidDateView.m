//
//  LSPrepaidDateView.m
//  livestream
//
//  Created by Calvin on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPrepaidDateView.h"

@interface LSPrepaidDateView ()

@end

@implementation LSPrepaidDateView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIView *containerView = [[LiveBundle mainBundle] loadNibNamed:@"LSPrepaidDateView" owner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.endTimeButton.layer.cornerRadius = 4;
    self.endTimeButton.layer.masksToBounds = YES;
}

- (void)updateNewBeginTime {
    //只能选24小时后的时间
    NSInteger time = [LSPrePaidManager manager].activityTime + 86400;
    if ([LSPrePaidManager manager].zoneItem.summerTimeStart < time && time < [LSPrePaidManager manager].zoneItem.summerTimeEnd) {
        time = time + 3600;
    }
    NSString * zoneTime = [[LSPrePaidManager manager] getTimeFromTimestamp:time timeFormat:@"MMM dd, yyyy-HH:00" andZone:[[LSPrePaidManager manager]getZone]];
    
    NSArray * array = [zoneTime componentsSeparatedByString:@"-"];
    [self updateDate:[array firstObject]];
    [self updateBeginTime:[array lastObject]];
}
 

- (void)updateCountries:(LSCountryTimeZoneItemObject*)item {
    
     [self.countriesButton setTitle:item.countryName forState:UIControlStateNormal];
    
     LSTimeZoneItemObject * timeItem = [item.timeZoneList firstObject];
    
    [self updateTimeZone:timeItem];
}

- (void)updateTimeZone:(LSTimeZoneItemObject *)item {
    [LSPrePaidManager manager].zoneItem = item;
    [self.timeZoneButton setTitle:[[LSPrePaidManager manager] getTimeZoneText:item] forState:UIControlStateNormal];
    
    [self updateNewBeginTime];
}

- (void)updateDate:(NSString *)str {
    [LSPrePaidManager manager].yaerStr = str;
    [self.timeButton setTitle:str forState:UIControlStateNormal];
    
    [self updateBeginTime:[LSPrePaidManager manager].benginTime];
}

- (void)updateBeginTime:(NSString *)time {
    if ([LSPrePaidManager manager].yaerStr.length > 0) {
        
        if (![[[LSPrePaidManager manager]getTimeArray] containsObject:time]) {
            time = [[[LSPrePaidManager manager]getTimeArray] firstObject];
        }
        
        [LSPrePaidManager manager].benginTime = time;
        [self.beginTimeButton setTitle:time forState:UIControlStateNormal];
        
        NSString * endTime = [[LSPrePaidManager manager] getEndTime:time];
        [self.endTimeButton setTitle:endTime forState:UIControlStateNormal];
        
        NSString * str = [NSString stringWithFormat:@"%@-%@",[LSPrePaidManager manager].yaerStr,time];
        NSString *zone = [[LSPrePaidManager manager] getZone];
        [self updateLocalTime:str andZone:zone];
    }
}

- (void)updateLocalTime:(NSString *)time andZone:(NSString*)zone {
 
    NSInteger timeS = [[LSPrePaidManager manager]timeSwitchTimestamp:time];
    
     if ([[LSPrePaidManager manager]nowtimeIsInBeginTime:time]) {
         timeS = timeS-3600;
     }

    NSString *dateString = [[LSPrePaidManager manager]getLocalTimeFromTimestamp:timeS timeFormat:@"MMM dd, yyyy-HH:mm"];
 
    NSArray * array = [dateString componentsSeparatedByString:@"-"];
    NSString * endTime = [[LSPrePaidManager manager] getEndTime:[array lastObject]];
    self.localTimeLabel.text = [NSString stringWithFormat:@"Your local time: %@ - %@",[dateString stringByReplacingOccurrencesOfString:@"-" withString:@" "],endTime];
}

- (void)updateCredits:(LSScheduleDurationItemObject *)item {
    [LSPrePaidManager manager].duration = [NSString stringWithFormat:@"%d",item.duration];
    if (item.credit != item.originalCredit) {
          NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits %0.2f Credits",item.duration,item.credit,item.originalCredit];
             NSString * str1 = [NSString stringWithFormat:@"%0.2f Credits",item.originalCredit];
         NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:str1];
          [self.creditsButton setAttributedTitle:attrStr forState:UIControlStateNormal];
    } else {
        NSString * str = [NSString stringWithFormat:@"%d Minutes - %0.2f Credits",item.duration,item.credit];
        NSMutableAttributedString * attrStr =  [[LSPrePaidManager manager] newCreditsStr:str credits:@""];
       [self.creditsButton setAttributedTitle:attrStr forState:UIControlStateNormal];
    }
}

- (IBAction)buttonDid:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidDateViewBtnDid:)]) {
        [self.delegate prepaidDateViewBtnDid:sender];
    }
}

- (void)resetBtnState {
    self.countriesButton.selected = NO;
    self.timeZoneButton.selected = NO;
    self.timeButton.selected = NO;
    self.beginTimeButton.selected = NO;
    self.creditsButton.selected = NO;
    self.endTimeButton.selected = NO;
}
 

@end
