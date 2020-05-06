//
//  LSGiftTypeView.h
//  livestream
//
//  Created by Calvin on 2019/9/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoomStyleItem.h"

@protocol LSGiftTypeViewDelegate <NSObject>

- (void)giftTypeViewSelectIndexRow:(NSInteger)row;

@end

@interface LSGiftTypeView : UIView

@property (weak, nonatomic) IBOutlet LSCollectionView *collectionView;
@property (nonatomic, strong) NSArray * items;
@property (weak, nonatomic) id<LSGiftTypeViewDelegate> delegate;

@property (nonatomic, strong) RoomStyleItem *roomStyleItem;

- (void)selectTypeRow:(NSInteger)row isAnimated:(BOOL)animated;
@end
 
