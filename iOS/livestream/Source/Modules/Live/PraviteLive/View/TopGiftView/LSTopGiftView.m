//
//  LSTopGiftView.m
//  livestream
//
//  Created by Calvin on 2019/9/2.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSTopGiftView.h"
#import "LSVIPLiveGiftListCell.h"

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
    
    NSMutableArray * images = [NSMutableArray array];
    for (int i = 1; i <= 7; i++) {
        UIImage * image = [UIImage imageNamed:[NSString stringWithFormat:@"Prelive_Loading%d",i]];
        [images addObject:image];
    }
    self.loading.animationImages = images;
    self.loading.animationDuration = 0.6;
    [self.loading startAnimating];
}

- (void)initialize {
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    //注册cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"LSVIPLiveGiftListCell" bundle:[LiveBundle mainBundle]] forCellWithReuseIdentifier:[LSVIPLiveGiftListCell cellIdentifier]];
}

-(void)getGiftData {
    self.loading.hidden = NO;
    self.button.hidden = YES;
    [[LSGiftManager manager]getRoomRandomGiftList:self.liveRoom.roomId finshHandler:^(BOOL success, NSArray<LSGiftManagerItem *> *giftList) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.loading.hidden = YES;
            if (success) {
                self.isShowGiftData = YES;
                if (giftList.count > 0) {
                    self.button.hidden = YES;
                    self.items = giftList;
                    if (giftList.count > 5) {
                        self.items = [giftList subarrayWithRange:NSMakeRange(0, 5)];
                    }
                    [self.collectionView reloadData];
                }
                else {
                    [self setButtonImage:NO];
                }
            }
            else {
                [self setButtonImage:YES];
            }
        });
    }];
}

- (void)setButtonImage:(BOOL)isRetry {
    
    self.button.hidden = NO;
    if (isRetry) {
        [self.button setImage:[UIImage imageNamed:@"Hangout_Invite_Fail"] forState:UIControlStateNormal];
        [self.button setTitle:NSLocalizedStringFromSelf(@"RETRY_TIP") forState:UIControlStateNormal];
        self.button.userInteractionEnabled = YES;
    }
    else {
        [self.button setImage:[UIImage imageNamed:@"Live_No_Yet_Gifts"] forState:UIControlStateNormal];
        [self.button setTitle:NSLocalizedStringFromSelf(@"GIFT_TIP") forState:UIControlStateNormal];
        self.button.userInteractionEnabled = NO;
    }
}

- (IBAction)buttonDid:(UIButton *)sender {
    self.button.hidden = YES;
    self.loading.hidden = NO;
    [self getGiftData];
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
    LSVIPLiveGiftListCell *cell = (LSVIPLiveGiftListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:[LSVIPLiveGiftListCell cellIdentifier] forIndexPath:indexPath];
    result = cell;
    
    LSGiftManagerItem *item = self.items[indexPath.row];
    [cell updateItem:item type:@"Nomal"];
    return result;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.delegate respondsToSelector:@selector(topGiftViewDidSelectItem:)]) {
        LSGiftManagerItem *item = self.items[indexPath.row];
        [self.delegate topGiftViewDidSelectItem:item];
    }
}
 
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
 
    CGFloat w = self.tx_width/5;
 
    return CGSizeMake(w, self.tx_height);
}
@end
