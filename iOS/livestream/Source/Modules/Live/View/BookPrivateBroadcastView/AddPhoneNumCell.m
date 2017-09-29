//
//  AddPhoneNumCell.m
//  testDemo
//
//  Created by Calvin on 17/9/25.
//  Copyright © 2017年 dating. All rights reserved.
//

#import "AddPhoneNumCell.h"
#import "UIView+YYAdd.h"
#import "NSBundle+DeviceFamily.h"
#import "CalvinSwitch.h"

@implementation AddPhoneNumCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

+ (NSString *)cellIdentifier {
    return @"AddPhoneNumCell";
}

+ (NSInteger)cellHeight {
    return 100;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (id)getUITableViewCell:(UITableView*)tableView isOpen:(BOOL)isOpen
{
    AddPhoneNumCell *cell = (AddPhoneNumCell *)[tableView dequeueReusableCellWithIdentifier:[AddPhoneNumCell cellIdentifier]];
    
    if (nil == cell){
        NSArray *nib = [[NSBundle mainBundle] loadNibNamedWithFamily:[AddPhoneNumCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    CalvinSwitch * vgSwitch = [[CalvinSwitch alloc]initWithFrame:CGRectMake(0, 0, cell.switchBGView.frame.size.width, cell.switchBGView.frame.size.height) onColor:[UIColor colorWithHexString:@"5d0e86"] offColor:[UIColor colorWithHexString:@"b5b5b5"] font:[UIFont systemFontOfSize:14] ballSize:16];
    vgSwitch.on = isOpen;
    [cell.switchBGView addSubview:vgSwitch];
    [vgSwitch addTarget:cell action:@selector(switchOn:) forControlEvents:UIControlEventValueChanged];
    
    return cell;
}

- (void)switchOn:(CalvinSwitch *)vgSwitch
{
    if ([self.delegate respondsToSelector:@selector(addPhoneNumCellSwitchOn:)]) {
        [self.delegate addPhoneNumCellSwitchOn:vgSwitch.on];
    }
    
    [vgSwitch removeFromSuperview];
    vgSwitch = nil;
}

- (IBAction)addBtnDid:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(addPhoneNumCellAddBtnDid)]) {
        [self.delegate addPhoneNumCellAddBtnDid];
    }
}

- (IBAction)changeBtnDid:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(addPhoneNumCellChangeBtnDid)]) {
        [self.delegate addPhoneNumCellChangeBtnDid];
    }
}

@end
