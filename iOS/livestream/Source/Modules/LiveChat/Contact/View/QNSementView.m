//
//  LCSegmentView.m
//  UIWidget
//
//  Created by test on 2018/11/21.
//  Copyright © 2018年 lance. All rights reserved.
//


#import "QNSementView.h"
#import "QNUnreadCountBtn.h"

#define kSelectedColor       [UIColor colorWithRed:41 / 255.0 green:122 / 255.0 blue:243 / 255.0 alpha:1]
#define kTextSelectedColor  [UIColor colorWithRed:56 / 255.0 green:56 / 255.0 blue:56 / 255.0 alpha:1]
#define kNormalColor        [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1]
#define kLineNormalColor    [UIColor whiteColor]
#define kSpacing         [UIScreen mainScreen].bounds.size.width==320?5: [UIScreen mainScreen].bounds.size.width==375?15:20

@interface QNSementView ()<QNUnreadCountBtnDelegate>

@property (nonatomic, strong) QNUnreadCountBtn *lastClickUnreadButton;

@property (nonatomic, strong) UIColor * textSelectedColor;

@property (nonatomic, strong) UIColor * textNormalColor;

@property (nonatomic, strong) UIColor * lineNormalColor;

@property (nonatomic, strong) UIColor * lineSelectedColor;

@property (nonatomic, strong) UIFont * textFont;
@property (nonatomic, strong) UIFont * selectTextFont;

@end

@implementation QNSementView

- (instancetype)initWithNumberOfTitles:(NSArray *)titles andFrame:(CGRect)frame delegate:(id<QNSementViewDelegate>)delegate isSymmetry:(BOOL)isSymmetry isShowbottomLine:(BOOL)isBottom{
    if (self = [super initWithFrame:frame]) {
        _textSelectedColor = kTextSelectedColor;
        _textNormalColor = kNormalColor;
        
        _lineSelectedColor = kSelectedColor;
        _lineNormalColor = kLineNormalColor;
        
        _textFont = [UIFont systemFontOfSize:17.f];
        _selectTextFont = [UIFont systemFontOfSize:17.f];
        // 设置代理
        self.delegate = delegate;
        NSMutableArray * array = [NSMutableArray array];
        [array addObject:[NSNumber numberWithFloat:0]];
        for (int i = 0; i < titles.count; i++) {
            CGFloat w = [[titles objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + (kSpacing);
            [array addObject:[NSNumber numberWithFloat:ceil(w)]];
        }
        
        CGFloat oldW = 0;
        CGFloat symmetryW =  frame.size.width/titles.count;
        for (int i = 0; i < titles.count; i ++) {
            CGFloat x = [array[i] floatValue] + oldW;
            oldW = x;
            
            QNUnreadCountBtn *button = nil;
            
            
            if (isSymmetry) {
                button = [[QNUnreadCountBtn alloc] initWithFrame:CGRectMake(i*symmetryW, 0, symmetryW, frame.size.height)];;
            }
            else
            {
                button = [[QNUnreadCountBtn alloc] initWithFrame:CGRectMake(x, 0, [array[i+1] floatValue], frame.size.height)];
            }
            
            // 默认选中第一个 设置状态
            if (i == 0) {
                button.unreadNameText.textColor = kTextSelectedColor;
                button.lineView.backgroundColor = kSelectedColor;
                // 保留为上次选择中的button
                _lastClickUnreadButton = button;
            }
            button.backgroundColor = [UIColor clearColor];
            [button updateUnreadCount:@"0"];
            // 设置对应的tag
            button.tag = i + 88;
            button.unreadNameText.text = titles[i];
            button.delegate = self;
            [self addSubview:button];
            
        }
        
        if (isBottom) {
            CGFloat bottom = self.frame.origin.y + self.frame.size.height;
            UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
            bottomView.backgroundColor = [UIColor grayColor];
            [self addSubview:bottomView];
        }
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleArray = [NSArray array];
        
        _textSelectedColor = kTextSelectedColor;
        _textNormalColor = kNormalColor;
        
        _lineSelectedColor = kSelectedColor;
        _lineNormalColor = kLineNormalColor;
        
    }
    return self;
}

- (void)setTextNormalColor:(UIColor *)textNormalColor andSelectedColor:(UIColor *)textSelectedColor {
    _textNormalColor = textNormalColor;
    _textSelectedColor = textSelectedColor;
    //更新按钮的文本颜色
    for (id subview in self.subviews) {
        if ([subview tag] >= 88) {
            QNUnreadCountBtn *button = [self viewWithTag:[subview tag]];
            [button.unreadNameText setTextColor:_textNormalColor];
        }
    }
    _lastClickUnreadButton.unreadNameText.textColor = _textSelectedColor;
}

- (void)setLineNormalColor:(UIColor *)lineNormalColor andelectedColor:(UIColor *)lineSelectedColor {
    _lineNormalColor = lineNormalColor;
    _lineSelectedColor = lineSelectedColor;
    //更新选中按钮的下划线颜色
    _lastClickUnreadButton.lineView.backgroundColor = lineSelectedColor;
}

-(void)setTitleFont:(UIFont *)font
{
    _textFont = font;
    for (id subview in self.subviews) {
        if ([subview tag] >= 88) {
            QNUnreadCountBtn *button = [self viewWithTag:[subview tag]];
            [button.unreadNameText setFont:font];
        }
    }
}

-(void)setTitleSelectFont:(UIFont *)font
{
    _selectTextFont = font;
    //for (id subview in self.subviews) {
    [_lastClickUnreadButton.unreadNameText setFont:_selectTextFont];
    //}
}

- (void)newTitleBtnIsSymmetry:(BOOL)isSymmetry {
    if (_textFont == nil) {
        _textFont = [UIFont systemFontOfSize:17.f];
    }
    if (_selectTextFont == nil) {
        _selectTextFont = [UIFont systemFontOfSize:17.f];
    }
    NSMutableArray * array = [NSMutableArray array];
    [array addObject:[NSNumber numberWithFloat:0]];
    for (int i = 0; i < self.titleArray.count; i++) {
        CGFloat w = [[self.titleArray objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:_textFont}].width + (kSpacing);
        [array addObject:[NSNumber numberWithFloat:ceil(w)]];
    }
      
      CGFloat oldW = 0;
      CGFloat symmetryW =  self.frame.size.width/self.titleArray.count;
      for (int i = 0; i < self.titleArray.count; i ++) {
          CGFloat x = [array[i] floatValue] + oldW;
          oldW = x;
          
          QNUnreadCountBtn *button = nil;
          
          if (isSymmetry) {
              button = [[QNUnreadCountBtn alloc] initWithFrame:CGRectMake(i*symmetryW, 0, symmetryW, self.frame.size.height)];
          }
          else
          {
              button = [[QNUnreadCountBtn alloc] initWithFrame:CGRectMake(x, 0, [array[i+1] floatValue], self.frame.size.height)];;
          }
          
          button.unreadNameText.font = _textFont;
          button.lineView.backgroundColor = self.lineNormalColor;
          button.unreadNameText.textColor = self.textNormalColor;
          button.backgroundColor = [UIColor clearColor];
          [button updateUnreadCount:@"0"];
          // 设置对应的tag
          button.tag = i + 88;
          button.unreadNameText.text = self.titleArray[i];
          button.delegate = self;
          [self addSubview:button];
          
          // 默认选中第一个 设置状态
          if (i == 0) {
              button.unreadNameText.textColor = self.textSelectedColor;
              button.lineView.backgroundColor = self.lineSelectedColor;
              // 保留为上次选择中的button
              _lastClickUnreadButton = button;
              
              button.unreadNameText.font = _selectTextFont;
          }

      }
      
      if (self.isShowbottomLine) {
          CGFloat bottom = self.frame.origin.y + self.frame.size.height;
          UIView * bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, bottom, self.frame.size.width, 1)];
          bottomView.backgroundColor = [UIColor grayColor];
          [self addSubview:bottomView];
      }
}

