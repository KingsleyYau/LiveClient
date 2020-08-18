//
//  LSCustomTopTabView.m
//  TestDarkDemo
//
//  Created by logan on 2020/7/29.
//  Copyright © 2020 test. All rights reserved.
//

#import "LSCustomTopTabView.h"

static const NSInteger BTN_TAG = 100;

@interface LSCustomTopTabView ()

@property (copy, nonatomic) NSArray <NSString *> * titleArr;

/** scrollview */
@property (nonatomic, strong) UIScrollView * scrollView;

/** 标题控件数组 */
@property (nonatomic, strong) NSMutableArray <UIButton *> * itemArr;

/** 下划线view */
@property (nonatomic, strong) UIView * lineView;

/** 当前选择的按钮 */
@property (nonatomic, strong) UIButton * selectBtn;

@end

@implementation LSCustomTopTabView

- (instancetype)initWithFrame:(CGRect)frame titleArr:(NSArray <NSString *> *)titleArr{
    if (self = [super initWithFrame:frame]) {
        self.titleArr = titleArr;
        self.titleNormalColor = [UIColor blackColor];//默认黑色
        self.titleSelectedColor = [UIColor grayColor];//默认灰色
        self.lineColor = self.titleSelectedColor;
        self.spaceX = 5;
        [self initSubView];
    }
    return self;
}

- (void)initSubView{
    
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.lineView];
    
    for (int i = 0; i < self.titleArr.count; i ++) {
        UIButton * btn = [[UIButton alloc] init];
        [btn setTitle:self.titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:_titleNormalColor forState:UIControlStateNormal];
        [btn setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
        btn.tag = BTN_TAG + i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.itemArr addObject:btn];
        [self.scrollView addSubview:btn];
    }
}

- (void)setIsSameWidth:(BOOL)isSameWidth{
    _isSameWidth = isSameWidth;
    [self setNeedsLayout];
}

- (void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    self.lineView.backgroundColor = _lineColor;
}

- (void)setTitleNormalColor:(UIColor *)titleColor{
    _titleNormalColor = titleColor;
    for (int i = 0; i < self.itemArr.count; i ++) {
        [self.itemArr[i] setTitleColor:_titleNormalColor forState:UIControlStateNormal];
    }
}

- (void)setTitleSelectedColor:(UIColor *)titleSelectedColor{
    _titleSelectedColor = titleSelectedColor;
    for (int i = 0; i < self.itemArr.count; i ++) {
        [self.itemArr[i] setTitleColor:_titleSelectedColor forState:UIControlStateSelected];
    }
}

- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    [self setNeedsLayout];
}

- (void)setSpaceX:(CGFloat)spaceX{
    _spaceX = spaceX;
    [self setNeedsLayout];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    
    CGFloat space = _spaceX;
    
    if (self.isSameWidth) {
        CGFloat btnWidth = (self.frame.size.width - (self.itemArr.count + 1) * space) / self.itemArr.count;
        for (int i = 0; i < self.itemArr.count; i ++) {
            UIButton * btn = self.itemArr[i];
            btn.frame = CGRectMake(space + (btnWidth + space) * i, 0, btnWidth, self.frame.size.height);
        }
        
    }else{
        self.scrollView.contentSize = CGSizeMake(space, 0);
        for (int i = 0; i < self.itemArr.count; i ++) {
            UIButton * btn = self.itemArr[i];
            [btn sizeToFit];
            btn.frame = CGRectMake(self.scrollView.contentSize.width, 0, btn.frame.size.width, self.frame.size.height);
            self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(btn.frame) + space, 0);
        }
    }
    
    if (self.currentIndex < self.itemArr.count) {
        UIButton * btn = self.itemArr[self.currentIndex];
        [self updataSelectStatus:btn];
    }
}

