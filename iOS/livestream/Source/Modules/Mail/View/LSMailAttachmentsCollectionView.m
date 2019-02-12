//
//  LSMailAttachmentsCollectionView.m
//  livestream
//
//  Created by test on 2018/12/26.
//  Copyright © 2018 net.qdating. All rights reserved.
//

#import "LSMailAttachmentsCollectionView.h"
#import "LSMailAttachmentCollectionViewCell.h"

@interface LSMailAttachmentsCollectionView()<UICollectionViewDelegate,UICollectionViewDataSource>


@end


@implementation LSMailAttachmentsCollectionView
- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialize];
}

- (void)initialize {
    self.delegate = self;
    self.dataSource = self;
    self.scrollEnabled = NO;
//    self.alwaysBounceVertical = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemSize = (screenSize.width - 42) / 3;
    layout.minimumLineSpacing = 14;
    layout.minimumInteritemSpacing = 0;
    layout.itemSize = CGSizeMake(itemSize,itemSize);
    self.collectionViewLayout = layout;
    //注册cell
    [self registerNib:[UINib nibWithNibName:@"LSMailAttachmentCollectionViewCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[LSMailAttachmentCollectionViewCell cellIdentifier]];
}



#pragma mark - UICollectionViewDataSource method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *result = [[UICollectionViewCell alloc] init];
   LSMailAttachmentCollectionViewCell *cell = (LSMailAttachmentCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSMailAttachmentCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    result = cell;
    // 数据填充
    LSMailAttachmentModel *item = [self.items objectAtIndex:indexPath.row];
    
    if( cell.imageViewLoader ) {
        [cell.imageViewLoader stop];
    }
    // 加载
    [cell.imageViewLoader loadImageWithImageView:cell.photoImageView options:0 imageUrl:item.smallImgUrl placeholderImage:nil];
    

    return result;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([self.collectionViewDelegate respondsToSelector:@selector(mailAttachmentsCollectionView:didSelectItemAtIndexPath:)]) {
        [self.collectionViewDelegate mailAttachmentsCollectionView:collectionView didSelectItemAtIndexPath:indexPath];
    }
}




@end
