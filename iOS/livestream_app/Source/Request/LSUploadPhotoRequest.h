//
//  LSUploadPhotoRequest.h
//  dating
//  2.9.提交用户头像接口（仅独立）
//  Created by Max on 17/12/21.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSUploadPhotoRequest : LSSessionRequest
/*
 *  @param photoName          上传头像文件名
 */
@property (nonatomic, copy) NSString* _Nonnull photoName;
@property (nonatomic, strong) UploadPhotoFinishHandler _Nullable finishHandler;
@end
