//
//  InformationSelectView.m
//  dating
//
//  Created by test on 2018/9/18.
//  Copyright © 2018年 qpidnetwork. All rights reserved.
//

#import "LSInformationSelectView.h"
#define AnimationTime 0.3

@interface LSInformationSelectView()<UIPickerViewDataSource,UIPickerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIPickerView *informationPickerView;
@property (weak, nonatomic) IBOutlet UIView *chooseActionView;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end



@implementation LSInformationSelectView

+ (instancetype)initInformationSelectViewXib {
    NSArray *nibs = [[LiveBundle mainBundle] loadNibNamedWithFamily:@"LSInformationSelectView" owner:nil options:nil];
    LSInformationSelectView* view = [nibs objectAtIndex:0];
    view.userInteractionEnabled = YES;
    view.frame = [UIScreen mainScreen].bounds;
    view.informationPickerView.delegate = view;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(hideAnimation)];
    [view addGestureRecognizer:tap];
    return view;
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)reloadCurrentIndex {
    [self.informationPickerView selectRow:[self.dataArray indexOfObject:self.currentDetail] inComponent:0 animated:NO];
}

- (IBAction)cancelAction:(id)sender {
    [self hideAnimation];
}

- (IBAction)saveAction:(id)sender {
    NSInteger row = [self.informationPickerView selectedRowInComponent:0];
    if ([self.informationDelegate respondsToSelector:@selector(lsInformationSelectView:didSaveInformationForIndex:)]) {
        [self.informationDelegate lsInformationSelectView:self didSaveInformationForIndex:row];
    }
    [self hideAnimation];
}



 - (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // 主tableview

    return self.dataArray.count;
}


- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    return self.dataArray[row];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
}



//显示界面
- (void)showAnimation {
    self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    [UIView animateWithDuration:AnimationTime animations:^{
        self.informationPickerView.alpha = 1;
        self.chooseActionView.alpha = 1;
        self.bgView.alpha = 0.5;
    }];
}

//隐藏界面
- (void)hideAnimation {
    [UIView animateWithDuration:AnimationTime animations:^{
        self.bgView.alpha = 0;
        self.informationPickerView.alpha = 0;
        self.chooseActionView.alpha = 0;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
