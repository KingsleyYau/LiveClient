//
//  BarrageModelCell.h
//  BarrageDemo
//
//  Created by siping ruan on 16/9/22.
//  Copyright © 2016年 siping ruan. All rights reserved.
//

#import "BarrageViewCell.h"
#import "ImageViewLoader.h"

@class BarrageModel, BarrageView;

@interface BarrageModelCell : BarrageViewCell

@property (weak, nonatomic) IBOutlet UILabel* labelName;
@property (weak, nonatomic) IBOutlet UILabel* labelMessage;
@property (weak, nonatomic) IBOutlet UIView* labelMessageBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageViewTopFit* imageViewHeader;
@property (strong, nonatomic) ImageViewLoader* imageViewHeaderLoader;

@property (strong, nonatomic) BarrageModel *model;

+ (instancetype)cellWithBarrageView:(BarrageView *)barrageView;

@end
