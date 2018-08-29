//
//  SelectCoverViewCell.h
//  livestream
//
//  Created by randy on 17/6/19.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SelectCoverViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, strong) UIButton *userButton;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UILabel *label;

- (UIView *)snapshotView;
+ (NSString *)cellIdentifier;


//- (void)setCellCoverImage:(CoverPhotoItemObject *)coverDic;


@end
