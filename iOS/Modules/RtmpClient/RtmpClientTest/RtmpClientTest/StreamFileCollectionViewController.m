//
//  StreamFileCollectionViewController.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/13.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import "StreamFileCollectionViewController.h"
#import "StreamFileCollectionViewCell.h"
#import <AVFoundation/AVFoundation.h>

@implementation FileItem
@end

@interface StreamFileCollectionViewController ()
@property (weak) IBOutlet UICollectionView *collectionView;
@property (strong) NSMutableArray *items;

@end

@implementation StreamFileCollectionViewController

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"File List";

    UIBarButtonItem *selectAllBarItem = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStyleDone target:self action:@selector(selectAll:)];
    self.navigationItem.rightBarButtonItem = selectAllBarItem;
    
    [self setupCollectionView];

    self.items = [NSMutableArray array];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *inputDir = [NSString stringWithFormat:@"%@/input", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:inputDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSInteger index = 0;
    NSArray *fileArray = [fileManager contentsOfDirectoryAtPath:inputDir error:nil];
    for (NSString *fileName in fileArray) {
        BOOL flag = YES;
        NSString *filePath = [inputDir stringByAppendingPathComponent:fileName];
        if ([fileManager fileExistsAtPath:filePath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    FileItem *item = [[FileItem alloc] init];
                    item.fileName = fileName;
                    item.filePath = filePath;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        UIImage *image = [self getThumbImage:item.filePath];
                        item.image = image;
                        item.firstShowImage = YES;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            
//                            NSLog(@"%@::viewDidLoad(), [%ld, Reload]", NSStringFromClass([self class]), index);
                            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                        });
                    });
                    [self.items addObject:item];
                    index++;
                }
            }
        }
    }

    [self reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setupCollectionView {
    NSBundle *bundle = [NSBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:@"StreamFileCollectionViewCell" bundle:bundle];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:[StreamFileCollectionViewCell cellIdentifier]];

    self.collectionView.backgroundView = nil;
    self.collectionView.backgroundColor = [UIColor clearColor];
}

#pragma mark - 数据逻辑
- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)selectAll:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectAllFile:)]) {
        [self.delegate didSelectAllFile:self.items];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - (UICollectionViewDataSource)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StreamFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[StreamFileCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    [cell reset];
    
    NSMutableArray *visableItems = [NSMutableArray array];
    for(NSIndexPath *indexPath in collectionView.indexPathsForVisibleItems) {
        [visableItems addObject:@(indexPath.row)];
    }
    
//    NSLog(@"%@::cellForItemAtIndexPath(), [%ld, Show], %p", NSStringFromClass([self class]), indexPath.row, cell);
    if (indexPath.row < self.items.count) {
        FileItem *item = [self.items objectAtIndex:indexPath.row];
        //        cell.fileNameLabel.text = [NSString stringWithFormat:@"%@", item.fileName];
        if ( item.firstShowImage ) {
//            NSLog(@"%@::cellForItemAtIndexPath(), [%ld, Show First], %p", NSStringFromClass([self class]), indexPath.row, cell);
            item.firstShowImage = NO;
            cell.fileImageView.alpha = 0.0f;
            [UIView animateWithDuration:1.0f
                             animations:^{
                                 cell.fileImageView.alpha = 1.0;
                             }];
        }
        cell.fileImageView.image = item.image;
    }

    //    __weak typeof(self) weakSelf = self;
    //    NSInteger preLoadIndex = (indexPath.row + 6);
    //    preLoadIndex = (preLoadIndex < self.items.count) ? preLoadIndex : self.items.count;
    //    for (NSInteger i = indexPath.row; i < self.items.count; i++) {
    //        FileItem *item = [self.items objectAtIndex:i];
    //        if (item.image == nil) {
    //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    //                @synchronized(weakSelf) {
    //                    item.image = [self getThumbImage:item.filePath];
    //                }
    //            });
    //        }
    //    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.items.count) {
        FileItem *item = [self.items objectAtIndex:indexPath.row];
        if ([self.delegate respondsToSelector:@selector(didSelectFile:)]) {
            [self.delegate didSelectFile:item];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIImage *)getThumbImage:(NSString *)videoPath {
    if (videoPath) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        gen.maximumSize = CGSizeMake(640, 640);
        CMTime time = CMTimeMakeWithSeconds(0.0, 600); //取第5秒，一秒钟600帧
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        if (error) {
            NSLog(@"%@::getThumbImage(), error:%@", NSStringFromClass([StreamFileCollectionViewCell class]), error);
            return nil;
        }
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return thumb;
    } else {
        return nil;
    }
}

@end
