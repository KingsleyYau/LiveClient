//
//  LSGiftProductTableViewCell.m
//  livestream
//
//  Created by test on 2019/10/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSGiftProductTableViewCell.h"
@interface LSGiftProductTableViewCell()

@property (nonatomic, assign) int num;
@end

@implementation LSGiftProductTableViewCell

+ (NSString *)cellIdentifier {
    return @"LSGiftProductTableViewCell";
}

+ (NSInteger)cellHeight {
    return 80;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSGiftProductTableViewCell *cell = (LSGiftProductTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[LSGiftProductTableViewCell cellIdentifier]];
    if (nil == cell) {
        NSArray *nib = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSGiftProductTableViewCell" owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.imageViewLoader = [LSImageViewLoader loader];
        cell.giftImageView.layer.cornerRadius = 3.0f;
        cell.giftImageView.layer.masksToBounds = YES;
        cell.giftTextFeild.delegate = cell;
        cell.giftTextFeild.keyboardType = UIKeyboardTypeNumberPad;

    }
    return cell;
}

- (IBAction)addAction:(id)sender {
    self.num = self.giftTextFeild.text.intValue;
    int num = self.giftTextFeild.text.intValue + 1;
    self.giftTextFeild.text = [NSString stringWithFormat:@"%d",num];
    if (self.giftProductDelegate && [self.giftProductDelegate respondsToSelector:@selector(lsGiftProductTableViewCellDidSelectChangeGiftNum:num:)]) {
        [self.giftProductDelegate lsGiftProductTableViewCellDidSelectChangeGiftNum:self num:self.num];
    }
}
- (IBAction)minusAction:(id)sender {
    self.num = self.giftTextFeild.text.intValue;
    int num = self.giftTextFeild.text.intValue - 1;
    if (num > 0) {
        self.giftTextFeild.text = [NSString stringWithFormat:@"%d",num];
        if (self.giftProductDelegate && [self.giftProductDelegate respondsToSelector:@selector(lsGiftProductTableViewCellDidSelectChangeGiftNum:num:)]) {
            [self.giftProductDelegate lsGiftProductTableViewCellDidSelectChangeGiftNum:self num:self.num];
        }
    } else {
        if (self.giftProductDelegate && [self.giftProductDelegate respondsToSelector:@selector(lsGiftProductTableViewCellDidSelectRemoveGift:)]) {
            [self.giftProductDelegate lsGiftProductTableViewCellDidSelectRemoveGift:self];
        }
    }
}


- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.num = [textField.text intValue];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    bool bFlag = YES;
    
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int index = 0;
    while (index < string.length) {
        NSString * num = [string substringWithRange:NSMakeRange(index, 1)];
        NSRange numRange = [num rangeOfCharacterFromSet:tmpSet];
        if (numRange.length == 0) {
            bFlag = NO;
            break;
        }
        index++;
    }
    return bFlag;
}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.giftProductDelegate respondsToSelector:@selector(lsGiftProductTableViewCell:DidChangeCount:lastNum:)]) {
        [self.giftProductDelegate lsGiftProductTableViewCell:self DidChangeCount:textField lastNum:self.num];
    }
}


@end
