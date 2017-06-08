//
//  KKTextField.h
//  dating
//
//  Created by Max on 16/2/16.
//  Copyright © 2016年 qpidnetwork. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KKTextField;
@protocol KKTextFieldDelegate <NSObject>
@optional
- (void)textFieldDoneInput:(KKTextField *)kkTextField;
//- (void)textFieldDidChange:(KKTextField *)kkTextField;
@end

@interface KKTextField : UITextField {
    
}
@property (nonatomic, assign) id<KKTextFieldDelegate> kkTextFieldDelegate;
@property (nonatomic, retain) UILabel *tipsLabel;
@end
