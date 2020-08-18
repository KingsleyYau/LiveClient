//
//  LSVideoItemCellViewModelProtocol.h
//  livestream
//
//  Created by logan on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LSVideoItemCellViewModelProtocol <NSObject>

@optional
/**
 获取视频标题
 */
- (NSString *)getVideoItemModelTitle;
/**
  获取视频描述内容
*/
- (NSString *)getVideoItemModelDetail;
/**
  获取视频的用户昵称
*/
- (NSString *)getVideoItemModelUsername;
/**
  获取视频的用户年龄
*/
- (NSString *)getVideoItemModelUserAge;
/**
  获取视频的时长
*/
- (NSString *)getVideoItemModelVideoTime;
/**
  获取视频的用户头像
*/
- (NSString *)getVideoItemModelUserHeadImg;
/**
  获取视频的封面图
*/
- (NSString *)getVideoItemModelCoverImg;
/**
  是否收藏
*/
- (BOOL)getVideoItemModelIsFavorite;
/**
  是否在线
*/
- (BOOL)getVideoItemModelIsOnline;

@end

@protocol LSVideoItemCellViewControlProtocol <NSObject>

@optional
- (void)itemCellViewFavoriteCheck:(UIView *)view data:(id<LSVideoItemCellViewModelProtocol>)data;
- (void)itemCellViewToVideoDetailCheck:(UIView *)view data:(id<LSVideoItemCellViewModelProtocol>)data;
- (void)itemCellViewToUserDetailCheck:(UIView *)view data:(id<LSVideoItemCellViewModelProtocol>)data;

@end

NS_ASSUME_NONNULL_END
