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
@property (assign) bool firstShowImage;
@property (assign) bool isDirectory;
@property (assign) bool isUnknowFormat;
@end

@protocol StreamFileCollectionViewControllerDelegate <NSObject>
- (void)didSelectFile:(FileItem *)fileItem;
- (void)didSelectAllFile:(NSArray<FileItem *>*)fileItemArray;
@end

@interface StreamFileCollectionViewController : StreamBaseViewController
@property (weak) id<StreamFileCollectionViewControllerDelegate> delegate;
@property (strong) NSString *inputDir;
@end
