//
//  LSTopGiftView.m
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSTopGiftView.h"
#import "GiftItemCollectionViewCell.h"
#import "LSGiftManager.h"
@interface LSTopGiftView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) NSArray * items;
@end

@implementation LSTopGiftView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamed:@"LSTopGiftView" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        UIView *containerView = [[LiveBundle mainBundle] loadNibNamed:@"LSTopGiftView" owner:self options:nil].firstObject;
        CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        containerView.frame = newFrame;
        [self addSubview:containerView];
         
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (void)initialize {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
  
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"GiftItemCollectionViewCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier]];
}

-(void)getGiftData {
    
    [[LSGiftManager manager]getRoomRandomGiftList:self.liveRoom.roomId finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.items = giftList;
                if (giftList.count > 5) {
                 self.items = [giftList subarrayWithRange:NSMakeRange(0, 5)];
                }
                
                [self.collectionView reloadData];
            }
            else {
                
            }
        });
    }];
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
    GiftItemCollectionViewCell *cell = (GiftItemCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[GiftItemCollectionViewCell cellIdentifier] forIndexPath:indexPath];
    result = cell;
    
    LSGiftManagerItem *item = self.items[indexPath.row];
    [cell updateItem:item manLevel:self.liveRoom.imLiveRoom.manLevel lovelLevel:self.liveRoom.imLiveRoom.loveLevel type:GiftListTypeNormal];
    cell.giftBigImageView.hidden = YES;
    return result;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
 
    CGFloat w = self.tx_width/self.items.count;
 
    return CGSizeMake(w, self.tx_height);
}
@end
