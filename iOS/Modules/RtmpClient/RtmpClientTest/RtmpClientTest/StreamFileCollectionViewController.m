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

    [self setupCollectionView];

    self.items = [NSMutableArray array];
    NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *inputDir = [NSString stringWithFormat:@"%@/input", cacheDir];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:inputDir withIntermediateDirectories:YES attributes:nil error:nil];

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
                    item.image = [self getThumbImage:filePath];
                    [self.items addObject:item];
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

#pragma mark - (UICollectionViewDataSource)
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    StreamFileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[StreamFileCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    [cell reset];

    if (indexPath.row < self.items.count) {
        FileItem *item = [self.items objectAtIndex:indexPath.row];
//        cell.fileNameLabel.text = [NSString stringWithFormat:@"%@", item.fileName];
        cell.fileImageView.image = item.image;
    }

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
        gen.maximumSize = CGSizeMake(1920, 1080);
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
