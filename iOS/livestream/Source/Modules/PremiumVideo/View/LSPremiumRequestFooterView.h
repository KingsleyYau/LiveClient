//
//  LSPremiumRequestFooterView.h
//  livestream
//
//  Created by Albert on 2020/7/30.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSPremiumRequestFooterView : UIView<UITextViewDelegate>
{
    CGFloat totalHeight;
}

@property (nonatomic, weak) IBOutlet UILabel *tipLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tipLabelH;
@property (nonatomic, weak) IBOutlet UITextView *clickTextView;
@property (nonatomic, weak) IBOutlet UILabel *clickLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *clickLabelH;

-(void)setTipText:(NSString *)txt;
-(void)setRichText:(NSString *)txt RangeText:(NSString *)rText;
-(CGFloat)getContentHeight;

@end

NS_ASSUME_NONNULL_END
