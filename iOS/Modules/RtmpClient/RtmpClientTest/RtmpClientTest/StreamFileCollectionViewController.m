//
//  StreamFileCollectionViewController.m
//  RtmpClientTest
//
//  Created by Max on 2020/10/13.
//  Copyright © 2020年 net.qdating. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "StreamFileCollectionViewController.h"
#import "StreamFileCollectionViewCell.h"
#import "FileDownloadManager.h"
#import "RtmpPlayerOC.h"

@implementation FileItem
- (BOOL)isVideo {
    return [self.fileName localizedCaseInsensitiveContainsString:@".mp4"];
}
@end

@interface StreamFileCollectionViewController ()
@property (weak) IBOutlet UICollectionView *collectionView;
@property (strong) NSMutableArray *items;
@property (weak) IBOutlet UIImageView *imageView;

@end

@implementation StreamFileCollectionViewController

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 导航
    NSArray *array = [self.inputDir componentsSeparatedByString:@"/"];
    NSString *dir = [array lastObject];
    self.title = dir;
    UIBarButtonItem *selectAllBarItem = [[UIBarButtonItem alloc] initWithTitle:@"All" style:UIBarButtonItemStyleDone target:self action:@selector(selectAll:)];
    self.navigationItem.rightBarButtonItem = selectAllBarItem;

    // 列表
    [self setupCollectionView];

    // 数据
    self.items = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:self.inputDir withIntermediateDirectories:YES attributes:nil error:nil];

    NSInteger index = 0;
    NSArray *fileArray = [fm contentsOfDirectoryAtPath:self.inputDir error:nil];
    NSArray *sortFileArray = [fileArray sortedArrayUsingComparator:^(NSString *firstFileName, NSString *secondFileName) {
        NSString *firstFilePath = [self.inputDir stringByAppendingPathComponent:firstFileName];
        NSString *secondFilePath = [self.inputDir stringByAppendingPathComponent:secondFileName];
        NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstFilePath error:nil];
        NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondFilePath error:nil];
        id firstDate = [firstFileInfo objectForKey:NSFileModificationDate];
        id secondDate = [secondFileInfo objectForKey:NSFileModificationDate];
        NSComparisonResult order = [secondDate compare:firstDate];
        return order;
    }];
    
    for (NSString *fileName in sortFileArray) {
        BOOL flag = YES;
        NSString *filePath = [self.inputDir stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&flag]) {
            if (!flag) {
                // ignore .DS_Store
                if (![[fileName substringToIndex:1] isEqualToString:@"."]) {
                    FileItem *item = [[FileItem alloc] init];
                    item.fileName = fileName;
                    item.filePath = filePath;
                    [self.items addObject:item];
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        UIImage *image;
                        if (item.isVideo) {
                            image = [self getThumbImage:item.filePath];
                        } else {
                            image = [UIImage imageWithData:[NSData dataWithContentsOfFile:item.filePath]];
                        }

                        if (!image) {
                            image = [UIImage imageNamed:@"File"];
                        }

                        int ms = arc4random() % 200;
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ms * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
//                        dispatch_async(dispatch_get_main_queue(), ^{
                            item.image = image;
                            item.firstShowImage = YES;
                            
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                            [self.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
                        });
                    });
                    
                    index++;
                }
            } else {
                FileItem *item = [[FileItem alloc] init];
                item.fileName = fileName;
                item.filePath = filePath;
                item.isDirectory = flag;
                item.image = [UIImage imageNamed:@"Directory"];
                item.firstShowImage = NO;
                [self.items addObject:item];
                index++;
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
    self.collectionView.bounces = YES;
    self.collectionView.alwaysBounceVertical = YES;
}

