//
//  LSPrePaidPickerView.h
//  livestream
//
//  Created by Calvin on 2020/3/27.
//  Copyright © 2020 net.qdating. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LSPrePaidPickerViewDelegate <NSObject>

- (void)removePrePaidPickerView;

- (void)prepaidPickerViewSelectedRow:(NSInteger)row;
@end

@interface LSPrePaidPickerView : UIView

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSArray * items;
@property (nonatomic, assign) NSInteger selectTimeRow;
@property (weak, nonatomic) id<LSPrePaidPickerViewDelegate> delegate;

- (void)reloadData;
@end

 
