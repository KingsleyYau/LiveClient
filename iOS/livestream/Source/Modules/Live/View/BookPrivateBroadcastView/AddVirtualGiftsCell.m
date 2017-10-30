//
//  AddVirtualGiftsCell.m
//  testDemo
//
//  Created by Calvin on 17/9/25.
//  Copyright © 2017年 dating. All rights reserved.
//

#import "AddVirtualGiftsCell.h"
#import "NSBundle+DeviceFamily.h"
#import "CalvinSwitch.h"
#import "LSGiftItemObject.h"
#import "GiftNumItemObject.h"
#import "LiveGiftDownloadManager.h"
#import "LiveBundle.h"

#import <UIButton+WebCache.h>

@interface AddVirtualGiftsCell ()

@property (nonatomic, strong) UIButton *oldButton;
@property (nonatomic, strong) UIButton *oldNumButton;
@property (nonatomic, strong) LiveGiftDownloadManager *giftDownloadManager;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) CGFloat credit;
@end

@implementation AddVirtualGiftsCell

- (void)awakeFromNib {
    [super awakeFromNib];

    self.numBtn.layer.cornerRadius = 3;
    self.numBtn.layer.masksToBounds = YES;
    self.numBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x3c3c3c).CGColor;
    self.numBtn.layer.borderWidth = 0.5;

    self.numView.layer.borderColor = COLOR_WITH_16BAND_RGB(0x3c3c3c).CGColor;
    self.numView.layer.borderWidth = 0.5;
    self.numView.layer.cornerRadius = 10;
    self.numView.layer.masksToBounds = YES;

    self.giftDownloadManager = [LiveGiftDownloadManager manager];

    self.data = [NSArray array];
}

+ (NSString *)cellIdentifier {
    return @"AddVirtualGiftsCell";
}

+ (NSInteger)cellHeight {
    return 170;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)numBtnDid:(UIButton *)sender {
    self.numView.hidden = NO;
}

