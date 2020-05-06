//
//  ManProfileViewController.m
//  dating
//
//  Created by test on 2017/4/26.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "LSManProfileViewController.h"
#import "LSDomainSessionRequestManager.h"
#import "LSGetMyProfileRequest.h"
#import "LSUpdateProfileRequest.h"
#import <AVFoundation/AVFoundation.h>
#import "LSManDetailTableViewCell.h"
#import "LSTagListCollectionView.h"
#import "LSManInterestItem.h"
#import "DialogIconTips.h"
#import "LSEditInterestViewController.h"
#import "LSInformationSelectView.h"
#import "LSMotifyAboutYouViewController.h"
#import "LSLoginManager.h"
#import "DialogIconTips.h"
#import "LSImageViewLoader.h"
#import "DialogTip.h"
#import "LSProfilePhotoViewController.h"
#import "LSProfilePhotoActionViewController.h"
#import "LSRichAttrLabel.h"
#import "LSChatTextAttachment.h"

#define Minimum 100
#define Maximum 2000
#define ShowMax 200

typedef enum : NSUInteger {
    AlertTypeFail
} AlertType;

typedef enum {
    RowTypeManID,
    RowTypeHeight,
    RowTypeWeight,
    RowTypeSmoke,
    RowTypeEducation,
    RowTypeProfession,
    RowTypeLanguage,
    RowTypeChildren,
    RowTypeIncome,
    RowTypeZodiac,
} RowType;

@interface LSManProfileViewController () <UITextViewDelegate, NSXMLParserDelegate, LSMotifyAboutYouViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, LSManDetailTableViewCellDelegate, LSTagListCollectionViewDelegate, LSAllTagListCollectionViewDelegate, LSEditInterestViewControllerDelegate, LSInformationSelectViewDelegate,TTTAttributedLabelDelegate> {
    CGRect _orgFrame;
    CGRect _newFrame;
}

@property (nonatomic, strong) NSArray *tableViewArray;

/** 任务管理 */
@property (nonatomic, strong) LSDomainSessionRequestManager *sessionManager;

/** 个人详情模型 */
@property (nonatomic, strong) LSPersonalProfileItemObject *personalItem;

/** 国家列表 */
@property (nonatomic, strong) NSMutableArray *countryList;
/** 国家名字 */
@property (nonatomic, strong) NSString *countryName;
/** 标签 */
@property (nonatomic, strong) NSString *elementTag;

/** 保存个人描述内容 */
@property (nonatomic, strong) NSString *personalDescription;

