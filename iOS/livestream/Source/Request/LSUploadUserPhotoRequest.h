//
//  LSGetGiftTypeListRequest.h
//  dating
//  2.23.提交用户头像
//  Created by Alex on 19/08/28
//  Copyright © 2019年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSUploadUserPhotoRequest : LSSessionRequest

/**
 * 2.23.提交用户头像接口
 *
 * file             上传头像文件名
 * finishHandler    接口回调s
 */
@property (nonatomic, copy) NSString* _Nullable file;
@property (nonatomic, strong) UploadUserPhotoFinishHandler _Nullable finishHandler;
@end
