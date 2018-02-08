//
//  AccountSDKManager.m
//  AccountSDK
//
//  Created by Max on 2017/12/6.
//  Copyright © 2017年 net.qdating. All rights reserved.
//

#import "AccountSDKManager.h"

#pragma mark - Facebook
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

#pragma mark - Twtter
#import <TwitterKit/TwitterKit.h>

static AccountSDKManager *gManager = nil;
@interface AccountSDKManager () <FBSDKSharingDelegate>
@property (strong) AccountShareHandler shareHandler;

#pragma mark - Facebook property
@property (strong) FBSDKLoginManager *loginManagerFacebook;
@property (strong) FBSDKAccessToken *tokenFacebook;

#pragma mark - Twitter property
@property (strong) TWTRSession *sessionTwitter;

@end

@implementation AccountSDKManager

+ (instancetype)shareInstance {
    if (!gManager) {
        gManager = [[AccountSDKManager alloc] init];
    }

    return gManager;
}

- (id)init {
    if (self = [super init]) {
        [self initFacebook];
        [self initTwitter];

        [self loadPersistence];
    }

    NSLog(@"AccountSDKManager::init( %p )", self);
    NSLog( @"AccountSDKManager FB sdk version: %@", [FBSDKSettings sdkVersion] );
    return self;
}

- (void)dealloc {
    NSLog(@"AccountSDKManager::dealloc( %p )", self);

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)autoLogin:(AccountLoginHandler)handler {
    BOOL bFlag = NO;

    NSLog(@"AccountSDKManager::autoLogin( type : %d )", self.type);

    switch (self.type) {
        case AccountSDKType_Facebook: {
            if (self.tokenFacebook) {
                [FBSDKAccessToken setCurrentAccessToken:self.tokenFacebook];
                [self getProfile:^(BOOL success, NSError *error, AccountSDKProfile *profile) {
                    if (handler) {
                        handler(success, error);
                    }
                }];
                bFlag = YES;
            }
        } break;
        case AccountSDKType_Twitter: {
            TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
            if (store.session) {
                [self getProfile:^(BOOL success, NSError *error, AccountSDKProfile *profile) {
                    if (handler) {
                        handler(success, error);
                    }
                }];
                bFlag = YES;
            }
        } break;
        default: {
            bFlag = NO;
        } break;
    }

    return bFlag;
}

- (BOOL)login:(AccountSDKType)type vc:(UIViewController *)vc handler:(AccountLoginHandler)handler {
    BOOL bFlag = YES;

    NSLog(@"AccountSDKManager::login( type : %d )", type);

    self.type = type;
    switch (type) {
        case AccountSDKType_Facebook: {
            [self loginWithFacebook:vc handler:handler];
        } break;
        case AccountSDKType_Twitter: {
            [self loginWithTwitter:vc handler:handler];
        } break;
        default: {
            bFlag = NO;
        } break;
    }

    return bFlag;
}

- (void)logout {
    NSLog(@"AccountSDKManager::logout( type : %d )", self.type);

    switch (self.type) {
        case AccountSDKType_Facebook: {
            [self logoutWithFacebook];
        } break;
        case AccountSDKType_Twitter: {
            [self logoutWithTwitter];
        }break;
        default: {
        } break;
    }
    
    self.type = AccountSDKType_Unknow;
    [self savePersistence];
}

- (BOOL)getProfile:(AccountProfileHandler)handler {
    NSLog(@"AccountSDKManager::getProfile( type : %d )", self.type);

    BOOL bFlag = YES;

    switch (self.type) {
        case AccountSDKType_Facebook: {
            [self getProfileWithFacebook:handler];
        } break;
        case AccountSDKType_Twitter: {
            [self getProfileWithTwitter:handler];
        } break;
        default: {
            bFlag = NO;
        } break;
    }

    return bFlag;
}

