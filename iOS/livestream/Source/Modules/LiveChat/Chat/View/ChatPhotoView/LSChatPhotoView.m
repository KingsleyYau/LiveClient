//
//  ChatPhotoView.m
//  dating
//
//  Created by test on 16/7/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import "LSChatPhotoView.h"
#import "LSChatPhotoCollectionViewCell.h"
#import "LSChatPhotoDataManager.h"
#import "LSChatPhoneAlbumPhoto.h"
@interface LSChatPhotoView ()
@property (nonatomic, strong) NSIndexPath * oldPath;
@property (nonatomic, strong) LSChatPhotoDataManager * chatPhotoManager;
@property (nonatomic, strong) NSArray * items;
@end

@implementation LSChatPhotoView

+ (instancetype)PhotoView:(id)owner{
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSChatPhotoView" owner:owner options:nil];
    LSChatPhotoView* view = [nibs objectAtIndex:0];

    // 设置布局样式
    UICollectionViewFlowLayout *flowlayout = [[UICollectionViewFlowLayout alloc] init];
    flowlayout.minimumLineSpacing = 0;
    flowlayout.minimumInteritemSpacing = 0;
    flowlayout.itemSize = CGSizeMake(screenSize.width/2, screenSize.width/2);
    flowlayout.scrollDirection = UICollectionViewScrollDirectionVertical;

    view.chatPhotoCollectionView.collectionViewLayout = flowlayout;
    
    UINib *nib = [UINib nibWithNibName:@"LSChatPhotoCollectionViewCell" bundle:[LiveBundle mainBundle]];
    [view.chatPhotoCollectionView registerNib:nib forCellWithReuseIdentifier:[LSChatPhotoCollectionViewCell cellIdentifier]];
    
    view.chatPhotoManager = [LSChatPhotoDataManager manager];
    
    view.photoCamBtn.layer.cornerRadius = view.photoCamBtn.frame.size.height/2;
    view.photoCamBtn.layer.masksToBounds = YES;
    
    view.photoAlbumBtn.layer.cornerRadius = view.photoAlbumBtn.frame.size.height/2;
    view.photoAlbumBtn.layer.masksToBounds = YES;
    
    return view;
}

- (void)reloadData{
    self.items = [LSChatPhotoDataManager manager].photoPathArray;
    [self.chatPhotoCollectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LSChatPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[LSChatPhotoCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    // 防止数组越界
    if (indexPath.row < self.items.count) {
        LSChatPhoneAlbumPhoto *albumPhoto = [self.items objectAtIndex:indexPath.row];
        
        [[PHImageManager defaultManager] requestImageForAsset:albumPhoto.asset
                                                   targetSize:CGSizeMake(screenSize.width/2,screenSize.width/2)
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:nil
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    if (result) {
                                                        [cell.photoImageView setImage:result];
                                                    }
                                                }];
        
        
        cell.photoEditView.hidden = !albumPhoto.isEdit;
        cell.sendBtn.tag = indexPath.row;
        cell.viewBtn.tag = indexPath.row;
        
        [cell.sendBtn addTarget:self action:@selector(sendBtnDid:) forControlEvents:UIControlEventTouchUpInside];
        [cell.viewBtn addTarget:self action:@selector(viewBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    }

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    self.photoAlbumBtn.hidden = YES;
    self.photoCamBtn.hidden = YES;
    
    for (int i = 0; i< self.items.count; i++) {
        LSChatPhoneAlbumPhoto *albumPhoto = [self.items objectAtIndex:i];
        if (i == indexPath.row) {
            albumPhoto.isEdit = !albumPhoto.isEdit;
            if (!albumPhoto.isEdit) {
                self.photoAlbumBtn.hidden = NO;
                if (!self.isCamShare) {
                    self.photoCamBtn.hidden = NO;
                }
            }
        }else
        {
            albumPhoto.isEdit = NO;
        }
    }
     [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
    
    [self.chatPhotoCollectionView reloadData];
}

- (void)sendBtnDid:(UIButton *)btn {
    
    for (int i = 0; i< self.items.count; i++) {
        LSChatPhoneAlbumPhoto *albumPhoto = [self.items objectAtIndex:i];
       albumPhoto.isEdit = NO;
    }
    self.photoAlbumBtn.hidden = NO;
    if (!self.isCamShare) {
        self.photoCamBtn.hidden = NO;
    }
    [self.chatPhotoCollectionView reloadData];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(chatPhotoView:didSendSelectItem:)]) {
        [self.delegate chatPhotoView:self didSendSelectItem:btn.tag];
    }
}

- (void)viewBtnDid:(UIButton *)btn {
    
    for (int i = 0; i< self.items.count; i++) {
        LSChatPhoneAlbumPhoto *albumPhoto = [self.items objectAtIndex:i];
        albumPhoto.isEdit = NO;
    }
    self.photoAlbumBtn.hidden = NO;
    if (!self.isCamShare) {
        self.photoCamBtn.hidden = NO;
    }
    [self.chatPhotoCollectionView reloadData];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(chatPhotoView:didViewSelectItem:)]) {
        [self.delegate chatPhotoView:self didViewSelectItem:btn.tag];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    for ( LSChatPhoneAlbumPhoto *albumPhoto in self.items) {
        if (albumPhoto.isEdit) {
            albumPhoto.isEdit = NO;
            self.photoAlbumBtn.hidden = NO;
            if (!self.isCamShare) {
                self.photoCamBtn.hidden = NO;
            }
            [self.chatPhotoCollectionView reloadData];
            break;
        }
    }
}

- (IBAction)camBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatPhotoViewOpenCam)]) {
        [self.delegate chatPhotoViewOpenCam];
    }
}

- (IBAction)albumBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(chatPhotoViewOpenAlbumList)]) {
        [self.delegate chatPhotoViewOpenAlbumList];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
}
@end
