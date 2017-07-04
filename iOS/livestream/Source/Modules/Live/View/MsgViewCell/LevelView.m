//
//  LevelView.m
//  livestream
//
//  Created by randy on 17/6/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "LevelView.h"

@implementation LevelView


+ (instancetype)getLevelView{
    
    LevelView* levelView = [[[NSBundle mainBundle] loadNibNamed:@"LevelView" owner:nil options:nil] firstObject];
    
    levelView.layer.cornerRadius = 8;
    levelView.layer.masksToBounds = YES;
    
    return levelView;
}

@end
