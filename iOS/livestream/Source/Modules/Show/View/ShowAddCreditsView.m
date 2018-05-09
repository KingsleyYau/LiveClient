//
//  ShowAddCreditsView.m
//  livestream
//
//  Created by Calvin on 2018/4/18.
//  Copyright © 2018年 net.qdating. All rights reserved.
//

#import "ShowAddCreditsView.h"
#import "LSImageViewLoader.h"
#import "LSBuyProgramRequest.h"
#import "DialogTip.h"
#import "LiveModule.h"
@interface ShowAddCreditsView ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet LSUIImageViewTopFit *headImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *creditsLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIView *button;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, strong) LSImageViewLoader * imageViewLoader;
@property (nonatomic, strong) LSSessionRequestManager *sessionManager;
@property (nonatomic, strong) LSProgramItemObject * obj;
@end

@implementation ShowAddCreditsView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.bgView.layer.cornerRadius = 8;
    self.bgView.layer.masksToBounds = YES;
    
    self.button.layer.cornerRadius = 4;
    self.button.layer.masksToBounds = YES;
    
    self.headImage.layer.cornerRadius = self.headImage.frame.size.height/2;
    self.headImage.layer.masksToBounds = YES;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self =  [[LiveBundle mainBundle] loadNibNamedWithFamily:NSStringFromClass([self class]) owner:self options:0].firstObject;
        
        self.frame = frame;
        
        self.sessionManager = [LSSessionRequestManager manager];
    }
    return self;
}

- (void)updateUI:(LSProgramItemObject *)item
{
    self.obj = item;
    [self.imageViewLoader stop];
    if (!self.imageViewLoader) {
        self.imageViewLoader = [LSImageViewLoader loader];
    }
    [self.imageViewLoader refreshCachedImage:self.headImage options:SDWebImageRefreshCached imageUrl:item.anchorAvatar placeholderImage:[UIImage imageNamed:@"Default_Img_Lady_Circyle"]];
    
    self.titleLabel.text = item.showTitle;
    
    self.creditsLabel.text = [NSString stringWithFormat:@"%0.1f credits",item.price];
}

- (IBAction)bgTap:(UITapGestureRecognizer *)sender {
    
    [self removeFromSuperview];
}

- (IBAction)closeBtnDid:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)GetTicketBtn:(UIButton *)sender {
    [[LiveModule module].analyticsManager reportActionEvent:ShowCalendarConfirmGetTicket eventCategory:EventCategoryShowCalendar];
    LSBuyProgramRequest * request = [[LSBuyProgramRequest alloc]init];
    request.liveShowId = self.obj.showLiveId;
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString * _Nonnull errmsg, double leftCredit){
         dispatch_async(dispatch_get_main_queue(), ^{
             if (success) {
                 [self removeFromSuperview];
                 [[DialogTip dialogTip]showDialogTip:[LiveModule module].moduleVC.view tipText:NSLocalizedStringFromSelf(@"ADD_CREDITS_SUCCESS")];
                 
                 self.obj.ticketStatus = PROGRAMTICKETSTATUS_BUYED;
                 self.obj.isHasFollow = YES;
                 if ([self.delegate respondsToSelector:@selector(buyProgramSuccess:)]) {
                     [self.delegate buyProgramSuccess:self.obj];
                 }
             }
             else
             {
                 if (errnum == HTTP_LCC_ERR_NO_CREDIT) {
                     UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedStringFromSelf(@"ADD_CREDITS_MSG") delegate:self cancelButtonTitle:NSLocalizedStringFromSelf(@"Cancel") otherButtonTitles:NSLocalizedStringFromSelf(@"Add Credit"), nil];
                     [alertView show];
                 }
                 else
                 {
                     [[DialogTip dialogTip]showDialogTip:[LiveModule module].moduleVC.view.window tipText:errmsg];
                 }
             }
        });
    };
    [self.sessionManager sendRequest:request];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        if ([self.delegate respondsToSelector:@selector(pushAddCreditVc)]) {
            [self.delegate pushAddCreditVc];
        }
    }
}
@end
