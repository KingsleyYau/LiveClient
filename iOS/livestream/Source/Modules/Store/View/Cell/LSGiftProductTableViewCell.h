//
//  LSGiftProductTableViewCell.h
//  livestream
//
//  Created by test on 2019/10/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageViewLoader.h"
NS_ASSUME_NONNULL_BEGIN
@class LSGiftProductTableViewCell;
@protocol LSGiftProductTableViewCellDelegate <NSObject>
@optional
- (void)lsGiftProductTableViewCellDidSelectChangeGiftNum:(LSGiftProductTableViewCell *)cell num:(int)num;
- (void)lsGiftProductTableViewCellDidSelectRemoveGift:(LSGiftProductTableViewCell *)cell;
- (void)lsGiftProductTableViewCell:(LSGiftProductTableViewCell *)cell DidChangeCount:(UITextField *)textField lastNum:(int)num;
@end

@interface LSGiftProductTableViewCell : UITableViewCell<UITextFieldDelegate>
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;
@property (weak, nonatomic) IBOutlet UIImageView *giftImageView;
@property (weak, nonatomic) IBOutlet UILabel *giftName;
@property (weak, nonatomic) IBOutlet UILabel *giftPrice;
@property (weak, nonatomic) IBOutlet UITextField *giftTextFeild;
@property (nonatomic, weak) id<LSGiftProductTableViewCellDelegate> giftProductDelegate;

+ (NSString *)cellIdentifier;

+ (NSInteger)cellHeight;

+ (id)getUITableViewCell:(UITableView *)tableView;
@end

NS_ASSUME_NONNULL_END
