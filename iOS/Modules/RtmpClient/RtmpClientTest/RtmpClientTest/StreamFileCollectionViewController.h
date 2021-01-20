//
//  StreamFileCollectionViewController.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/13.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StreamBaseViewController.h"

@interface FileItem : NSObject
@property (strong) NSString *fileName;
@property (strong) NSString *filePath;
@property (strong) UIImage *image;
@property (assign) BOOL firstShowImage;
@property (assign) BOOL isDirectory;
@property (assign) BOOL isUnknowFormat;
@property (nonatomic, assign, readonly) BOOL isVideo;
@end

@protocol StreamFileCollectionViewControllerDelegate <NSObject>
- (void)didPlayFile:(FileItem *)fileItem;
- (void)didPlayAllFile:(NSArray<FileItem *>*)fileItemArray;
- (void)didPublishFile:(FileItem *)fileItem;
@end

@interface StreamFileCollectionViewController : StreamBaseViewController
@property (weak) id<StreamFileCollectionViewControllerDelegate> delegate;
@property (strong) NSString *inputDir;
@end
