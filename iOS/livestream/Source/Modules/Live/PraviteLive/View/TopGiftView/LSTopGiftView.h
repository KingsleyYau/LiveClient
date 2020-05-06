//
//  LSTopGiftView.h
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LiveRoom.h"
#import "LSGiftManager.h"
@protocol LSTopGiftViewDelegate <NSObject>

- (void)topGiftViewDidSelectItem:(LSGiftManagerItem*)item;

@end

@interface LSTopGiftView : UIView
@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) id<LSTopGiftViewDelegate> delegate;
@property (nonatomic, strong) LiveRoom *liveRoom;
@property (weak, nonatomic) IBOutlet UIImageView *loading;
@property (nonatomic, assign) BOOL isShowGiftData;
-(void)getGiftData;
@end

 
