//
//  ChatPhotoView.h
//  dating
//
//  Created by test on 16/7/7.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSChatPhotoView;

@protocol ChatPhotoViewDelegate <NSObject>
@optional
- (void)chatPhotoView:(LSChatPhotoView *)chatPhotoView didSendSelectItem:(NSInteger)item;

- (void)chatPhotoView:(LSChatPhotoView *)chatPhotoView didViewSelectItem:(NSInteger)item;

- (void)chatPhotoViewOpenCam;

- (void)chatPhotoViewOpenAlbumList;
@end


@interface LSChatPhotoView : UIView<UICollectionViewDelegate, UICollectionViewDataSource>


@property (weak, nonatomic) IBOutlet LSCollectionView* chatPhotoCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *photoCamBtn;
@property (weak, nonatomic) IBOutlet UIButton *photoAlbumBtn;
@property (nonatomic, assign) BOOL isCamShare;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camBtnTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *camBtnH;

/** 代理 */
@property (nonatomic,weak) id<ChatPhotoViewDelegate> delegate;

+ (instancetype)PhotoView:(id)owner;

/**
 *  刷新界面
 */
- (void)reloadData;


@end