/** 个人资料头像图片 */
@property (weak, nonatomic) IBOutlet UIImageView *profilePhoto;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIView *interestsView;
@property (weak, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIView *informationView;

#pragma mark - interests
@property (weak, nonatomic) IBOutlet UIButton *interestEditBtn;
/** 兴趣列表 */
@property (nonatomic, strong) NSMutableArray *interestList;
/** 兴趣标题列表 */
@property (nonatomic, strong) NSMutableArray *selectInterestList;
@property (nonatomic, strong) LSManInterestItem *interestItem;
/** 选择的兴趣列表 */
//@property (nonatomic, copy) NSArray* selectInterests;
@property (weak, nonatomic) IBOutlet LSTagListCollectionView *interestContentView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *interestContentHeight;
@property (weak, nonatomic) IBOutlet UILabel *interestTips;

#pragma mark - aboutYouView
@property (weak, nonatomic) IBOutlet UIScrollView *backgroundScrollView;
@property (weak, nonatomic) IBOutlet UIButton *aboutYouEditBtn;
/** aboutYou */
@property (weak, nonatomic) IBOutlet UIView *aboutYouLineView;
@property (weak, nonatomic) IBOutlet LSRichAttrLabel *personalCont;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *personalContHeight;
#pragma mark - information
/** information数组 */
@property (nonatomic, copy) NSArray *informationDetail;
@property (weak, nonatomic) IBOutlet LSTableView *tableView;
/** maminformation数组 */
@property (nonatomic, copy) NSArray *manInformationDetail;
@property (weak, nonatomic) IBOutlet UILabel *personName;

@property (weak, nonatomic) IBOutlet UIView *informationLineView;
@property (weak, nonatomic) IBOutlet UILabel *ageAndLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutYouPlaceholder;

/** 显示更多 */
@property (nonatomic, assign) BOOL showMore;

/** informaiton */
@property (weak, nonatomic) IBOutlet UILabel *resumeStatusLabel;

/** 是否更新 */
@property (nonatomic, assign) BOOL updatePerson;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backTopDistance;
/** 下载器 */
@property (nonatomic, strong) LSImageViewLoader *imageViewLoader;


@end

@implementation LSManProfileViewController
- (void)initCustomParam {
    [super initCustomParam];

    self.backTitle = @"";
    self.isShowNavBar = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    if (@available(iOS 11, *)) {
        self.backgroundScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    _orgFrame = CGRectZero;
    _newFrame = CGRectZero;

    self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.height / 2;
    self.profilePhoto.layer.masksToBounds = YES;
    self.profilePhoto.layer.borderWidth = 5.0f;
    self.profilePhoto.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.profilePhoto.userInteractionEnabled = YES;
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTapAction:)];
    [self.profilePhoto addGestureRecognizer:photoTap];


    self.interestContentView.tagDelegate = self;
    self.aboutYouEditBtn.layer.cornerRadius = self.aboutYouEditBtn.bounds.size.height * 0.5;
    self.aboutYouEditBtn.layer.masksToBounds = YES;
    self.updatePerson = NO;

    self.sessionManager = [LSDomainSessionRequestManager manager];
    [self setupArray];
    [self setUpPlist];
    
    [self setupAboutYou];
//    if (IS_IPHONE_X) {
//        self.backTopDistance.constant = 45;
//    }
}

- (void)dealloc {
}

- (void)setupArray {
    self.informationDetail = [NSArray array];

    self.manInformationDetail = [NSArray array];

    self.selectInterestList = [NSMutableArray array];

    self.interestList = [NSMutableArray array];

    self.countryList = [NSMutableArray array];

    self.tableViewArray = [NSArray array];
}

- (void)setupScrollView {
    CGFloat topH = 20;
    if (IS_IPHONE_X) {
        topH = 44;
    }
    [self.backgroundScrollView setContentInset:UIEdgeInsetsMake(-topH, 0, 0, 0)];
}

