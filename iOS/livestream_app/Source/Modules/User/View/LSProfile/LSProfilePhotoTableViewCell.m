//
//  LSProfilePhotoTableViewCell.m
//  livestream
//
//  Created by test on 2017/12/27.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LSProfilePhotoTableViewCell.h"
#import "LSLoginManager.h"
@implementation LSProfilePhotoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.profilePhoto.layer.cornerRadius = 52/2;
    self.profilePhoto.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


+ (NSString *)cellIdentifier {
    return @"LSProfilePhotoTableViewCell";
}

+ (NSInteger)cellHeight {
    return 74;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSProfilePhotoTableViewCell *cell = (LSProfilePhotoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSProfilePhotoTableViewCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSProfilePhotoTableViewCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.textLabel.textColor = COLOR_WITH_16BAND_RGB(0x3c3c3c);
    }
    
    return cell;
}

- (void)updateAvatarStatus
{
    NSString * str = @"";
    switch ([LSLoginManager manager].loginItem.photoStatus) {
        case PHOTOVERIFYSTATUS_HANDLDING:{
            // 审核中
            str = [NSString stringWithFormat:@"%@ (%@)",NSLocalizedStringFromSelf(@"Avatar"),NSLocalizedStringFromSelf(@"Pending Approval")];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
            
            NSRange ranges = NSMakeRange(0, str.length);
          [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x3c3c3c) range:ranges];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:ranges];
            NSRange range = [str rangeOfString:NSLocalizedStringFromSelf(@"Pending Approval")];
            [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x00A0E9) range:range];
            
            self.textLabel.attributedText = attributedString;
            
        }break;
        case PHOTOVERIFYSTATUS_NOPASS:{
            // 审核不通过
            str = [NSString stringWithFormat:@"%@ (%@)",NSLocalizedStringFromSelf(@"Avatar"),NSLocalizedStringFromSelf(@"Rejected")];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
            NSRange ranges = NSMakeRange(0, str.length);
            [attributedString addAttribute:NSForegroundColorAttributeName value:COLOR_WITH_16BAND_RGB(0x3c3c3c) range:ranges];
            [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:ranges];
            NSRange range = [str rangeOfString:NSLocalizedStringFromSelf(@"Rejected")];
            [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
            
            self.textLabel.attributedText = attributedString;
        }break;
        case PHOTOVERIFYSTATUS_NOPHOTO_AND_FINISH:{
            // 没有头像及审核成功
            str = NSLocalizedStringFromSelf(@"Avatar");
            
            self.textLabel.text = str;
        }break;
        default:
            break;
    }
}

@end