- (void)updataSelectStatus:(UIButton *)btn{
    
    CGRect oriBtnFrame = btn.frame;
    [btn sizeToFit];
    CGFloat lineWidth = btn.frame.size.width;
    btn.frame = oriBtnFrame;
    BOOL isOverWidth = lineWidth > btn.frame.size.width?YES:NO;
    
    btn.selected = YES;
    self.selectBtn.selected = NO;
    self.selectBtn = btn;
    [UIView animateWithDuration:0.3 animations:^{
        if (self.lineSameTitleWidth && !isOverWidth) {
            self.lineView.frame = CGRectMake(btn.frame.origin.x + (btn.frame.size.width - lineWidth) / 2, self.frame.size.height - 1, lineWidth, 1);
        }else{
            self.lineView.frame = CGRectMake(btn.frame.origin.x, self.frame.size.height - 1, btn.frame.size.width, 1);
        }
    }];
}

- (void)btnClick:(UIButton *)btn{
    
    if (btn == _selectBtn) return;
    
    [self updataSelectStatus:btn];
    NSInteger index = btn.tag - BTN_TAG;
    if ([self.delegate respondsToSelector:@selector(tabView:currentSelectIndex:)]) {
        [self.delegate tabView:self currentSelectIndex:index];
    }
    
    if(_scrollView.contentSize.width <= _scrollView.frame.size.width) return;
    if (btn.tx_x + btn.tx_width / 2 > _scrollView.tx_width / 2) {
        CGFloat centerX = btn.tx_x - (_scrollView.tx_width - btn.tx_width) / 2;
        if (btn.tx_x + _spaceX + (_scrollView.tx_width + btn.tx_width) / 2 >= _scrollView.contentSize.width) {
            centerX = _scrollView.contentSize.width - _scrollView.tx_width;
        }
        [_scrollView setContentOffset:CGPointMake(centerX, 0) animated:YES];
    }else{
        [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    /*
    if (_scrollView.contentSize.width < _scrollView.frame.size.width) {
        return;
    }
    CGRect rect = [_scrollView convertRect:btn.frame toView:self];
    CGFloat convertX = rect.origin.x;
    if (convertX - btn.frame.size.width < 0) {//内容往右移动
        CGFloat btnWidth = btn.frame.size.width;
        if (index > 0) {
            btnWidth = _itemArr[index - 1].frame.size.width;
        }
        CGFloat scrollX = (_scrollView.contentOffset.x + convertX - btnWidth - _spaceX) < 0?0:(_scrollView.contentOffset.x + convertX - btnWidth - _spaceX);
        [_scrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
    }
    
    CGFloat btnWidth = 2 * btn.frame.size.width;
    if (index < _itemArr.count - 1) {
        btnWidth = btn.frame.size.width + _itemArr[index + 1].frame.size.width;
    }
    if (convertX + btnWidth > _scrollView.frame.size.width) {//内容往左移动
        
        CGFloat willScrollX = _scrollView.contentOffset.x + _spaceX + btnWidth + convertX - _scrollView.frame.size.width;
        CGFloat totalSize = _scrollView.contentSize.width - _scrollView.frame.size.width;
        CGFloat scrollX = willScrollX>totalSize?totalSize:willScrollX;//convertX + btn.width - self.width;
        [_scrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
    }*/
}

- (void)tabScrollToIndex:(NSInteger)index{
    if (index < self.itemArr.count) {
        UIButton * btn = self.itemArr[index];
        if(btn == _selectBtn) return;
        [self updataSelectStatus:btn];
        if (_scrollView.contentSize.width < _scrollView.frame.size.width) {
            return;
        }
        CGFloat btnX = btn.frame.origin.x;
        CGFloat scrollX = btnX > _scrollView.contentSize.width - _scrollView.frame.size.width?_scrollView.contentSize.width - _scrollView.frame.size.width:btnX;

        [_scrollView setContentOffset:CGPointMake(scrollX, 0) animated:YES];
    }
}

#pragma mark - lazy
- (NSMutableArray *)itemArr{
    if (!_itemArr) {
        _itemArr = [NSMutableArray new];
    }
    return _itemArr;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 1, 0, 1)];
        [_lineView setBackgroundColor:self.lineColor];
    }
    return _lineView;
}

@end