- (void)viewWillAppear:(BOOL)animated {

    if (!self.viewDidAppearEver) {
        [self setupXMLParser];
        // 获取本地数据
        LSPersonalProfileItemObject *item = [self getUserData];
        // 优先按时本地的数据
        if (item) {
            self.personalItem = item;
            [self setupSelectInterest];
            [self getPersonalMsg];
            self.personName.text = [NSString stringWithFormat:@"%@ %@", self.personalItem.firstname, self.personalItem.lastname];
            self.ageAndLocationLabel.text = [NSString stringWithFormat:@"%d • %@", self.personalItem.age, self.countryList[self.personalItem.country]];
            // 个人描述审核状态
            self.aboutYouEditBtn.hidden = ![self.personalItem canUpdateResume];
            self.resumeStatusLabel.hidden = [self.personalItem canUpdateResume];
            [self reloadData:YES];
        }

    }
    [self getPersonalProfile];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setUpPlist {
    NSString *manProfilePlistPath = [[LiveBundle mainBundle] pathForResource:@"LSManProfile" ofType:@"plist"];
    NSArray *manProfileArray = [[NSArray alloc] initWithContentsOfFile:manProfilePlistPath];
    self.informationDetail = manProfileArray[0];
    self.manInformationDetail = manProfileArray[1];

    NSString *manInterestPlistPath = [[LiveBundle mainBundle] pathForResource:@"LSManInterestTag" ofType:@"plist"];
    NSArray *manInterestArray = [[NSArray alloc] initWithContentsOfFile:manInterestPlistPath];
    NSMutableArray *tempArray = [NSMutableArray array];
    LSManInterestItem *interestItem = nil;
    for (NSDictionary *dict in manInterestArray) {
        interestItem = [[LSManInterestItem alloc] initWithDict:dict];
        [tempArray addObject:interestItem];
        self.interestItem = interestItem;
    }
    self.interestList = tempArray;
}

- (void)setUpProfilePhoto {

    self.imageViewLoader = [LSImageViewLoader loader];
    [self.imageViewLoader loadImageFromCache:self.profilePhoto
                                     options:SDWebImageRefreshCached
                                    imageUrl:self.personalItem.photoUrl
                            placeholderImage:[UIImage imageNamed:@"Default_Img_Man_Circyle"]
                               finishHandler:^(UIImage *image){
                               }];

    // 判断用户头像状态, 是否显示按钮
    self.editBtn.hidden = ![self.personalItem canUpdatePhoto];
    self.profilePhoto.userInteractionEnabled = ![self.personalItem noPhotoStatus];
}

- (void)setupSelectInterest {
    NSMutableArray *tempArray = [NSMutableArray array];

    for (NSString *num in self.personalItem.interests) {

        if ([num isEqualToString:@""] || [num isEqualToString:@"null"]) {
            self.interestContentHeight.constant = 100;
            [self.interestsView layoutIfNeeded];
            self.interestTips.hidden = NO;
        } else {
            int i = [num intValue];
            self.interestItem = self.interestList[i - 1];

            [tempArray addObject:self.interestItem];
        }
    }
    if (tempArray.count > 0) {
        self.interestTips.hidden = YES;
    } else {
        self.interestTips.hidden = NO;
    }

    self.selectInterestList = tempArray;
    self.interestContentView.selectTags = self.selectInterestList;
    [self.interestContentView.collectionView reloadData];
}


- (void)setupAboutYou {
    self.personalCont.font = [UIFont systemFontOfSize:13];
    self.personalCont.textColor = [UIColor colorWithRed:56 / 255.0 green:56 / 255.0 blue:56 / 255.0 alpha:1];
    self.personalCont.delegate = self;
    self.personalCont.linkAttributes = @{
        NSUnderlineStyleAttributeName : @(NSUnderlineStyleNone),
        NSForegroundColorAttributeName : [UIColor colorWithRed:0 green:102 / 255.0 blue:255.0 alpha:1],
    };
}
#pragma mark - 界面逻辑
- (void)setupContainView {
    [super setupContainView];

    [self setupNavigationBar];

    [self setupTableView];

    //    [self setupScrollView];

    self.backgroundScrollView.bounces = NO;

    self.interestsView.layer.cornerRadius = 4.0f;
    self.interestsView.layer.masksToBounds = YES;
    self.aboutView.layer.cornerRadius = 4.0f;
    self.aboutView.layer.masksToBounds = YES;
    self.informationView.layer.cornerRadius = 4.0f;
    self.informationView.layer.masksToBounds = YES;
}

- (void)setupNavigationBar {
    [super setupNavigationBar];
//    self.title = NSLocalizedString(@"My Profile", nil);
}

//设置xml解析
- (void)setupXMLParser {
    NSString *path = [[LiveBundle mainBundle] pathForResource:@"LSCountry_without_code" ofType:@"xml"];
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:path];
    NSData *data = [file readDataToEndOfFile];

    NSXMLParser *xmlRead = [[NSXMLParser alloc] initWithData:data];
    [xmlRead setDelegate:self];

    [xmlRead parse];
    [file closeFile];
}

- (void)setupTableView {
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    headerView.backgroundColor = [UIColor whiteColor];
    [self.tableView setTableHeaderView:headerView];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView setTableFooterView:footerView];
}

#pragma mark - 数据逻辑
- (void)reloadData:(BOOL)isReloadView {
    // 数据填充
    // 主tableView
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *dictionary = nil;
    CGSize viewSize;
    NSValue *rowSize;
    viewSize = CGSizeMake(_tableView.frame.size.width, [LSManDetailTableViewCell cellHeight]);
    rowSize = [NSValue valueWithCGSize:viewSize];

    // 个人资料
    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeManID] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeHeight] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeWeight] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeSmoke] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeEducation] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeProfession] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeLanguage] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeChildren] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeIncome] forKey:ROW_TYPE];
    [array addObject:dictionary];

    dictionary = [NSMutableDictionary dictionary];
    [dictionary setValue:rowSize forKey:ROW_SIZE];
    [dictionary setValue:[NSNumber numberWithInteger:RowTypeZodiac] forKey:ROW_TYPE];
    [array addObject:dictionary];

    self.tableViewArray = array;
    if (isReloadView) {
        [self.tableView reloadData];
    }
}

