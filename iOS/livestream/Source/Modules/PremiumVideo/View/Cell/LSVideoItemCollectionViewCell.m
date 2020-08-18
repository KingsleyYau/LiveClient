//
//  LSVideoItemCollectionViewCell.m
//  livestream
//
//  Created by logan on 2020/7/31.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSVideoItemCollectionViewCell.h"
#import "LSVideoItemCellView.h"

@interface LSVideoItemCollectionViewCell ()<LSVideoItemCellViewDelegate>

@property (nonatomic, strong) LSVideoItemCellView * cellContentView;

/** 数据模型 */
@property (nonatomic, strong) LSPremiumVideoinfoItemObject * model;
/** index */
@property (nonatomic, assign) NSInteger index;

@end

@implementation LSVideoItemCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.layer.cornerRadius = 4;
    self.layer.masksToBounds = YES;
    _cellContentView = [[LSVideoItemCellView alloc] init];
    _cellContentView.delegate = self;
    [self.contentView addSubview:_cellContentView];
    [_cellContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(1, 1, 2, 1));
    }];
}

- (void)dealloc{
    NSLog(@"dealloc -");
}

+ (NSString *)identifier{
    return NSStringFromClass([self class]);
}

- (void)setModel:(LSPremiumVideoinfoItemObject *)model index:(NSInteger)index{
    _model = model;
    _index = index;
    [_cellContentView setViewWithModel:model];
}

#pragma mark - LSVideoItemCellViewDelegate
- (void)itemCellView:(LSVideoItemCellView *)cellView favoriteCheckModel:(id<LSVideoItemCellViewModelProtocol>)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(favoriteCellCheck:dataModel:index:)]) {
        [self.delegate favoriteCellCheck:self dataModel:self.model index:self.index];
    }
}
- (void)itemCellView:(LSVideoItemCellView *)cellView toUserDetailCheckModel:(id<LSVideoItemCellViewModelProtocol>)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toUserDetailCellCheck:dataModel:index:)]) {
        [self.delegate toUserDetailCellCheck:self dataModel:self.model index:self.index];
    }
}
- (void)itemCellView:(LSVideoItemCellView *)cellView toVideoDetailCheckModel:(id<LSVideoItemCellViewModelProtocol>)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(toVideoDetailCellCheck:dataModel:index:)]) {
        [self.delegate toVideoDetailCellCheck:self dataModel:self.model index:self.index];
    }
}

@end
