//
//  LSPrepaidDateView.h
//  livestream
//
//  Created by Calvin on 2020/3/24.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSPrePaidManager.h"
#import "LSCountryTimeZoneItemObject.h"
#import "LSScheduleDurationItemObject.h"
@protocol LSPrepaidDateViewDelegate <NSObject>

- (void)prepaidDateViewBtnDid:(UIButton*)button;

@end

@interface LSPrepaidDateView : UIView

@property (weak, nonatomic) IBOutlet UIButton * countriesButton;
@property (weak, nonatomic) IBOutlet UIButton *timeZoneButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *beginTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *endTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *creditsButton;
@property (weak, nonatomic) IBOutlet UILabel *localTimeLabel;
@property (weak, nonatomic) id<LSPrepaidDateViewDelegate> delegate;

- (void)updateNewBeginTime;
- (void)updateCountries:(LSCountryTimeZoneItemObject*)item;
- (void)updateTimeZone:(LSTimeZoneItemObject *)item;
- (void)updateCredits:(LSScheduleDurationItemObject *)item;
- (void)updateDate:(NSString *)str;
- (void)updateBeginTime:(NSString *)time;
- (void)resetBtnState;
@end