#pragma mark - XML
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName

       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qName

         attributes:(NSDictionary *)attributeDict {
    self.elementTag = elementName;
    if ([elementName isEqualToString:@"resources"]) {

    } else if ([elementName isEqualToString:@"country_without_code"]) {
        self.countryList = [[NSMutableArray alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (self.countryName == nil) {
        self.countryName = @"";
    }

    if ([self.elementTag isEqualToString:@"item"]) {
        self.countryName = string;
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"item"]) {
        [self.countryList addObject:self.countryName];
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
}

#pragma mark - 相册逻辑

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 接口
- (BOOL)getPersonalProfile {
    LSGetMyProfileRequest *request = [[LSGetMyProfileRequest alloc] init];
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, LSPersonalProfileItemObject *_Nullable userInfoItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideAndResetLoading];
            if (success) {
                if (self.updatePerson) {
                    [[DialogIconTips dialogIconTips] showDialogIconTips:self.view tipText:@"Done" tipIcon:nil];
                }

                NSLog(@"ManProfileViewController::getPersonalProfile( 获取男士详情成功 )");
                self.personalItem = userInfoItem;

                [self setUpProfilePhoto];
                // 个人描述审核状态
                self.aboutYouEditBtn.hidden = ![self.personalItem canUpdateResume];
                self.resumeStatusLabel.hidden = [self.personalItem canUpdateResume];

                [self getPersonalMsg];

                [self setupSelectInterest];

                self.personName.text = [NSString stringWithFormat:@"%@ %@", self.personalItem.firstname, self.personalItem.lastname];
                self.ageAndLocationLabel.text = [NSString stringWithFormat:@"%d • %@", self.personalItem.age, self.countryList[self.personalItem.country]];
                // 更新用户本地的个人信息数据
                [self saveUserData:userInfoItem];
            } else {
                self.interestTips.hidden = NO;
                if ([errmsg isEqualToString:NSLocalizedStringFromErrorCode(@"LOCAL_ERROR_CODE_TIMEOUT")]) {
                    self.personName.text = @"Micheal";
                    self.ageAndLocationLabel.text = @"28 • US";
                }
                // 获取本地数据
                LSPersonalProfileItemObject *item = [self getUserData];
                // 如果本地有数据则失败显示本地的数据
                if (item) {
                    self.personalItem = item;
                    [self setupSelectInterest];
                    [self getPersonalMsg];
                    self.personName.text = [NSString stringWithFormat:@"%@ %@", self.personalItem.firstname, self.personalItem.lastname];
                    self.ageAndLocationLabel.text = [NSString stringWithFormat:@"%d • %@", self.personalItem.age, self.countryList[self.personalItem.country]];
                }
            }
            [self reloadData:YES];
        });
    };
    return [self.sessionManager sendRequest:request];
}

- (void)getTextViewHeight:(NSString * _Nullable)text {
    

    CGSize labelSize = [self.personalCont sizeThatFits:CGSizeMake(self.personalCont.frame.size.width - 20, MAXFLOAT)];
    CGFloat height = ceil(labelSize.height) + 1;
    
    if (height <= 1) {
        height = 50;
    }

    self.personalContHeight.constant = height ;
    [self.personalCont layoutIfNeeded];

}

