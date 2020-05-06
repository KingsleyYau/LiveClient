//
//  PresentSendView.h
//  UIWidget
//
//  Created by test on 2017/6/12.
//  Copyright © 2017年 lance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectBlock)(NSString *text);

typedef enum : NSUInteger {
    PullMenuStatusShow,
    PullMenuStatusHide
} PullMenuStatus;
@interface PresentSendView : UIView

@property (nonatomic, copy) SelectBlock valueChangeBlock;

@property (weak, nonatomic) IBOutlet LSCheckButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *selectNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (nonatomic, strong) UIView *containerView;


@property (nonatomic, strong) NSArray* data;
@property (nonatomic, assign) PullMenuStatus status;
/** tableview */
@property (nonatomic, strong) LSTableView* tableView;


//-(void)pullMenuShow;
//-(void)pullMenuDismiss;

@end