- (BOOL)shareItem:(AccountSDKType)type vc:(UIViewController *)vc shareItem:(ACCountSDKShareItem *)shareItem handler:(AccountShareHandler)handler {
    BOOL bFlag = YES;
    NSLog(@"AccountSDKManager::shareItem( type : %d, shareItem : %@ )", type, shareItem);

    self.shareHandler = handler;
    
    switch (type) {
        case AccountSDKType_Facebook: {
            [self shareItemFacebook:vc shareItem:shareItem handler:handler];
        } break;
        case AccountSDKType_Twitter: {
            [self shareItemTwitter:vc shareItem:shareItem handler:handler];
        } break;
        default: {
        } break;
    }

    return bFlag;
}

- (NSString *)token {
    NSString *token = nil;
    
    switch (self.type) {
        case AccountSDKType_Facebook: {
            token = self.tokenFacebook.tokenString;
        } break;
        case AccountSDKType_Twitter: {
            token = self.sessionTwitter.authToken;
        } break;
        default: {
        } break;
    }
    
    NSLog(@"AccountSDKManager::getToken( type : %d, token : %@ )", self.type, token);
    
    return token;
}

#pragma mark - Thirdparty callback
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"AccountSDKManager::didFinishLaunchingWithOptions( launchOptions : %@ )", launchOptions);

    // TODO:Facebook
    // This sample uses FBSDKProfile to get user information,
    //  so we enable automatic fetching on access token changes.
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    // TODO:Twitter

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options {
    NSLog(@"AccountSDKManager::openURL( url : %@ )", url);
    
    BOOL bFlag = YES;
    bFlag = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey]
                                                               annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
//    bFlag = [[FBSDKApplicationDelegate sharedInstance] application:application
//                                                           openURL:url
//                                                           options:options];
    bFlag = [[Twitter sharedInstance] application:application
                                          openURL:url
                                          options:options];

    return bFlag;
}

// Still need this for iOS8
- (BOOL)application:(UIApplication *)application
              openURL:(NSURL *)url
    sourceApplication:(nullable NSString *)sourceApplication
           annotation:(nonnull id)annotation {
    NSLog(@"AccountSDKManager::openURL( sourceApplication : %@, url : %@ )", sourceApplication, url);

    BOOL bFlag = YES;

    bFlag = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                           openURL:url
                                                 sourceApplication:sourceApplication
                                                        annotation:annotation];

    return bFlag;
}

#pragma mark - Persistence method
- (void)savePersistence {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:self.type forKey:@"type"];

    NSData *dataFacebookToken = [NSKeyedArchiver archivedDataWithRootObject:self.tokenFacebook];
    [userDefaults setObject:dataFacebookToken forKey:@"tokenFacebook"];

    NSData *dataTwitterSession = [NSKeyedArchiver archivedDataWithRootObject:self.sessionTwitter];
    [userDefaults setObject:dataTwitterSession forKey:@"sessionTwitter"];

    [userDefaults synchronize];
}

- (void)loadPersistence {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.type = (AccountSDKType)[userDefaults integerForKey:@"type"];

    NSData *dataFacebookToken = [userDefaults objectForKey:@"tokenFacebook"];
    self.tokenFacebook = [NSKeyedUnarchiver unarchiveObjectWithData:dataFacebookToken];

    NSData *dataTwitterSession = [userDefaults objectForKey:@"sessionTwitter"];
    self.sessionTwitter = [NSKeyedUnarchiver unarchiveObjectWithData:dataTwitterSession];
}

#pragma mark - Facebook method
- (void)initFacebook {
    NSString *facebookAppID = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"FacebookAppID"];
    NSLog(@"AccountSDKManager::initFacebook( facebookAppID : %@ )", facebookAppID);

    self.loginManagerFacebook = [[FBSDKLoginManager alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(accessTokenChangedFacebook:)
                                                 name:FBSDKAccessTokenDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(currentProfileChangedFacebook:)
                                                 name:FBSDKProfileDidChangeNotification
                                               object:nil];
}