- (void)getPersonalMsg{

    NSString *personalMsg = [self.personalItem canUpdateResume]?self.personalItem.resume:self.personalItem.resume_content;
    NSString *cont = [personalMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (cont.length == 0) {
        self.aboutYouPlaceholder.hidden = NO;
    }else {
        self.aboutYouPlaceholder.hidden = YES;
    }
        UIColor *dyColor = [LSColor colorWithLight:[UIColor blackColor] orDark:[UIColor whiteColor]];
    if (cont.length > ShowMax) {
        NSString *detail = @"Show more";
        NSInteger subStringIndex = ShowMax - detail.length ;
        NSString *personalMsg = [NSString stringWithFormat:@"%@...\n%@", [cont substringToIndex:subStringIndex],detail];
        NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:personalMsg attributes:@{NSForegroundColorAttributeName : dyColor}];

        
        // 设置超链接内容
        LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
        attachment.text = @"Show more";
        attachment.url = [NSURL URLWithString:@"MORE"];
        attachment.bounds = CGRectMake(0, 0, [UIFont systemFontOfSize:14].lineHeight, [UIFont systemFontOfSize:14].lineHeight);
        NSRange tapRange = [personalMsg rangeOfString:@"Show more"];
        [atts addAttributes:@{
                                     NSFontAttributeName : [UIFont systemFontOfSize:13],
                                     NSAttachmentAttributeName : attachment,
                                     } range:tapRange];
        
        self.personalCont.attributedText = atts;
        [atts enumerateAttributesInRange:NSMakeRange(0, atts.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
            if( attachment && attachment.url != nil ) {
                [self.personalCont addLinkToURL:attachment.url withRange:range];
            }
        }];

        [self getTextViewHeight:self.personalCont.attributedText.string];
    }else {
        self.personalCont.text = cont;
        [self getTextViewHeight:cont];
    }
 
    
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if( [[url absoluteString] isEqualToString:@"MORE"] ) {
        label.text = [self.personalItem canUpdateResume]?self.personalItem.resume:self.personalItem.resume_content;
        NSString *content = [label.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *detail = @"\nShow less";
        NSString *personalMsg = [content stringByAppendingString:detail];
        UIColor *dyColor = [LSColor colorWithLight:[UIColor blackColor] orDark:[UIColor whiteColor]];
        NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:personalMsg attributes:@{NSForegroundColorAttributeName : dyColor}];
        // 设置超链接内容
        LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
        attachment.text = detail;
        attachment.url = [NSURL URLWithString:@"LESS"];
        attachment.bounds = CGRectMake(0, 0, [UIFont systemFontOfSize:14].lineHeight, [UIFont systemFontOfSize:14].lineHeight);
        NSRange tapRange = [personalMsg rangeOfString:detail];
        [atts addAttributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSAttachmentAttributeName : attachment,
        } range:tapRange];
        
        label.attributedText = atts;
        [atts enumerateAttributesInRange:NSMakeRange(0, atts.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
            if( attachment && attachment.url != nil ) {
                [self.personalCont addLinkToURL:attachment.url withRange:range];
            }
        }];

        [self getTextViewHeight:self.personalCont.attributedText.string];
    }else if ([[url absoluteString] isEqualToString:@"LESS"]) {
        NSString *detail = @"Show more";
        NSInteger subStringIndex = ShowMax - detail.length ;
        NSString *personalMsg = [NSString stringWithFormat:@"%@...\n%@", [label.text substringToIndex:subStringIndex],detail];
        NSMutableAttributedString *atts = [[NSMutableAttributedString alloc] initWithString:personalMsg];
        
        
        // 设置超链接内容
        LSChatTextAttachment *attachment = [[LSChatTextAttachment alloc] init];
        attachment.text = @"Show more";
        attachment.url = [NSURL URLWithString:@"MORE"];
        attachment.bounds = CGRectMake(0, 0, [UIFont systemFontOfSize:14].lineHeight, [UIFont systemFontOfSize:14].lineHeight);
        NSRange tapRange = [personalMsg rangeOfString:@"Show more"];
        [atts addAttributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize:14],
            NSAttachmentAttributeName : attachment,
        } range:tapRange];
                label.attributedText = atts;
        [atts enumerateAttributesInRange:NSMakeRange(0, atts.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
            LSChatTextAttachment *attachment = attrs[NSAttachmentAttributeName];
            if( attachment && attachment.url != nil ) {
                [self.personalCont addLinkToURL:attachment.url withRange:range];
            }
        }];

        [self getTextViewHeight:self.personalCont.attributedText.string];
    }
}

#pragma mark - 弹框提示处理
- (NSAttributedString *)parseMessage:(NSString *)text font:(UIFont *)font color:(UIColor *)textColor {
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:text];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];

    paragraphStyle.lineSpacing = 4;
    [attributeString addAttributes:@{
        NSFontAttributeName : font,
        NSForegroundColorAttributeName : textColor,
        NSParagraphStyleAttributeName : paragraphStyle
    }
                             range:NSMakeRange(0, attributeString.length)];
    return attributeString;
}

