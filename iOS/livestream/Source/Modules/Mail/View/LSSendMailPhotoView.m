//
//  LSSendMailPhotoView.m
//  livestream
//
//  Created by Calvin on 2018/12/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSSendMailPhotoView.h"
#import "LSSendMailPhotoCell.h"
#import "LSMailFileItem.h"
@interface LSSendMailPhotoView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@end

@implementation LSSendMailPhotoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //[self setUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUI];
}

- (void)setUI {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat height = self.frame.size.height;
    layout.itemSize = CGSizeMake(height , height);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    self.collectionView = [[LSCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self addSubview:self.collectionView];
    
    UINib *nib = [UINib nibWithNibName:@"LSSendMailPhotoCell" bundle:[LiveBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[LSSendMailPhotoCell cellIdentifier]];
}

- (void)setPhotoArray:(NSArray *)photoArray {
    _photoArray = photoArray;
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photoArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSSendMailPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSSendMailPhotoCell cellIdentifier] forIndexPath:indexPath];
   
    LSMailFileItem * item = self.photoArray[indexPath.row];
    [cell updateMailPhotoStatus:item];
    
    cell.removeBtn.tag = indexPath.row+99;
    [cell.removeBtn addTarget:self action:@selector(removePhoto:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


- (void)removePhoto:(UIButton *)btn {
    NSInteger row = btn.tag - 99;
    if ([self.delegate respondsToSelector:@selector(sendMailPhotoViewRemoveRow:)]) {
        [self.delegate sendMailPhotoViewRemoveRow:row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(sendMailPhotoViewDidRow:)]) {
        [self.delegate sendMailPhotoViewDidRow:indexPath.row];
    }
}


@end
