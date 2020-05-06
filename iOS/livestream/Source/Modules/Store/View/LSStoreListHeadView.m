//
//  LSStoreListHeadView.m
//  livestream
//
//  Created by Calvin on 2019/10/10.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSStoreListHeadView.h"
#import "LSStoreFlowerGiftItemObject.h"
@interface LSStoreListHeadView ()

@end

@implementation LSStoreListHeadView

 - (instancetype)initWithCoder:(NSCoder *)coder {
     self = [super initWithCoder:coder];
     if (self) {
         UIView *containerView = [[LiveBundle mainBundle] loadNibNamed:@"LSStoreListHeadView" owner:self options:nil].firstObject;
         CGRect newFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
         containerView.frame = newFrame;
         [self addSubview:containerView];
         
     }
     return self;
 }

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectRow = 0;
}

- (void)reloadData {
    if (self.selectRow < self.titleArray.count) {
        LSStoreFlowerGiftItemObject * item = self.titleArray[self.selectRow];
        
        if (item.isHasGreeting) {
             self.titleLabel.attributedText = [self getContentStr:item.typeName labelFont: self.titleLabel.font maxWidth:SCREEN_WIDTH -90];
        }else {
            self.titleLabel.text = item.typeName;
        }
        
        [self.tableView reloadData];
        
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectRow inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
}
 
- (IBAction)chooseBtnDid:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(storeListHeadViewDidChooseBtn)]) {
        [self.delegate storeListHeadViewDidChooseBtn];
    }
}

#pragma mark - 列表界面回调 (UITableViewDataSource / UITableViewDelegate)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
       static NSString *cellName = @"cellName";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = COLOR_WITH_16BAND_RGB(0x383838);
    }
    if (indexPath.row < self.titleArray.count) {
        
        if (self.selectRow == indexPath.row) {
            cell.backgroundColor = COLOR_WITH_16BAND_RGB(0xECEEF1);
        }else {
            cell.textLabel.textColor = [LSColor colorWithLight:COLOR_WITH_16BAND_RGB(0x383838) orDark:[UIColor whiteColor]];
            cell.backgroundColor = [LSColor colorWithLight:[UIColor whiteColor] orDark:[UIColor blackColor]];
        }
        
         LSStoreFlowerGiftItemObject * item = self.titleArray[indexPath.row];
        
        if (item.isHasGreeting) {
            cell.textLabel.attributedText = [self getContentStr:item.typeName labelFont:cell.textLabel.font maxWidth:SCREEN_WIDTH - 40];
        }else {
            cell.textLabel.text = item.typeName;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    self.selectRow = indexPath.row;
    [self reloadData];

    if ([self.delegate respondsToSelector:@selector(storeListHeadViewSelectSection:)]) {
        [self.delegate storeListHeadViewSelectSection:self.selectRow];
    }
}

- (CGFloat)getStrW:(NSString *)str labelFont:(UIFont*)font {
     CGFloat strW = [str sizeWithAttributes:@{NSFontAttributeName:font}].width;
    return strW;
}

- (NSMutableAttributedString *)getContentStr:(NSString *)str labelFont:(UIFont*)font maxWidth:(CGFloat)maxwidth{
    NSString * cardStr = @"Free Greeting Card";
    
    NSString * string = [NSString stringWithFormat:@"%@ - %@",str,cardStr];
    
    //长度过长需要截取
    if ([self getStrW:string labelFont:font] > maxwidth) {
        for (int i = 1; i < str.length; i++) {
        string = [NSString stringWithFormat:@"%@... - %@",[str substringToIndex:str.length - i],cardStr];
            if ([self getStrW:string labelFont:font] < maxwidth) {
                break;
            }
        }
    }
    
    NSMutableAttributedString * attStr = [[NSMutableAttributedString alloc]initWithString:string];
    [attStr addAttributes:@{NSForegroundColorAttributeName:COLOR_WITH_16BAND_RGB(0xF2661C)} range:[string rangeOfString:cardStr]];
    
    return attStr;
}

@end