- (void)selectButtonTag:(NSInteger)tag
{
    QNUnreadCountBtn * button = [self viewWithTag:tag + 88];
    [self unreadCountBtnDidTap:button];
}

+ (CGFloat)getSegmentControlW:(NSArray *)titles
{
    CGFloat w = 0;
    for (int i = 0; i < titles.count; i++) {
        w = ([[titles objectAtIndex:i] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}].width + (kSpacing)) + w;
    }
    
    return w;
}

- (void)unreadCountBtnDidTap:(QNUnreadCountBtn *)btn {
    if (_lastClickUnreadButton != btn) {
        // 设置状态
        btn.unreadNameText.textColor = self.textSelectedColor;
        btn.lineView.backgroundColor = self.lineSelectedColor;
        btn.unreadNameText.font = self.selectTextFont;
        
        _lastClickUnreadButton.unreadNameText.textColor = self.textNormalColor;
        _lastClickUnreadButton.lineView.backgroundColor = self.lineNormalColor;
        _lastClickUnreadButton.unreadNameText.font = self.textFont;
        
        _lastClickUnreadButton = btn;

        // 回调 可用block
        if ([self.delegate respondsToSelector:@selector(segmentControlSelectedTag:)]) {
            [self.delegate segmentControlSelectedTag:btn.tag - 88];
        }
    }
}




- (void)updateBtnUnreadCount:(NSArray * )countArray
{
    for (int i = 0; i < countArray.count; i++) {
        QNUnreadCountBtn *button = [self viewWithTag:i+88];
        [button updateUnreadCount:countArray[i]];
    }
}

- (void)updateUnreadStatus:(NSArray *)showArray
{
    for (int i = 0; i < showArray.count; i++) {
        QNUnreadCountBtn *button = [self viewWithTag:i+88];
        [button updateUnreadStatus:[showArray[i] boolValue]];
    }
}

@end

