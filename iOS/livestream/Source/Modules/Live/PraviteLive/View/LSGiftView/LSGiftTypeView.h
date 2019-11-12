//
//  LSGiftTypeView.h
//  livestream
//
//  Created by Calvin on 2019/9/5.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSGiftTypeViewDelegate <NSObject>

- (void)giftTypeViewSelectIndexRow:(NSInteger)row;

@end

@interface LSGiftTypeView : UIView

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray * items;
@property (weak, nonatomic) id<LSGiftTypeViewDelegate> delegate;

- (void)selectTypeRow:(NSInteger)row isAnimated:(BOOL)animated;
@end
 
