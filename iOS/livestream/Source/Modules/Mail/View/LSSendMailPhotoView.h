//
//  LSSendMailPhotoView.h
//  livestream
//
//  Created by Calvin on 2018/12/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSSendMailPhotoViewDelegate <NSObject>

- (void)sendMailPhotoViewDidRow:(NSInteger)row;
- (void)sendMailPhotoViewRemoveRow:(NSInteger)row;
@end

@interface LSSendMailPhotoView : UIView
@property (strong, nonatomic) UICollectionView *collectionView;

@property (weak, nonatomic) id <LSSendMailPhotoViewDelegate> delegate;
@property (strong, nonatomic) NSArray *photoArray;


@end

