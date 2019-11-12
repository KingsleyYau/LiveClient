//
//  LSMyCartStoreCell.m
//  livestream
//
//  Created by Randy_Fan on 2019/10/8.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSMyCartStoreCell.h"
#import "LSImageViewLoader.h"

@interface LSMyCartStoreCell ()<UITextFieldDelegate>
@property (nonatomic, strong) LSImageViewLoader *loader;

@property (nonatomic, strong) LSCartGiftItem *giftItem;

@property (nonatomic, assign) int num;
@end

@implementation LSMyCartStoreCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.loader = [LSImageViewLoader loader];
        self.giftItem = [[LSCartGiftItem alloc] init];
        self.num = 0;
    }
    return self;
}

+ (id)getUITableViewCell:(UITableView *)tableView {
    LSMyCartStoreCell *cell = (LSMyCartStoreCell *)[tableView dequeueReusableCellWithIdentifier:[LSMyCartStoreCell cellIdentifier]];
    
    if (nil == cell) {
        NSBundle *bundle = [LiveBundle mainBundle];
        NSArray *nib = [bundle loadNibNamedWithFamily:[LSMyCartStoreCell cellIdentifier] owner:tableView options:nil];
        cell = [nib objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.numTextField.delegate = cell;
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.storeImageView.layer.cornerRadius = 5;
    self.storeImageView.layer.masksToBounds = YES;
    
    self.numTextField.layer.cornerRadius = 3;
    self.numTextField.layer.borderWidth = 1;
    self.numTextField.layer.borderColor = COLOR_WITH_16BAND_RGB(0x666666).CGColor;
    self.numTextField.layer.masksToBounds = YES;
}

- (void)setupContent:(LSCartGiftItem *)model {
    self.giftItem = model;
    self.stroeNameLabel.text = [NSString stringWithFormat:@"%@ - %@",model.giftId, model.giftName];
    self.moneyLabel.text = [NSString stringWithFormat:@"USD %.2f",(model.giftPrice * model.giftNumber)];
    self.numTextField.text = [NSString stringWithFormat:@"%d",model.giftNumber];
    self.num = model.giftNumber;
    [self.loader loadImageWithImageView:self.storeImageView options:0 imageUrl:model.giftImg placeholderImage:nil finishHandler:^(UIImage *image) {

    }];
}

- (void)changeGiftNum:(int)num success:(BOOL)success {
    if (success) {
        self.num = num;
    }
    self.numTextField.text = [NSString stringWithFormat:@"%d",self.num];
    self.moneyLabel.text = [NSString stringWithFormat:@"USD %.2f",(self.giftItem.giftPrice * self.num)];
}

#pragma mark - 点击事件
- (IBAction)lessenStoreNum:(id)sender {
    int num = self.numTextField.text.intValue - 1;
    if (num) {
        if (self.delagate && [self.delagate respondsToSelector:@selector(didSelectChangeGiftNum:item:num:)]) {
            [self.delagate didSelectChangeGiftNum:self item:self.giftItem num:num];
        }
    } else {
        if (self.delagate && [self.delagate respondsToSelector:@selector(didSelectRemoveGift:)]) {
            [self.delagate didSelectRemoveGift:self.giftItem];
        }
    }
}

- (IBAction)addStoreNum:(id)sender {
    int num = self.numTextField.text.intValue + 1;
    if (num) {
        if (self.delagate && [self.delagate respondsToSelector:@selector(didSelectChangeGiftNum:item:num:)]) {
            [self.delagate didSelectChangeGiftNum:self item:self.giftItem num:num];
        }
    }
}

- (IBAction)clickGiftInfo:(id)sender {
    if (self.delagate && [self.delagate respondsToSelector:@selector(didSelectGiftInfo:)]) {
        [self.delagate didSelectGiftInfo:self.giftItem];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGRect rect = [textField caretRectForPosition:textField.selectedTextRange.end];
    if (self.delagate && [self.delagate respondsToSelector:@selector(getConvertRectToVc:rect:)]) {
        [self.delagate getConvertRectToVc:textField rect:rect];
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.num = textField.text.intValue;
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
    if (textField.text.length > 0 && textField.text.intValue != self.num) {
        if ((textField.text.intValue > 99 || textField.text.intValue < 1) ) {
            if (self.delagate && [self.delagate respondsToSelector:@selector(showChangeError)]) {
                [self.delagate showChangeError];
            }
            textField.text = [NSString stringWithFormat:@"%d",self.num];
        } else {
            if (self.delagate && [self.delagate respondsToSelector:@selector(didSelectChangeGiftNum:item:num:)]) {
                [self.delagate didSelectChangeGiftNum:self item:self.giftItem num:textField.text.intValue];
            }
        }
    } else {
        textField.text = [NSString stringWithFormat:@"%d",self.num];
    }
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass(self);
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.loader stop];
    [self.storeImageView sd_cancelCurrentImageLoad];
    self.storeImageView.image = nil;
    self.num = 0;
}

@end
