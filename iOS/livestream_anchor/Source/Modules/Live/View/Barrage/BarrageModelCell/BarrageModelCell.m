//
//  BarrageModelCell.m
//  BarrageDemo
//
//  Created by siping ruan on 16/9/22.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import "BarrageModelCell.h"
#import "BarrageView.h"
#import "LiveBundle.h"

@interface BarrageModelCell ()
@end

@implementation BarrageModelCell

- (instancetype)reloadCustomCell {
    return [[LiveBundle mainBundle] loadNibNamed:@"BarrageModelCell" owner:self options:0].firstObject;
}

+ (instancetype)cellWithBarrageView:(BarrageView *)barrageView {
    static NSString *reuseIdentifier = @"BarrageModelCell";
    BarrageModelCell *cell = [barrageView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[BarrageModelCell alloc] initWithIdentifier:reuseIdentifier];
    }
    
    cell.imageViewHeader.image = nil;
    cell.labelMessage.text = @"";
    
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.layer.cornerRadius = self.frame.size.height / 2;
//    self.layer.masksToBounds = YES;
    
    self.imageViewHeader.layer.cornerRadius = self.imageViewHeader.frame.size.height / 2;
    self.imageViewHeader.layer.masksToBounds = YES;
    
    self.labelMessageBackgroundView.layer.cornerRadius = self.labelMessageBackgroundView.frame.size.height / 2;
    self.labelMessageBackgroundView.layer.masksToBounds = YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imageViewHeader.layer.cornerRadius = self.imageViewHeader.frame.size.height / 2;
    self.imageViewHeader.layer.masksToBounds = YES;
    
    self.labelMessageBackgroundView.layer.cornerRadius = self.labelMessageBackgroundView.frame.size.height / 2;
    self.labelMessageBackgroundView.layer.masksToBounds = YES;
}

@end
