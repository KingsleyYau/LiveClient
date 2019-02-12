//
//  LSMailFileItem.h
//  livestream
//
//  Created by Calvin on 2018/12/14.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    FileType_Add = 0,
    FileType_Photo,
} FileType;

typedef enum : NSUInteger {
    UploadStatus_uploading = 0,
    UploadStatus_succeed,
    UploadStatus_error,
} UploadStatus;


@interface LSMailFileItem : NSObject

@property (nonatomic,copy) NSString * fileId;
@property (nonatomic,copy) NSString * fileName;
@property (nonatomic,copy) NSString * filePath;
@property (nonatomic,copy) NSString * msg; //上传信息
@property (nonatomic,copy) NSString * url;
@property (nonatomic,strong) UIImage * image;
@property (nonatomic,assign) FileType type;
@property (nonatomic,assign) UploadStatus uploadStatus;
@end
