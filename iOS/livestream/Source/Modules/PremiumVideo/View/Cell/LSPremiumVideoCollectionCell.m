//
//  LSPremiumVideoCollectionCell.m
//  livestream
//
//  Created by Albert on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPremiumVideoCollectionCell.h"

@implementation LSPremiumVideoCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.mainView.layer.masksToBounds = YES;
    self.mainView.layer.cornerRadius = 5.f;
    self.mainView.layer.borderColor = Color(153, 153, 153, 1).CGColor;
    self.mainView.layer.borderWidth = 0.5f;
    
    self.headImgView.layer.masksToBounds = YES;
    self.headImgView.layer.cornerRadius = self.headImgView.bounds.size.height/2;
    
    self.durationLabel.layer.masksToBounds = YES;
    self.durationLabel.layer.cornerRadius = 3.f;
    
    [self.titleLabel setFont: [UIFont fontWithName:@"Arial-BoldMT" size:14]];
    [self.titleLabel setTextColor:[UIColor colorWithRed:56/255.0 green:56/255.0 blue:56/255.0 alpha:1/1.0]];
    
    [self.introLabel setFont:[UIFont fontWithName:@"ArialMT" size:12]];
    [self.introLabel setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1/1.0]];
    
    [self.nameLabel setFont:[UIFont fontWithName:@"Arial-BoldMT" size:12]];
    [self.nameLabel setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
    
    [self.yearLabel setFont:[UIFont fontWithName:@"ArialMT" size:11]];
    [self.yearLabel setTextColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1/1.0]];
    //[self.onlineImgView setHidden:YES];
}

+(NSString *)cellIdentifier
{
    return @"LSPremiumVideoCollectionCell";
}

-(void)setVideoItemObject:(LSPremiumVideoListItemObject *)obj
{
    
}

-(IBAction)userBtnOnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(premiumVideoCellUserBtnOnClicked:)]) {
        [self.delegate premiumVideoCellUserBtnOnClicked:self.tag];
    }
}

-(IBAction)collectBtnOnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(premiumVideoCellCollectBtnOnClicked:)]) {
        [self.delegate premiumVideoCellCollectBtnOnClicked:self.tag];
    }
}

@end