- (void)loginWithFacebook:(UIViewController *)vc handler:(AccountLoginHandler)handler {
    NSLog(@"AccountSDKManager::loginWithFacebook()");
    [self.loginManagerFacebook logInWithReadPermissions:nil
                                     fromViewController:vc
                                                handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                                    NSLog(@"AccountSDKManager::loginWithFacebook( [Finish], result : %@, error : %@ )", result, error);

                                                    if (!error && result.token) {
                                                        self.tokenFacebook = result.token;
                                                        [self savePersistence];
                                                    }
                                                    handler((result.isCancelled ? !result.isCancelled : !error), error);
                                                }];
}

- (void)logoutWithFacebook {
    NSLog(@"AccountSDKManager::logoutWithFacebook()");
    [self.loginManagerFacebook logOut];
    self.tokenFacebook = nil;
    [self savePersistence];
}

- (void)getProfileWithFacebook:(AccountProfileHandler)handler {
    NSLog(@"AccountSDKManager::getProfileWithFacebook()");
    // picture.type enum{small, normal, album, large, square}
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{ @"fields" : @"id, name, first_name, last_name, email, picture.type(large), gender" }];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        // Since we're only requesting /me, we make a simplifying assumption that any error
        // means the token is bad.
        NSLog(@"AccountSDKManager::getProfileWithFacebook( [Finish], result : %@, error : %@ )", result, error);
        if (handler) {
            AccountSDKProfile *profile = [[AccountSDKProfile alloc] init];
            profile.name = result[@"name"];
            profile.firstName = result[@"first_name"];
            profile.lastName = result[@"last_name"];
            profile.gender = result[@"gender"];
            NSDictionary *picture = result[@"picture"];
            if (picture) {
                NSDictionary *data = picture[@"data"];
                if (data) {
                    profile.photoUrl = data[@"url"];
                }
            }
            handler(!error, error, profile);
        }
    }];
}

- (void)shareItemFacebook:(UIViewController *)vc shareItem:(ACCountSDKShareItem *)shareItem handler:(AccountShareHandler)handler {
    NSLog(@"AccountSDKManager::shareItemFacebook()");
    NSObject<FBSDKSharingContent> *shareContent = nil;
    switch (shareItem.type) {
        case ACCountSDKShareItemType_Link: {
            FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
            content.contentURL = [NSURL URLWithString:shareItem.url];
            shareContent = content;
        } break;
        case ACCountSDKShareItemType_Photo: {
            FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
            NSMutableArray *images = [NSMutableArray array];
            for(UIImage *image in shareItem.imageArray) {
                FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImage:image userGenerated:YES];
                [images addObject:photo];
            }
            content.photos = images;
            shareContent = content;
        } break;
        default:
            break;
    }
    
    FBSDKShareDialog *dialog = [[FBSDKShareDialog alloc] init];
    dialog.fromViewController = vc;
    dialog.shareContent = shareContent;
    dialog.delegate = self;
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fbauth2://"]]){
        dialog.mode = FBSDKShareDialogModeNative;
    } else {
        dialog.mode = FBSDKShareDialogModeAutomatic;
    }
    
    [dialog show];
    
//    [FBSDKShareDialog showFromViewController:vc withContent:shareContent delegate:self];
}

#pragma mark - Facebook method login delegate
- (void)accessTokenChangedFacebook:(NSNotification *)notification {
    FBSDKAccessToken *token = notification.userInfo[FBSDKAccessTokenChangeNewKey];
    NSLog(@"AccountSDKManager::accessTokenChangedFacebook( [Token is changed], token : %@ )", token);
    self.tokenFacebook = token;
    [self savePersistence];
}

- (void)currentProfileChangedFacebook:(NSNotification *)notification {
    FBSDKProfile *profile = notification.userInfo[FBSDKProfileChangeNewKey];
    NSLog(@"AccountSDKManager::currentProfileChangedFacebook( [Profile is changed], profile : %@ )", profile);
    if (profile) {

    } else {
    }
}

#pragma mark - Facebook method share delegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results {
    NSLog(@"AccountSDKManager::sharer_didCompleteWithResults( results : %@ )", results);
    if( self.shareHandler ) {
        self.shareHandler(YES, nil);
    }
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error {
    NSLog(@"AccountSDKManager::sharer_didFailWithError( error : %@ )", error);
    if( self.shareHandler ) {
        self.shareHandler(NO, error);
    }
}

