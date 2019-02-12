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

- (BOOL)isRiskControlType:(RiskType)type
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
             isRisk = [LSLoginManager manager].loginItem.isLiveChatRisk;
            if (isRisk) {
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"RiskControl_Chat", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
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
