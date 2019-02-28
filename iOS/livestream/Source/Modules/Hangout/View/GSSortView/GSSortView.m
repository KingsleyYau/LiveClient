//
//  GSSortView.m
//  GSSortView
//
//  Created by 帅高 on 2017/11/11.
//  Copyright © 2017年 gersces. All rights reserved.
//

#import "GSSortView.h"

@interface GSSortView ()<UIScrollViewDelegate>
//顶部标题框
@property (nonatomic,strong)UIScrollView *barScroller;
//下标线
@property (nonatomic,strong)UIImageView *markLineView;

@property (nonatomic,strong)UIButton *tmpItem;

@property (nonatomic,assign)NSInteger curIndex;

@property (nonatomic,assign)CGFloat tmpOff_X;

@end

@implementation GSSortView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        self.barScroller = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.barScroller.backgroundColor = [UIColor clearColor];
        self.barScroller.showsHorizontalScrollIndicator = NO;
        self.barScroller.scrollEnabled = NO;
        
        self.isBarEqualParts = NO;
        
        self.curIndex = 0;
        
        [self addSubview:self.barScroller];
    }
    return self;
}

- (void)reloadData{
    if (self.barTitles.count > 0) {
        [self configBarItems];
        [self configMarkLine];
    }
}

#pragma mark - 标题框的items
- (void)configBarItems{
    if (_isBarEqualParts) {
        //获取最长的标题的长度
        CGRect maxLongthRect = [self.barTitles[0] boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:self.itemFont],NSFontAttributeName, nil] context:nil];
        
        for (NSInteger i = 1; i < self.barTitles.count; i ++) {
            CGRect rect = [self.barTitles[i] boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:self.itemFont],NSFontAttributeName, nil] context:nil];
            
            if (maxLongthRect.size.width < rect.size.width) {
                maxLongthRect = rect;
            }
        }
        CGFloat itemWidth = maxLongthRect.size.width + 2 * self.itemBetween;
        
        for (NSInteger i = 0; i < self.barTitles.count; i ++) {
            UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
            item.frame = CGRectMake(i * itemWidth, 0, itemWidth, self.frame.size.height - self.lineHeight);
            item.tag = 1111 + i;
            item.titleLabel.font = [UIFont systemFontOfSize:self.itemFont];
            [item setTitle:_barTitles[i] forState:UIControlStateNormal];
            [item setTitleColor:self.textColor forState:UIControlStateNormal];
            [item setTitleColor:self.textSelectColor forState:UIControlStateSelected];
            [item addTarget:self action:@selector(itemClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.barScroller addSubview:item];
            if (i == 0) {
                item.selected = YES;
                self.tmpItem = item;
            }
        }
        self.barScroller.contentSize = CGSizeMake(itemWidth * self.barTitles.count,self.frame.size.height);
    } else{
        CGFloat item_X = 0;
        for (NSInteger i = 0; i < self.barTitles.count; i ++) {
            UIButton *item = [UIButton buttonWithType:UIButtonTypeCustom];
            item.tag = 1111 + i;
            item.titleLabel.font = [UIFont systemFontOfSize:self.itemFont];
            [item setTitle:self.barTitles[i] forState:UIControlStateNormal];
            [item setTitleColor:self.textColor forState:UIControlStateNormal];
            [item setTitleColor:self.textSelectColor forState:UIControlStateSelected];
            [item addTarget:self action:@selector(itemClickAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.barScroller addSubview:item];
            
            CGRect rect = [self.barTitles[i] boundingRectWithSize:CGSizeMake(MAXFLOAT, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:self.itemFont],NSFontAttributeName, nil] context:nil];
            item.frame = CGRectMake(item_X, 0, rect.size.width + 2 * self.itemBetween, self.frame.size.height - self.lineHeight);
            
            item_X += rect.size.width + 2 * self.itemBetween;
            
            if (i == 0) {
                item.selected = YES;
                self.tmpItem = item;
            }
        }
        self.barScroller.contentSize = CGSizeMake(item_X,self.frame.size.height);
    }
}

// 标题点击事件
- (void)itemClickAction:(UIButton *)sender{
    self.tmpItem.selected = NO;
    
    sender.selected = YES;
    self.tmpItem = sender;
    
    NSInteger index = sender.tag - 1111;
    if (self.curIndex != index) {
        self.curIndex = index;
        self.tmpOff_X = self.frame.size.width * self.curIndex;
        [self scrollMarkLineAndSelectedItem:self.tmpOff_X];
        
        if ([self.delegate respondsToSelector:@selector(gsSortViewDidScroll:)]) {
            [self.delegate gsSortViewDidScroll:self.curIndex];
        }
    }
}

#pragma mark - 下标线
- (void)configMarkLine{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height - self.lineHeight, self.barScroller.contentSize.width, self.lineHeight)];
    line.backgroundColor = [UIColor clearColor];
    [self.barScroller addSubview:line];
    
    self.markLineView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 0, self.lineHeight)];
    self.markLineView.image = self.lineImage;
    self.markLineView.contentMode = UIViewContentModeScaleToFill;
    UIButton *getItem = (UIButton *)[_barScroller viewWithTag:1111];
    self.markLineView.frame = CGRectMake(0, 0, self.markLineWidth > 0 ? self.markLineWidth : (getItem.frame.size.width - 2 * self.itemBetween), self.lineHeight);
    self.markLineView.center = CGPointMake(getItem.center.x, self.lineHeight / 2);
    self.markLineView.layer.cornerRadius = self.lineHeight / 2;
    self.markLineView.layer.masksToBounds = YES;
    [line addSubview:self.markLineView];
}

- (void)scrollMarkLineAndSelectedItem:(CGFloat)off_X {
    
    NSInteger tag = off_X/self.frame.size.width + 1111;
    
    UIButton *getItem = (UIButton *)[self.barScroller viewWithTag:tag];
    self.tmpItem.selected = NO;
    
    getItem.selected = YES;
    self.tmpItem = getItem;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.markLineView.frame = CGRectMake(0, 0, self.markLineWidth > 0 ? self.markLineWidth : (getItem.frame.size.width - 2 * self.itemBetween), self.lineHeight);
        self.markLineView.center = CGPointMake(getItem.center.x, self.lineHeight / 2);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat off_X = 0;
        if (getItem.frame.origin.x + getItem.frame.size.width > self.frame.size.width) {
            if (getItem.frame.origin.x + getItem.frame.size.width / 2 - self.frame.size.width / 2 >= 0 && getItem.frame.origin.x + getItem.frame.size.width / 2 + self.frame.size.width / 2 <= self.barScroller.contentSize.width) {
                off_X = getItem.frame.origin.x + getItem.frame.size.width / 2 - self.frame.size.width / 2;
            }
            else if (getItem.frame.origin.x + getItem.frame.size.width / 2 - self.frame.size.width / 2 >= 0){
                off_X = self.barScroller.contentSize.width - self.frame.size.width;
            }
        }
        self.barScroller.contentOffset = CGPointMake(off_X, 0);
    }];
}

@end
