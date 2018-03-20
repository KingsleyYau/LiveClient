//
//  AddVirtualGiftsCell.h
//  testDemo
//
//  Created by Calvin on 17/9/25.
//  Copyright © 2017年 dating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddVirtualGiftsCellDelegate <NSObject>

- (void)addVirtualGiftsCellSwitchOn:(BOOL)isOn;

- (void)addVirtualGiftsCellSelectGiftId:(NSString *)giftId andNum:(NSInteger)num;
@end

@interface AddVirtualGiftsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *switchBGView;
@property (weak, nonatomic) IBOutlet UIButton *numBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) id<AddVirtualGiftsCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIScrollView *numView;
@property (nonatomic, assign) NSInteger num;//礼物数量
@property (nonatomic, copy) NSString * giftId;
 

+ (NSString *)cellIdentifier;
+ (NSInteger)cellHeight;
+ (id)getUITableViewCell:(UITableView*)tableView isShowVG:(BOOL)isShowVG;

- (void)getVirtualGiftList:(NSArray *)array;
 
@end
