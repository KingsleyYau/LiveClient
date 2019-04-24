//
//  LSMailDetailPrivatePhotoCell.m
//  livestream
//
//  Created by Randy_Fan on 2018/12/26.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "LSMailDetailPrivatePhotoCell.h"
#import "LSPrivatePhotoCollectionViewCell.h"

#define CELLTOPHEIGHT 67

@interface LSMailDetailPrivatePhotoCell ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray<LSMailAttachmentModel *> *imageItems;

@end

@implementation LSMailDetailPrivatePhotoCell

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSMailDetailPrivatePhotoCell *cell = (LSMailDetailPrivatePhotoCell *)[tableView dequeueReusableCellWithIdentifier:[LSMailDetailPrivatePhotoCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMailDetailPrivatePhotoCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageItems = [[NSMutableArray alloc] init];
        
        cell.collectionView.showsVerticalScrollIndicator = NO;
        cell.collectionView.showsHorizontalScrollIndicator = NO;
        cell.collectionView.scrollEnabled = NO;
        cell.collectionView.delegate = cell;
        cell.collectionView.dataSource = cell;
        
        UINib *cellNib = [UINib nibWithNibName:@"LSPrivatePhotoCollectionViewCell" bundle:[LiveBundle mainBundle]];
        [cell.collectionView registerNib:cellNib forCellWithReuseIdentifier:[LSPrivatePhotoCollectionViewCell cellIdentifier]];
    }
    return cell;
}

- (void)setupCollection:(NSMutableArray *)imageItems {
    self.imageItems = imageItems;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSMailAttachmentModel *model = self.imageItems[indexPath.row];
    LSPrivatePhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSPrivatePhotoCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    [cell setupImageDetail:model];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    LSMailAttachmentModel *item = self.imageItems[indexPath.row];
    if ([self.delegate respondsToSelector:@selector(didCollectionViewItem:model:)]) {
        [self.delegate didCollectionViewItem:indexPath.row model:item];
    }
}

+ (NSString *)cellIdentifier {
    return @"LSMailDetailPrivatePhotoCell";
}

@end
