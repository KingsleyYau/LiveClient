//
//  LiveFinshViewController.h
//  livestream
//
//  Created by randy on 2017/9/20.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "KKViewController.h"
#import "LiveRoom.h"

@interface LiveFinshViewController : KKViewController

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *tipLabel;

@property (weak, nonatomic) IBOutlet UIView *recommandView;

@property (weak, nonatomic) IBOutlet UICollectionView *recommandCollectionView;

@property (nonatomic, strong) LiveRoom *liveRoom;

@end
