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
    
    // 导航
    NSArray* array = [self.inputDir componentsSeparatedByString:@"/"];
    NSString* dir = [array lastObject];
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
    for (NSString *fileName in fileArray) {
        BOOL flag = YES;
        NSString *filePath = [self.inputDir stringByAppendingPathComponent:fileName];
        if ([fm fileExistsAtPath:filePath isDirectory:&flag]) {
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
}

#pragma mark - 数据逻辑
- (void)reloadData {
    [self.collectionView reloadData];
}

- (void)selectAll:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectAllFile:)]) {
        NSMutableArray *items = [NSMutableArray array];
        for (FileItem* item in self.items) {
            if (!item.isDirectory && [item.fileName hasSuffix:@".mp4"]) {
                [items addObject:item];
            }
        }
        [self.delegate didSelectAllFile:items];
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
    for(NSIndexPath *indexPath in collectionView.indexPathsForVisibleItems) {
        [visableItems addObject:@(indexPath.row)];
    }
    
//    NSLog(@"%@::cellForItemAtIndexPath(), [%ld, Show], %p", NSStringFromClass([self class]), indexPath.row, cell);
    if (indexPath.row < self.items.count) {
        FileItem *item = [self.items objectAtIndex:indexPath.row];
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
        
        if (item.isDirectory) {
            cell.fileNameLabel.text = [NSString stringWithFormat:@"%@", item.fileName];
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
            if ([self.delegate respondsToSelector:@selector(didSelectFile:)]) {
                [self.delegate didSelectFile:item];
            }
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
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
        StreamFileCollectionViewCell* cell = (StreamFileCollectionViewCell *)sender.view;
        NSIndexPath* indexPath = [self.collectionView indexPathForCell:cell];
        FileItem *item = [self.items objectAtIndex:indexPath.row];
        UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Edit" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *delAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSFileManager *fm = [NSFileManager defaultManager];
            NSError* error;
            [fm removeItemAtPath:item.filePath error:&error];
            if (error) {
                NSLog(@"%@::longPressGesture( [Delete] ), error:%@", NSStringFromClass([self class]), error);
            } else {
                [self.items removeObjectAtIndex:indexPath.row];
                [self reloadData];
            }
        }];
        [alertVC addAction:delAction];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:cancelAction];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

@end
