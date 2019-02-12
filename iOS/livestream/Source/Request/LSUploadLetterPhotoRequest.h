//
//  LSUploadLetterPhotoRequest.h
//  dating
//   13.6.上传附件
//  Created by Alex on 17/9/11
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSSessionRequest.h"

@interface LSUploadLetterPhotoRequest : LSSessionRequest
/**
 * file                      上传头像文件名
 */
@property (nonatomic, copy) NSString* _Nullable file;
/**
 * fileName                      上传文件名
 */
@property (nonatomic, copy) NSString* _Nullable fileName;
@property (nonatomic, strong) UploadLetterPhotoFinishHandler _Nullable finishHandler;
@end
