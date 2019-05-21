//
//  LSSayHiCardDetailsViewController.m
//  livestream
//
//  Created by Calvin on 2019/4/24.
//  Copyright © 2019 net.qdating. All rights reserved.
//

#import "LSSayHiCardDetailsViewController.h"
#import "LSLoginManager.h"
#import "LSImageViewLoader.h"
@interface LSSayHiCardDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *fromLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentH;

@end

@implementation LSSayHiCardDetailsViewController
- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[LSImageViewLoader loader] loadImageWithImageView:self.bgImageView options:0 imageUrl:self.photoUrl placeholderImage:nil finishHandler:^(UIImage *image) {
        if (!image) {
            NSLog(@"LSSayHiCardDetailsViewController::图片加载失败");
        }
    }];
}

- (void)initCustomParam {
    [super initCustomParam];
    self.isShowNavBar = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setLineSpace:15.0f withText:self.contentStr inLabel:self.contentView];
    
    self.toLabel.text = [NSString stringWithFormat:@"Dear %@",self.ladyName];
    
    self.fromLabel.text = [LSLoginManager manager].loginItem.nickName;
    
    self.contentView.hidden = NO;
    
    self.fromLabel.hidden = NO;
    
    self.toLabel.hidden = NO;
    
    self.bgImageView.hidden = NO;
}

- (IBAction)backBtnDid:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setLineSpace:(CGFloat)lineSpace withText:(NSString *)text inLabel:(UITextView *)textView{
    if (!text || !textView) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;  //设置行间距
    paragraphStyle.alignment = textView.textAlignment;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName value:textView.font range:NSMakeRange(0, [text length])];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];

    textView.attributedText = attributedString;
    
    [self.contentView setContentOffset:CGPointZero animated:NO];
    
    CGSize size = [attributedString boundingRectWithSize:CGSizeMake(self.contentView.tx_width, self.fromLabel.tx_y - self.toLabel.tx_bottom - 40) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil].size;
    
    self.contentH.constant = ceil(size.height) + 20;
}

@end