#pragma mark -  按钮点击事件

- (IBAction)aboutYouBtnClick:(id)sender {
    LSMotifyAboutYouViewController *vc = [[LSMotifyAboutYouViewController alloc] initWithNibName:nil bundle:nil];
    vc.aboutYouContent = [self.personalItem canUpdateResume] ? self.personalItem.resume : self.personalItem.resume_content;
    vc.motifyDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)interestBtnClick:(id)sender {
    LSEditInterestViewController *vc = [[LSEditInterestViewController alloc] initWithNibName:nil bundle:nil];
    vc.allTagList = self.interestList;
    vc.selectInterestList = self.selectInterestList;
    vc.personalItem = self.personalItem;
    vc.editInterestDelegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)lsEditInterestViewController:(LSEditInterestViewController *)vc didSaveInterest:(NSMutableArray *)selectInteset {
    self.interestContentView.selectTags = self.selectInterestList;
    //    [self.interestContentView.collectionView reloadData];
    [self setupSelectInterest];
}

#pragma mark - talbleViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = 0;
    if ([tableView isEqual:self.tableView]) {
        // 主tableview
        number = self.tableViewArray.count;
    }
    return number;
}

#pragma mark - tableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *result = [[UITableViewCell alloc] init];

    if ([tableView isEqual:self.tableView]) {
        // 主tableview
        NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];

        // 大小
        CGSize viewSize;
        NSValue *value = [dictionarry valueForKey:ROW_SIZE];
        [value getValue:&viewSize];
        // 类型
        RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];

        LSManDetailTableViewCell *cell = [LSManDetailTableViewCell getUITableViewCell:tableView];
        result = cell;
        cell.detailMsg.text = self.informationDetail[type];
        NSArray *manArray = self.manInformationDetail[type];
        cell.manProfileEditMsg = manArray;
        cell.manDetailDelegate = self;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        switch (type) {
            case RowTypeManID: {
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.manDetail.text = self.personalItem.manId != nil ? self.personalItem.manId : @"";
            } break;
            case RowTypeHeight: {
                int itemIndex = self.personalItem.height > 0 ? self.personalItem.height : 0;
                cell.manDetail.text = manArray[itemIndex];
            } break;
            case RowTypeWeight: {
                int itemIndex = self.personalItem.weight > 0 ? self.personalItem.weight : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }

            } break;
            case RowTypeSmoke: {
                int itemIndex = self.personalItem.smoke > 0 ? self.personalItem.smoke : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }
            } break;
            case RowTypeEducation: {
                int itemIndex = self.personalItem.education > 0 ? self.personalItem.education : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }
            } break;
            case RowTypeProfession: {
                int itemIndex = self.personalItem.profession > 0 ? self.personalItem.profession : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }

            } break;

            case RowTypeLanguage: {
                int itemIndex = self.personalItem.language > 0 ? self.personalItem.language : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }
            } break;
            case RowTypeChildren: {
                int itemIndex = self.personalItem.children > 0 ? self.personalItem.children : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }
            } break;
            case RowTypeIncome: {
                int itemIndex = self.personalItem.income > 0 ? self.personalItem.income : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }
            } break;
            case RowTypeZodiac: {
                int itemIndex = self.personalItem.zodiac > 0 ? self.personalItem.zodiac : 0;
                if (itemIndex < manArray.count) {
                    cell.manDetail.text = manArray[itemIndex];
                } else {
                    cell.manDetail.text = manArray[manArray.count - 1];
                }

            } break;

            default:
                break;
        }
    }

    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) return;
    // 主tableview
    NSDictionary *dictionarry = [self.tableViewArray objectAtIndex:indexPath.row];
    // 类型
    RowType type = (RowType)[[dictionarry valueForKey:ROW_TYPE] intValue];
    NSArray *manArray = self.manInformationDetail[type];
    LSInformationSelectView *informationView = [LSInformationSelectView initInformationSelectViewXib];
    informationView.tag = type;
    informationView.informationDelegate = self;
    informationView.dataArray = manArray;
    LSManDetailTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    informationView.currentDetail = cell.manDetail.text;
    [informationView reloadCurrentIndex];
    [self.navigationController.view addSubview:informationView];
    [informationView showAnimation];
}

