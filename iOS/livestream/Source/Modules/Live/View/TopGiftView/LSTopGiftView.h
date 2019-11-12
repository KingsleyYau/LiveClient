//
//  LSTopGiftView.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"

@interface LSTopGiftView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) LiveRoom *liveRoom;

-(void)getGiftData;
@end

 