- (void)sharerDidCancel:(id<FBSDKSharing>)sharer {
    NSLog(@"AccountSDKManager::sharer_sharerDidCancel()");
    if( self.shareHandler ) {
        self.shareHandler(NO, nil);
    }
}

#pragma mark - Twitter method
- (void)initTwitter {
    NSString *twitterKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TwitterAppID"];
    NSString *twitterSecret = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TwitterAppSecret"];

    NSLog(@"AccountSDKManager::initTwitter( twitterKey : %@, twitterSecret : %@ )", twitterKey, twitterSecret);
    [[Twitter sharedInstance] startWithConsumerKey:twitterKey consumerSecret:twitterSecret];
}

- (void)loginWithTwitter:(UIViewController *)vc handler:(AccountLoginHandler)handler {
    NSLog(@"AccountSDKManager::loginWithTwitter()");

    [[Twitter sharedInstance] logInWithCompletion:^(TWTRSession *session, NSError *error) {
        NSLog(@"AccountSDKManager::loginWithTwitter( [Finish], session : %@, error : %@ )", session, error);
        if (session) {
            self.sessionTwitter = session;
            [self savePersistence];
        }
        handler((!error), error);
    }];
}

- (void)logoutWithTwitter {
    NSLog(@"AccountSDKManager::logoutWithTwitter()");

    TWTRSessionStore *store = [[Twitter sharedInstance] sessionStore];
    NSString *userID = store.session.userID;
    [store logOutUserID:userID];

    self.sessionTwitter = nil;
    [self savePersistence];
}

- (void)getProfileWithTwitter:(AccountProfileHandler)handler {
    NSLog(@"AccountSDKManager::getProfileWithTwitter()");

    TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];
    [client requestEmailForCurrentUser:^(NSString *email, NSError *error) {
        NSLog(@"AccountSDKManager::getProfileWithTwitter( [Finish], email : %@, error : %@ )", email, error);
        AccountSDKProfile *profile = [[AccountSDKProfile alloc] init];
        profile.email = email;

        dispatch_async(dispatch_get_main_queue(), ^{
            TWTRAPIClient *client = [[TWTRAPIClient alloc] init];
            [client loadUserWithID:self.sessionTwitter.userID
                        completion:^(TWTRUser *user, NSError *error) {
                            NSLog(@"AccountSDKManager::getProfileWithTwitter( [Finish], user : %@, error : %@ )", user, error);
                            if (handler) {
                                if (user) {
                                    profile.name = user.name;
                                    profile.photoUrl = user.profileImageLargeURL;
                                }
                                handler(!error, error, profile);
                            }
                        }];
        });
    }];
}

- (void)shareItemTwitter:(UIViewController *)vc shareItem:(ACCountSDKShareItem *)shareItem handler:(AccountShareHandler)handler {
    NSLog(@"AccountSDKManager::shareItemTwitter()");
    TWTRAPIClient *client = [TWTRAPIClient clientWithCurrentUser];

    switch (shareItem.type) {
        case ACCountSDKShareItemType_Link: {
            NSString *shareText = [NSString stringWithFormat:@"%@%@", shareItem.text, shareItem.url];
            [client sendTweetWithText:shareText
                           completion:^(TWTRTweet *_Nullable tweet, NSError *_Nullable error) {
                               NSLog(@"AccountSDKManager::shareItemTwitter( [Share link Finish], error : %@ )", error);
                               if( handler ) {
                                   handler(!error, error);
                               }
                           }];
        } break;
        case ACCountSDKShareItemType_Photo: {
            UIImage *image = (shareItem.imageArray.count > 0) ? shareItem.imageArray[0] : nil;
            [client sendTweetWithText:shareItem.text
                                image:image
                           completion:^(TWTRTweet *_Nullable tweet, NSError *_Nullable error) {
                               NSLog(@"AccountSDKManager::shareItemTwitter( [Share photo finish], error : %@ )", error);
                               if( handler ) {
                                   handler(!error, error);
                               }
                           }];
        } break;
        default:
            break;
    }
}
@end
