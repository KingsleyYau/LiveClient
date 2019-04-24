//
//  ChatPhoneAlbumPhoto.h
//  dating
//
//  Created by Max on 16/8/26.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@interface LSChatPhoneAlbumPhoto : NSObject

///**
// *  缩略图片缓存路径
// */
//@property (strong) NSString* filePath;
//
///**
// *  相册原图路径
// */
//@property (strong) NSURL* assertUrl;

/**
 *  原始图片缓存路径
 */
@property (strong) NSString * originalPath;

//是否编辑模式
@property (assign) BOOL isEdit;

@property (strong) PHAsset *asset;

@property (nonatomic,copy) NSString* fileName;
@end
