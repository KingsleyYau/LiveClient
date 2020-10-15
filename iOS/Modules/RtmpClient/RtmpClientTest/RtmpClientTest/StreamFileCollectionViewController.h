//
//  StreamFileCollectionViewController.h
//  RtmpClientTest
//
//  Created by Max on 2020/10/13.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileItem : NSObject
@property (strong) NSString *fileName;
@property (strong) NSString *filePath;
@property (strong) UIImage *image;
@property (assign) bool firstShowImage;
@end

@protocol StreamFileCollectionViewControllerDelegate <NSObject>
- (void)didSelectFile:(FileItem *)fileItem;
@end

@interface StreamFileCollectionViewController : UIViewController
@property (weak) id<StreamFileCollectionViewControllerDelegate> delegate;
@end
