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
        
    [self updateNewBeginTime];
}

- (void)updateNewBeginTime {
    NSString * string = [[[LSPrePaidManager manager].dateArray firstObject] objectForKey:@"year"];
    [self updateDate:string];
    
    NSString * time = [[LSPrePaidManager manager] getCurrentTimes];
    [self updateBeginTime:time];
}
 

- (void)updateCountries:(LSCountryTimeZoneItemObject*)item {
    
     [self.countriesButton setTitle:item.countryName forState:UIControlStateNormal];
    
     LSTimeZoneItemObject * timeItem = [item.timeZoneList firstObject];
    
    [self updateTimeZone:timeItem];
}

- (void)updateTimeZone:(LSTimeZoneItemObject *)item {
    [LSPrePaidManager manager].zoneItem = item;
    [self.timeZoneButton setTitle:[[LSPrePaidManager manager] getTimeZoneText:item] forState:UIControlStateNormal];
    
    NSString *zone = [[LSPrePaidManager manager] getZone];
    NSString * time = [[LSPrePaidManager manager] getNewTimeZoneDate:zone];
    NSString * timeStr = [[time componentsSeparatedByString:@"-"] lastObject];
    
    [self updateBeginTime:timeStr];
}

- (void)updateDate:(NSString *)str {
    [LSPrePaidManager manager].yaerStr = str;
    [self.timeButton setTitle:str forState:UIControlStateNormal];
    
    NSString * endTime = [[LSPrePaidManager manager] getEndTime:[LSPrePaidManager manager].benginTime];
    [self.endTimeButton setTitle:endTime forState:UIControlStateNormal];
    
    NSString * localTime = [NSString stringWithFormat:@"%@-%@",str,[LSPrePaidManager manager].benginTime];
    NSString *zone = [[LSPrePaidManager manager] getZone];
    [self updateLocalTime:localTime andZone:zone];
}

- (void)updateBeginTime:(NSString *)time {
    if ([LSPrePaidManager manager].yaerStr.length > 0) {
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
 
    
    NSDate *date = [[LSPrePaidManager manager]stingDateToDate:time dateFormat:@"MMM dd,yyyy-HH:mm" andZone:zone];

    NSString *dateString = [[LSPrePaidManager manager]getNowDateFromatAnDate:date];
    
    
    if ([[LSPrePaidManager manager]nowtimeIsInBeginTime:time]) {
         dateString = [[LSPrePaidManager manager] daylightSavingBeginTime:dateString];
    }
    
    NSArray * array = [dateString componentsSeparatedByString:@"-"];
    NSString * endTime = [[LSPrePaidManager manager] getEndTime:[array lastObject]];
    self.localTimeLabel.text = [NSString stringWithFormat:@"Your local time :%@ - %@",[dateString stringByReplacingOccurrencesOfString:@"-" withString:@" "],endTime];
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

 

@end