+ (id)getUITableViewCell:(UITableView *)tableView isShowVG:(BOOL)isShowVG {

    if (isShowVG) {
        AddVirtualGiftsCell *cell = (AddVirtualGiftsCell *)[tableView dequeueReusableCellWithIdentifier:[AddVirtualGiftsCell cellIdentifier]];

        if (nil == cell) {
            NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:[AddVirtualGiftsCell cellIdentifier] owner:tableView options:nil];
            cell = [nib objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        CalvinSwitch *vgSwitch = [[CalvinSwitch alloc] initWithFrame:CGRectMake(0, 0, cell.switchBGView.frame.size.width, cell.switchBGView.frame.size.height) onColor:COLOR_WITH_16BAND_RGB(0x5d0e86) offColor:COLOR_WITH_16BAND_RGB(0xb5b5b5) font:[UIFont systemFontOfSize:14] ballSize:16];
        vgSwitch.on = YES;
        [cell.switchBGView addSubview:vgSwitch];
        [vgSwitch addTarget:cell action:@selector(switchOn:) forControlEvents:UIControlEventValueChanged];

        return cell;
    } else {
        static NSString *cellName = @"AddVirtualGiftsCell_1";
        AddVirtualGiftsCell *cell = (AddVirtualGiftsCell *)[tableView dequeueReusableCellWithIdentifier:cellName];
        if (nil == cell) {
            cell = [[AddVirtualGiftsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
            cell.textLabel.text = NSLocalizedStringFromSelf(@"ADD_CIETUAL_GIFT");
        }

        CalvinSwitch *vgSwitch = [[CalvinSwitch alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 44 - 15, 15, 44, 20) onColor:COLOR_WITH_16BAND_RGB(0x5d0e86) offColor:COLOR_WITH_16BAND_RGB(0xb5b5b5) font:[UIFont systemFontOfSize:14] ballSize:16];
        vgSwitch.on = NO;
        [cell addSubview:vgSwitch];
        [vgSwitch addTarget:cell action:@selector(switchOn:) forControlEvents:UIControlEventValueChanged];
        return cell;
    }
}

- (void)getVirtualGiftList:(NSArray *)array {
    self.data = array;

    for (int i = 0; i < array.count; i++) {

        LSGiftItemObject *item = [array objectAtIndex:i];

        AllGiftItem *giftItem = [self.giftDownloadManager backGiftItemWithGiftID:item.giftId];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = COLOR_WITH_16BAND_RGB(0xdadada);
        button.frame = CGRectMake(i * 52, 0, 47, 47);
        button.layer.cornerRadius = 5;
        button.layer.masksToBounds = YES;
        button.tag = i + 88;
        [self.scrollView addSubview:button];
        [button addTarget:self action:@selector(virtualGiftDid:) forControlEvents:UIControlEventTouchUpInside];
        [button sd_setImageWithURL:[NSURL URLWithString:giftItem.infoItem.smallImgUrl] forState:UIControlStateNormal];

        if (i == 0) {
            self.oldButton = button;
            button.layer.borderColor = [UIColor redColor].CGColor;
            button.layer.borderWidth = 1;

            self.giftId = item.giftId;

            [self loadVGNum:item.sendNumList forGiftItem:giftItem];
        }
    }

    self.scrollView.contentSize = CGSizeMake(52 * array.count, 47);
}

- (void)loadVGNum:(NSArray *)array forGiftItem:(AllGiftItem *)giftItem {
    self.numView.hidden = YES;
    [self.numView removeAllSubviews];
    for (int i = 0; i < array.count; i++) {

        GiftNumItemObject *item = [array objectAtIndex:i];

        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, i * 30, self.numView.frame.size.width, 30);
        [button setTitle:[NSString stringWithFormat:@"%d", item.num] forState:UIControlStateNormal];
        [button setTitleColor:COLOR_WITH_16BAND_RGB(0x3c3c3c) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.tag = i + 20;
        [self.numView addSubview:button];
        [button addTarget:self action:@selector(selectNumBtnDid:) forControlEvents:UIControlEventTouchUpInside];

        if (item.isDefault) {
            self.num = item.num;
            self.oldNumButton = button;
            [self.numBtn setTitle:[NSString stringWithFormat:@"%ld", (long)self.num] forState:UIControlStateNormal];

            [button setBackgroundColor:COLOR_WITH_16BAND_RGB(0xf7cd3a)];

            self.credit = giftItem.infoItem.credit;
            CGFloat priceNum = self.credit * self.num;
            [self setPriceNum:priceNum];
        }
    }

    self.numView.contentSize = CGSizeMake(self.numView.frame.size.width, 30 * array.count);
}

- (void)virtualGiftDid:(UIButton *)button {
    self.oldButton.layer.borderColor = [UIColor clearColor].CGColor;
    self.oldButton.layer.borderWidth = 1;

    button.layer.borderWidth = 1;
    button.layer.borderColor = [UIColor redColor].CGColor;
    self.oldButton = button;

    LSGiftItemObject *item = [self.data objectAtIndex:button.tag - 88];

    AllGiftItem *giftItem = [self.giftDownloadManager backGiftItemWithGiftID:item.giftId];

    self.giftId = item.giftId;

    [self loadVGNum:item.sendNumList forGiftItem:giftItem];
}

- (void)selectNumBtnDid:(UIButton *)button {
    self.numView.hidden = YES;

    NSString *str = button.titleLabel.text;

    [self.numBtn setTitle:str forState:UIControlStateNormal];

    [self.oldNumButton setBackgroundColor:[UIColor whiteColor]];
    [button setBackgroundColor:COLOR_WITH_16BAND_RGB(0xf7cd3a)];
    self.oldNumButton = button;

    self.num = [str integerValue];

    [self setPriceNum:self.num * self.credit];
}

- (void)setPriceNum:(CGFloat)num {

    if ([self.delegate respondsToSelector:@selector(addVirtualGiftsCellSelectGiftId:andNum:)]) {
        [self.delegate addVirtualGiftsCellSelectGiftId:self.giftId andNum:self.num];
    }

    NSString *priceStr = [NSString stringWithFormat:@"%@  %0.1f %@", NSLocalizedStringFromSelf(@"TOTAL_PRICE"), num, NSLocalizedStringFromSelf(@"CRDITS")];
    NSMutableAttributedString *mAttStr = [[NSMutableAttributedString alloc] initWithString:priceStr];

    NSRange priceRange = [priceStr rangeOfString:[NSString stringWithFormat:@"%0.1f", num]];
    [mAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:20] range:priceRange];
    [mAttStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0xF7CD3A) range:priceRange];
    NSRange crditsRange = [priceStr rangeOfString:NSLocalizedStringFromSelf(@"CRDITS")];
    [mAttStr addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0xF7CD3A) range:crditsRange];

    self.priceLabel.attributedText = mAttStr;
}

- (void)switchOn:(CalvinSwitch *)vgSwitch {
    if (!vgSwitch.on) {
        self.giftId = @"";
    }

    if ([self.delegate respondsToSelector:@selector(addVirtualGiftsCellSwitchOn:)]) {
        [self.delegate addVirtualGiftsCellSwitchOn:vgSwitch.on];
    }

    [vgSwitch removeFromSuperview];
    vgSwitch = nil;
}

@end
