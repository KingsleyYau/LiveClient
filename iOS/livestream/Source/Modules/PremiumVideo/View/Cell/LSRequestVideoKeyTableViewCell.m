//
//  LSRequestVideoKeyTableViewCell.m
//  livestream
//  PremiumVideo RequestVideoKey 列表cell
//  Created by Albert on 2020/7/29.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSRequestVideoKeyTableViewCell.h"

@implementation LSRequestVideoKeyTableViewCell

+ (NSString *)cellIdentifier {
    return @"LSRequestVideoKeyTableViewCell";
}

+ (NSInteger)cellHeight {
    return 120;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // 创建新的
    self.imageViewLoader = [LSImageViewLoader loader];
    
    [self.expiryLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
    [self.expiryLabel setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];
    
    [self.titleLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:16]];
    [self.titleLabel setTextColor:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1/1.0]];
    
    [self.nameLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    [self.nameLabel setTextColor:[UIColor colorWithRed:30/255.0 green:158/255.0 blue:251/255.0 alpha:1/1.0]];
    
    self.bottomView.layer.masksToBounds = YES;
    self.bottomView.layer.cornerRadius = 5.f;
    
    self.headImgView.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = self.headImgView.bounds.size.height * 0.5f;
    
    self.viewKeyBtn.layer.masksToBounds = YES;
    self.viewKeyBtn.layer.cornerRadius = self.viewKeyBtn.bounds.size.height * 0.5f;
    
    self.durationLabel.layer.masksToBounds = YES;
    self.durationLabel.layer.cornerRadius = 5.f;
    
    self.titleLabelH.constant = ceil([[self.titleLabel font] lineHeight]);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0xD4000000).CGColor,(__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x25000000).CGColor, (__bridge id)COLOR_WITH_16BAND_RGB_ALPHA(0x00000000).CGColor];
    gradientLayer.locations = @[@0,@0.75,@1.0];
    gradientLayer.startPoint = CGPointMake(0, 1.0);
    gradientLayer.endPoint = CGPointMake(0, 0.0);
    gradientLayer.frame = CGRectMake(0, self.bottomView.bounds.size.height-20.f, self.bottomView.bounds.size.width, 20.f);
    [self.bottomView.layer addSublayer:gradientLayer];
}

+ (id)getUITableViewCell:(UITableView*)tableView {
    LSRequestVideoKeyTableViewCell *cell = (LSRequestVideoKeyTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSRequestVideoKeyTableViewCell cellIdentifier]];
    if (nil == cell){
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSRequestVideoKeyTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        
        if (cell.imageViewLoader == nil) {
            cell.imageViewLoader = [LSImageViewLoader loader];
        }
        
        cell.corverImgView.layer.masksToBounds = YES;
        cell.corverImgView.layer.cornerRadius = 3.f;
        
        cell.headImgView.layer.masksToBounds = YES;
        cell.headImgView.layer.cornerRadius = cell.headImgView.bounds.size.height * 0.5f;
        
        cell.viewKeyBtn.layer.masksToBounds = YES;
        cell.viewKeyBtn.layer.cornerRadius = cell.viewKeyBtn.bounds.size.height * 0.5f;
        cell.viewKeyBtn.layer.borderColor = Color(186, 209, 231, 1).CGColor;
        cell.viewKeyBtn.layer.borderWidth = 0.5f;
        [cell.viewKeyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    
    return cell;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)collectBtnOnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestVideoKeyCellCollectBtnOnDid:)]) {
        [self.delegate requestVideoKeyCellCollectBtnOnDid:self.tag];
    }
}

- (IBAction)userBtnOnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestVideoKeyCellUserBtnOnDid:)]) {
        [self.delegate requestVideoKeyCellUserBtnOnDid:self.tag];
    }
}

- (IBAction)viewKeyBtnOnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestVideoKeyCellViewKeyBtnOnDid:)]) {
        [self.delegate requestVideoKeyCellViewKeyBtnOnDid:self.tag];
    }
}


@end
