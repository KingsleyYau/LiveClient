//
//  LSPrePaidPickerView.m
//  livestream
//
//  Created by Calvin on 2020/3/27.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import "LSPrePaidPickerView.h"

@interface LSPrePaidPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@end

@implementation LSPrePaidPickerView

- (instancetype)init {
    self = [super init];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSPrePaidPickerView" owner:self options:0].firstObject;
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    self.selectTimeRow = 0;
}

- (void)reloadData {
    [self.pickerView reloadAllComponents];
    [self.pickerView selectRow:self.selectTimeRow inComponent:0 animated:NO];
}

- (IBAction)doneBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(prepaidPickerViewSelectedRow:)]) {
        [self.delegate prepaidPickerViewSelectedRow:self.selectTimeRow];
    }
}

- (IBAction)cancelBtnDid:(id)sender {
    if ([self.delegate respondsToSelector:@selector(removePrePaidPickerView)]) {
        [self.delegate removePrePaidPickerView];
    }
}

- (IBAction)bgTap:(id)sender {
    if ([self.delegate respondsToSelector:@selector(removePrePaidPickerView)]) {
        [self.delegate removePrePaidPickerView];
    }
}

#pragma mark PickerView Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.items.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
     UILabel * label = [[UILabel alloc]init];
    label.textAlignment = NSTextAlignmentCenter;
    if ([self.items[row] isKindOfClass:[NSString class]]) {
        label.text = self.items[row];
    }
    else {
        label.attributedText = self.items[row];
    }
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
 
        self.selectTimeRow = row;
        
}


@end
