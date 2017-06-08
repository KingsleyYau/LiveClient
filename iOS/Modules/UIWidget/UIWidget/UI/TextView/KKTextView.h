//
//  KKTextView.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KKTextView;
@protocol KKTextViewDelegate <NSObject>
@optional
- (void)textViewDoneInput:(KKTextView *)kkTextView;
@end
@interface KKTextView : UITextView {

}
@property (nonatomic, assign) IBOutlet id<KKTextViewDelegate> kkTextViewDelegate;
@property (nonatomic, retain) UILabel *tipsLabel;
@end
