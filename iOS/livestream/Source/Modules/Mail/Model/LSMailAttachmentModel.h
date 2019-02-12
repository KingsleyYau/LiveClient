//
//  LSMailAttachmentModel.h
//  livestream
//
//  Created by Randy_Fan on 2018/12/13.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    AttachmentTypeFreePhoto,
    AttachmentTypePrivatePhoto,
    AttachmentTypeGreetingVideo,
    AttachmentTypePrivateVideo,
    AttachmentTypeSendPhoto
} AttachmentType;

typedef enum : NSUInteger {
    SendAttachmentTypeSelf,
    SendAttachmentTypeLady
} SendAttachmentType;

typedef enum : NSUInteger {
    ExpenseTypeNo = 0,
    ExpenseTypeYes = 1,
    ExpenseTypeExpire = 2,
    ExpenseTypePaying = 3
} ExpenseType;

@interface LSMailAttachmentModel : NSObject

#pragma mark - common
/** 附件类型 */
@property (nonatomic, assign) AttachmentType attachType;
/** 发送类型 */
@property (nonatomic, assign) SendAttachmentType sendType;
/** 邮件ID */
@property (nonatomic, copy) NSString *mailId;
/** 是否已回复(意向信) */
@property (nonatomic, assign) BOOL isReplied;
/** 是否收费(EMF) */
@property (nonatomic, assign) BOOL isFree;

#pragma mark - FreePhoto
/** 原图url */
@property (nonatomic, copy) NSString* originImgUrl;
/** 小图url */
@property (nonatomic, copy) NSString * smallImgUrl;
/** 模糊图url */
@property (nonatomic, copy) NSString * blurImgUrl;

#pragma mark - PrivatePhoto
/** 图片id */
@property (nonatomic, copy) NSString* photoId;
/** 图片描述 */
@property (nonatomic, copy) NSString* photoDesc;

#pragma mark - FreeVideo
/** 8秒视频url(意向信) */
@property (nonatomic, copy) NSString *shortVideoUrl;
/** 总视频时长(意向信) */
@property (nonatomic, assign) CGFloat videoTime;
/** 视频url */
@property (nonatomic, copy) NSString *videoUrl;
/** 视频封面原图url */
@property (nonatomic, copy) NSString *videoCoverUrl;

#pragma mark - PrivateVideo
/** 视频封面小图url */
@property (nonatomic, copy) NSString *videoSmallCoverUrl;
/** 微视频ID */
@property (nonatomic, copy) NSString *videoId;
/** 微视频描述 */
@property (nonatomic, copy) NSString *videoDesc;
/** 附件付费情况 */
@property (nonatomic, assign) ExpenseType expenseType;

@end