#pragma mark - 数据逻辑
- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)selectAll:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didPlayAllFile:)]) {
        NSMutableArray *items = [NSMutableArray array];
        for (FileItem *item in self.items) {
            if (!item.isDirectory && [item.fileName hasSuffix:@".mp4"]) {
                [items addObject:item];
            }
        }
        [self.delegate didPlayAllFile:items];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - (UICollectionViewDataSource)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StreamFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[StreamFileCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    [cell reset];

    NSMutableArray *visableItems = [NSMutableArray array];
    for (NSIndexPath *indexPath in collectionView.indexPathsForVisibleItems) {
        [visableItems addObject:@(indexPath.row)];
    }

    //    NSLog(@"%@::cellForItemAtIndexPath(), [%ld, Show], %p", NSStringFromClass([self class]), indexPath.row, cell);
    if (indexPath.row < self.items.count) {
        FileItem *item = [self.items objectAtIndex:indexPath.row];
        cell.fileImageView.image = item.image;
        cell.fileNameLabel.text = [NSString stringWithFormat:@"%@", item.fileName];
        if (!item.isVideo) {
            cell.fileImageView.contentMode = UIViewContentModeScaleAspectFit;
        } else {
            cell.fileImageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        // 图片
        if (item.firstShowImage) {
            NSLog(@"%@::cellForItemAtIndexPath(), [%ld, Show Image First], %p", NSStringFromClass([self class]), indexPath.row, cell);
            item.firstShowImage = NO;
            cell.fileImageView.alpha = 0.0f;
            [UIView setAnimationsEnabled:YES];
            [UIView animateWithDuration:1.0f
                             animations:^{
                                 cell.fileImageView.alpha = 1.0;
                             }];
        } else {
            NSLog(@"%@::cellForItemAtIndexPath(), [%ld, Show], %p", NSStringFromClass([self class]), indexPath.row, cell);
        }

        // TODO:手势 - 长按弹出菜单
        cell.longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
        cell.longPress.minimumPressDuration = 0.5;
        [cell addGestureRecognizer:cell.longPress];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.items.count) {
        FileItem *item = [self.items objectAtIndex:indexPath.row];
        if (item.isDirectory) {
            NSString *inputDir = [NSString stringWithFormat:@"%@/%@", self.inputDir, item.fileName];
            StreamFileCollectionViewController *vc = [[StreamFileCollectionViewController alloc] init];
            vc.delegate = self.delegate;
            vc.inputDir = inputDir;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            if ([item isVideo]) {
                if ([self.delegate respondsToSelector:@selector(didPlayFile:)]) {
                    [self.delegate didPlayFile:item];
                }
                [self.navigationController popToRootViewControllerAnimated:YES];
            } else if (item.image) {
                StreamFileCollectionViewCell *cell = (StreamFileCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                [self showImage:item.image fromView:cell.fileImageView];
            }
        }
    }
}

- (UIImage *)getThumbImage:(NSString *)videoPath {
    if (videoPath) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
        // 获取视频图像实际开始时间 部分视频并非一开始就是有图像的 因此要获取视频的实际开始片段
        AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo].firstObject;
        NSArray<AVAssetTrackSegment *> *segs = videoTrack.segments;
        if (!segs.count) {
            return nil;
        }
        CMTime currentStartTime = kCMTimeZero;
        for (NSInteger i = 0; i < segs.count; i++) {
            if (!segs[i].isEmpty) {
                currentStartTime = segs[i].timeMapping.target.start;
                break;
            }
        }

        CMTime coverAtTimeSec = CMTimeMakeWithSeconds(1, asset.duration.timescale);
        // 如果想要获取的视频时间大于视频总时长 或者小于视频实际开始时间 则设置获取视频实际开始时间
        if (CMTimeCompare(coverAtTimeSec, asset.duration) == 1 || CMTimeCompare(coverAtTimeSec, currentStartTime) == -1) {
            coverAtTimeSec = currentStartTime;
        }

        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        gen.maximumSize = CGSizeMake(240, 240);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:coverAtTimeSec actualTime:&actualTime error:&error];
        if (error) {
            NSLog(@"%@::getThumbImage(), error:%@", NSStringFromClass([self class]), error);
            return nil;
        }
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        return thumb;
    } else {
        return nil;
    }
}

#pragma mark - 手势
- (void)longPressGesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        StreamFileCollectionViewCell *cell = (StreamFileCollectionViewCell *)sender.view;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
        FileItem *item = [self.items objectAtIndex:indexPath.row];
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:item.fileName message:nil preferredStyle:UIAlertControllerStyleActionSheet];

        UIAlertAction *delAction = [UIAlertAction actionWithTitle:@"Delete"
                                                            style:UIAlertActionStyleDestructive
                                                          handler:^(UIAlertAction *_Nonnull action) {
                                                              NSFileManager *fm = [NSFileManager defaultManager];
                                                              NSError *error;
                                                              [fm removeItemAtPath:item.filePath error:&error];
                                                              if (error) {
                                                                  NSLog(@"%@::longPressGesture( [Delete] ), error:%@", NSStringFromClass([self class]), error);
                                                              } else {
                                                                  [self.items removeObjectAtIndex:indexPath.row];
                                                                  [self reloadData];
                                                              }
                                                          }];
        [alertVC addAction:delAction];

        if (!item.isDirectory) {
            UIAlertAction *shareAction = [UIAlertAction actionWithTitle:@"Share"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *_Nonnull action) {
                                                                    NSURL *fileURL = [NSURL fileURLWithPath:item.filePath];
                                                                    UIActivityViewController *shareVC = [[UIActivityViewController alloc] initWithActivityItems:@[ fileURL ] applicationActivities:nil];
                                                                    [self presentViewController:shareVC animated:YES completion:nil];
                                                                }];
            [alertVC addAction:shareAction];
        } else {
            UIAlertAction *combineAction = [UIAlertAction actionWithTitle:@"Combine"
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                                      [self combineFrag:item];
                                                                  }];
            [alertVC addAction:combineAction];
        }

        if (!item.isDirectory && item.image) {
            UIAlertAction *publishImageAction = [UIAlertAction actionWithTitle:@"Publish"
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                                           if ([self.delegate respondsToSelector:@selector(didPublishFile:)]) {
                                                                               [self.delegate didPublishFile:item];
                                                                           }
                                                                           [self.navigationController popToRootViewControllerAnimated:YES];
                                                                       }];
            [alertVC addAction:publishImageAction];
        }

        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *_Nonnull action){

                                                             }];
        [alertVC addAction:cancelAction];

        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)combineFrag:(FileItem *)item {
    if (item.isDirectory) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSMutableArray *srcFilePaths = [NSMutableArray array];
            [[FileDownloadManager class] getAllVideo:item.filePath outputFilePaths:srcFilePaths];

            NSString *dstFilePath = [NSString stringWithFormat:@"%@/../%@.mp4", item.filePath, item.fileName];
            NSArray *sortPaths = [srcFilePaths sortedArrayUsingComparator:^(NSString *firstPath, NSString *secondPath) {
                NSDictionary *firstFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firstPath error:nil];
                NSDictionary *secondFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secondPath error:nil];
                id firstData = [firstFileInfo objectForKey:NSFileModificationDate];
                id secondData = [secondFileInfo objectForKey:NSFileModificationDate];
                return [firstData compare:secondData];
            }];

            [RtmpPlayerOC combine:sortPaths dstFilePath:dstFilePath];
            
            NSLog(@"%@::combineFrag(), [Finish]", NSStringFromClass([self class]));
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *tips = [NSString stringWithFormat:@"Combined %@", dstFilePath];
                [self toast:tips];
            });
        });
    }
}
@end
