//
//  RiskControlManager.m
//  dating
//
//  Created by Calvin on 2017/11/8.
//  Copyright © 2017年 qpidnetwork. All rights reserved.
//

#import "QNRiskControlManager.h"
#import "LSLoginManager.h"
static QNRiskControlManager* riskControlManager = nil;
@interface QNRiskControlManager ()
@end

@implementation QNRiskControlManager

+ (instancetype)manager
{
    if (riskControlManager == nil) {
        riskControlManager = [[[self class] alloc] init];
    }
    return riskControlManager;
}

- (BOOL)isRiskControlType:(RiskType)type withController:(UIViewController *_Nullable)vc
{
    BOOL isRisk = NO;
    switch (type) {
//        case RiskType_Ladyprofile:
//            isRisk = [LoginManager manager].loginItem.ladyprofile;
//            if (isRisk) {
//                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"RiskControl_LadyDetails", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//            }
//            break;
//        case RiskType_camshare:
//             isRisk = [LoginManager manager].loginItem.camshare;
//            if (isRisk) {
//                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"RiskControl_CamShare", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//            }
//            break;
        case RiskType_livechat:
            // isLiveChatRisk 改用为isLiveChatPriv
             //isRisk = [LSLoginManager manager].loginItem.isLiveChatRisk;
            if ([LSLoginManager manager].loginItem.isLiveChatRisk || !([LSLoginManager manager].loginItem.userPriv.liveChatPriv.isLiveChatPriv)) {
                isRisk = YES;
            }
            if (isRisk) {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"" message:NSLocalizedString(@"RiskControl_Chat", nil) preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAC = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
                [alertVC addAction:cancelAC];
                [vc presentViewController:alertVC animated:YES completion:nil];
            }
            break;
//        case RiskType_admirer:
//            isRisk = [LoginManager manager].loginItem.admirer;
//            if (isRisk) {
//                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"RiskControl_Admirers", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//            }
//            break;
//        case RiskType_bpemf:
//             isRisk = [LoginManager manager].loginItem.bpemf;
//            if (isRisk) {
//                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"RiskControl_EMF", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                [alertView show];
//            }
//            break;
        default:
            break;
    }
    return isRisk;
}


@end
