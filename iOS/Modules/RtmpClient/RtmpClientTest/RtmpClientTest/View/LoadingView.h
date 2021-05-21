//
//  LoadingView.h
//  Cartoon
//
//  Created by Max on 2021/5/7.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoadingView : UIView
+ (instancetype)view;
@property (weak) IBOutlet UILabel *msgLabel;
@end

NS_ASSUME_NONNULL_END
