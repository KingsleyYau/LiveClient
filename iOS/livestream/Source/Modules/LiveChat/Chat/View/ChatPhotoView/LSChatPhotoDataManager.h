//
//  ChatPhotoDataManager.h
//  dating
//
//  Created by Calvin on 2018/12/21.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
@protocol ChatPhotoDataManagerDelegate <NSObject>
@optional;

- (void)chatPhotoDataManagerReloadData;

- (void)onChoosePhotoURL:(NSString *)url;
@end

@interface LSChatPhotoDataManager : NSObject

+ (instancetype)manager;

@property (nonatomic, weak) id<ChatPhotoDataManagerDelegate> delegate;

@property (nonatomic, strong) NSArray * photoPathArray;

/**
 *  添加委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)addDelegate:(id<ChatPhotoDataManagerDelegate>)delegate;

/**
 *  移除委托
 *
 *  @param delegate 委托
 *
 *  @return 是否成功
 */
- (BOOL)removeDelegate:(id<ChatPhotoDataManagerDelegate>)delegate;

/**
 *  刷新相册
 *
 *  @param ascending 是否按时间顺序
 */
- (void)getAllAssetInPhotoAblumWithAscending:(BOOL)ascending;

/**
 *  获取原图尺寸地址
 *
 *  @param image 图片
 */
- (NSString *)getOriginalPhotoPath:(UIImage *)image andImageName:(NSString *)name;

/**
 *  选择图片
 *
 *  @param url 本地路径
 */
- (void)choosePhotoURL:(NSString *)url;

/**
 *  保存图片
 *
 *  @param image 图片
 */
- (void)synchronousSaveImageWithPhotosWithImage:(UIImage *)image;

//重置编辑状态
- (void)resetEditState;
@end


