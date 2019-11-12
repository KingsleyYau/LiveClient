//
//  LSMyCartCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMyCartCell.h"
#import "LSImageViewLoader.h"

@interface LSMyCartCell()<UITableViewDelegate,UITableViewDataSource,LSMyCartStoreCellDelegate>
@property (nonatomic, strong) LSImageViewLoader *loader;
@property (nonatomic, strong) NSMutableArray<LSCartGiftItem*> *giftList;
@property (nonatomic, strong) LSMyCartItemObject *cartItem;
@end

@implementation LSMyCartCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.loader = [LSImageViewLoader loader];
        self.giftList = [NSMutableArray array];
        self.cartItem = [[LSMyCartItemObject alloc] init];
    }
    return self;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSMyCartCell *cell = (LSMyCartCell *)[tableView dequeueReusableCellWithIdentifier:[LSMyCartCell cellIdentifier]];
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMyCartCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.tableView.delegate = cell;
    cell.tableView.dataSource = cell;
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.checkoutBtn.layer.cornerRadius = 5;
    self.checkoutBtn.layer.masksToBounds = YES;
    
    self.shopBtn.layer.cornerRadius = 5;
    self.shopBtn.layer.borderWidth = 1;
    self.shopBtn.layer.borderColor = COLOR_WITH_16BAND_RGB(0x007aff).CGColor;
    self.shopBtn.layer.masksToBounds = YES;
    
    self.headImageView.layer.cornerRadius = self.headImageView.tx_height / 2;
    self.headImageView.layer.masksToBounds = YES;
}

- (void)setupContent:(LSMyCartItemObject *)model {
    self.cartItem = model;
    self.nameLabel.text = model.anchorItem.anchorNickName;
    [self.loader loadImageFromCache:self.headImageView options:0 imageUrl:model.anchorItem.anchorAvatarImg placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"] finishHandler:^(UIImage *image) {

    }];
    for (LSFlowerGiftBaseInfoItemObject *obj in model.giftList) {
        LSCartGiftItem *item = [[LSCartGiftItem alloc] init];
        item.giftId = obj.giftId;
        item.giftName = obj.giftName;
        item.giftImg = obj.giftImg;
        item.giftNumber = obj.giftNumber;
        item.giftPrice = obj.giftPrice;
        item.anchorId = model.anchorItem.anchorId;
        [self.giftList addObject:item];
    }
    [self.tableView reloadData];
}

- (void)removeData:(LSCartGiftItem *)item {
    NSInteger index = 0;
    for (index = 0; index < self.giftList.count; index++) {
        LSCartGiftItem *model = [self.giftList objectAtIndex:index];
        if ([item.giftId isEqualToString:model.giftId]) {
            break;
        }
    }
    [self.giftList removeObjectAtIndex:index];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate/UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.giftList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LSCartGiftItem *item = [self.giftList objectAtIndex:indexPath.row];
    LSMyCartStoreCell *cell = [LSMyCartStoreCell getUITableViewCell:tableView];
    [cell setupContent:item];
    cell.delagate = self;
    return cell;
}

#pragma mark - 点击事件
- (IBAction)clickAnchorHead:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectAnchorInfo:)]) {
        [self.delegate didSelectAnchorInfo:self.cartItem];
    }
}

- (IBAction)continueShopAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectContinueShop:)]) {
        [self.delegate didSelectContinueShop:self.cartItem];
    }
}

- (IBAction)checkoutAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectChectOut:)]) {
        [self.delegate didSelectChectOut:self.cartItem];
    }
}

#pragma mark - LSMyCartStoreCellDelegate
- (void)didSelectChangeGiftNum:(LSMyCartStoreCell *)cell item:(LSCartGiftItem *)item num:(int)num {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeCartGiftNum:item:num:)]) {
        [self.delegate didChangeCartGiftNum:cell item:item num:num];
    }
}

- (void)showChangeError {
    if (self.delegate && [self.delegate respondsToSelector:@selector(disShowChangeError)]) {
        [self.delegate disShowChangeError];
    }
}

- (void)didSelectRemoveGift:(LSCartGiftItem *)item {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRemoveCartGift:item:)]) {
        [self.delegate didRemoveCartGift:self item:item];
    }
}

- (void)didSelectGiftInfo:(LSCartGiftItem *)item {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCartGiftInfo:)]) {
        [self.delegate didCartGiftInfo:item];
    }
}

- (void)getConvertRectToVc:(UITextField *)textField rect:(CGRect)rect {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didGetConvertRectToVc:rect:)]) {
        [self.delegate didGetConvertRectToVc:textField rect:rect];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.loader stop];
    [self.headImageView sd_cancelCurrentImageLoad];
    self.headImageView.image = nil;
    [self.giftList removeAllObjects];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self);
}

@end
