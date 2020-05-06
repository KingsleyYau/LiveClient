//
//  LSChatInputToolView.m
//  livestream
//
//  Created by Calvin on 2020/3/26.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSChatInputToolView.h"
#import "LSChatInputToolCell.h"
@interface LSChatInputToolView ()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic,strong) NSArray * items;
@property (nonatomic,strong) NSArray * selectItems;
@property (nonatomic,strong) NSMutableArray * countItems;
@end

@implementation LSChatInputToolView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        UIView *containerView = [[LiveBundle mainBundle] loadNibNamed:@"LSChatInputToolView" owner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"LSChatInputToolCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[LSChatInputToolCell cellIdentifier]];
    
    self.items = @[@"LS_Chat-Keyboard-PhotoGray",@"LS_Chat-EmotionGray",@"LS_ChatVoiceIcon",@"LS_Schedule_Request_Icon"];
    self.selectItems = @[@"",@"",@"",@""];
    self.countItems = [NSMutableArray arrayWithArray:@[@"",@"",@"",@""]];
    
    [self.collectionView reloadData];
}

- (void)updateUncount:(NSString*)count {
    
    [self.countItems removeLastObject];
    [self.countItems addObject:count];
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource method
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *result = [[UICollectionViewCell alloc] init];
    if (indexPath.row < self.items.count) {
        NSString * imageName = self.items[indexPath.row];

        LSChatInputToolCell *cell = (LSChatInputToolCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSChatInputToolCell cellIdentifier] forIndexPath:indexPath];
            result = cell;
        cell.iconBtn.tag = indexPath.row;
        [cell.iconBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        
        NSString * count = self.countItems[indexPath.row];
        if (count.length > 0) {
            cell.redLabel.hidden = NO;
            cell.redLabel.text = count;
        }else {
            cell.redLabel.hidden = YES;
            cell.redLabel.text = @"";
        }
    
        [cell.iconBtn addTarget:self action:@selector(voiceButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        if ([imageName isEqualToString:@"LS_ChatVoiceIcon"]) {
            [cell.iconBtn addTarget:self action:@selector(voiceButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
            [cell.iconBtn addTarget:self action:@selector(voiconBtnTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
            [cell.iconBtn addTarget:self action:@selector(voiceButtonDragOutside:) forControlEvents:UIControlEventTouchDragExit];
            [cell.iconBtn addTarget:self action:@selector(voiceButtonDragInside:) forControlEvents:UIControlEventTouchDragEnter];
        }
    }
    
    return result;
}

- (void)voiceButtonTouchUpInside:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(chatInputToolViewBtnDid:)]) {
        [self.delegate chatInputToolViewBtnDid:btn];
    }
}

- (void)voiceButtonTouchDown:(UIButton *)btn {
    if (btn.tag == 2 && [self.delegate respondsToSelector:@selector(voiceButtonTouchDown)]) {
        [self.delegate voiceButtonTouchDown];
    }
}

- (void)voiconBtnTouchUpOutside:(UIButton *)btn {
    if (btn.tag == 2 &&[self.delegate respondsToSelector:@selector(voiceButtonTouchUpOutside)]) {
        [self.delegate voiceButtonTouchUpOutside];
    }
}

- (void)voiceButtonDragOutside:(UIButton *)btn {
    if (btn.tag == 2 &&[self.delegate respondsToSelector:@selector(voiceButtonDragOutside)]) {
        [self.delegate voiceButtonDragOutside];
    }
}

- (void)voiceButtonDragInside:(UIButton *)btn {
    if (btn.tag == 2 &&[self.delegate respondsToSelector:@selector(voiceButtonDragInside)]) {
        [self.delegate voiceButtonDragInside];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
     
}
 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat w = screenSize.width/self.items.count;
    CGFloat h = self.frame.size.height;
    return CGSizeMake(w, h);
}

 -(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
     return UIEdgeInsetsMake(0, 0, 0, 0);
 }
 

@end