- (void)lsInformationSelectView:(LSInformationSelectView *)view didSaveInformationForIndex:(NSInteger)index {
    LSPersonalProfileItemObject *item = self.personalItem;
    switch (view.tag) {

        case RowTypeManID: {

        } break;
        case RowTypeHeight: {
            item.height = (int)index;
        } break;
        case RowTypeWeight: {
            item.weight = (int)index;
        } break;
        case RowTypeSmoke: {
            item.smoke = (int)index;

        } break;
        case RowTypeEducation: {
            item.education = (int)index;

        } break;
        case RowTypeProfession: {
            item.profession = (int)index;

        } break;

        case RowTypeLanguage: {
            item.language = (int)index;

        } break;
        case RowTypeChildren: {
            item.children = (int)index;

        } break;
        case RowTypeIncome: {
            item.income = (int)index;

        } break;
        case RowTypeZodiac: {
            item.zodiac = (int)index;
        } break;

        default:
            break;
    }
    [self updateProfile:item];
}

/**
 更新个人描述
 */
- (void)lsMotifyAboutYouViewControllerDidMotifyResume:(LSMotifyAboutYouViewController *)vc {
    [self getPersonalProfile];
}
#pragma mark - collectionView回调

/**
 更新高度
 
 @param height 高度
 */
- (void)lsTagListCollectionViewUpdateHeight:(CGFloat)height {
    self.interestContentHeight.constant = height;
    [self.interestContentView layoutIfNeeded];
}

/**
 更新详情
 
 @param item 个人信息
 @return 成功
 */
- (BOOL)updateProfile:(LSPersonalProfileItemObject *_Nullable)item {
    LSUpdateProfileRequest *request = [[LSUpdateProfileRequest alloc] init];
    request.resume = item.resume;
    request.height = item.height;
    request.weight = item.weight;
    request.smoke = item.smoke;
    request.drink = item.drink;
    request.religion = item.religion;
    request.education = item.education;
    request.profession = item.profession;
    request.ethnicity = item.ethnicity;
    request.income = item.income;
    request.children = item.children;
    request.language = item.language;
    request.zodiac = item.zodiac;
    request.interests = item.interests;
    [self showLoading];
    request.finishHandler = ^(BOOL success, HTTP_LCC_ERR_TYPE errnum, NSString *_Nonnull errmsg, BOOL isModify) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                NSLog(@"LSManProfileViewController::updateProfile( 更新男士详情成功 )");
                self.updatePerson = YES;
                [self getPersonalProfile];
            } else {
                [self hideLoading];
                [[DialogTip dialogTip] showDialogTip:self.view tipText:errmsg];
            }

        });

    };

    return [self.sessionManager sendRequest:request];
}

// 保存男士资料信息
- (void)saveUserData:(LSPersonalProfileItemObject *)item {
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSString *key = [LSLoginManager manager].loginItem.userId;
    NSString *manKey = [NSString stringWithFormat:@"LSManProfile_%@", key];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:item];
    [userData setObject:data forKey:manKey];
    [userData synchronize];
}

- (LSPersonalProfileItemObject *)getUserData {
    NSString *manKey = [NSString stringWithFormat:@"LSManProfile_%@",[LSLoginManager manager].loginItem.userId];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:manKey];
    LSPersonalProfileItemObject *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return item;
}


- (IBAction)editPhotoAction:(id)sender {
    LSProfilePhotoActionViewController *vc = [[LSProfilePhotoActionViewController alloc] initWithNibName:nil bundle:nil];
    [vc showPhotoAction:self];
}


- (void)photoTapAction:(UIButton *)sender {
    LSProfilePhotoViewController *vc = [[LSProfilePhotoViewController alloc] initWithNibName:nil bundle:nil];
    vc.isInReview = ![self.personalItem canUpdatePhoto];
    vc.headImage = self.profilePhoto;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
