//
//  LevelView.h
//  livestream
//
//  Created by randy on 17/6/12.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LevelView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *leveImageVIew;


@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

+ (instancetype)getLevelView;

@end
