//
//  GoogleLoginManager.h
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "GIDGoogleUserInfo.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@import GoogleSignIn;

@protocol LoginManagerDelegate <NSObject>

- (void)didLogin;
- (void)didLogout;
- (void)didDisconnect;
- (void)didFailWithError:(NSError*)error;
@end


@interface LoginManager : NSObject<GIDSignInUIDelegate, GIDSignInDelegate, FBSDKLoginButtonDelegate>
@property (nonatomic, assign) id<LoginManagerDelegate> delegate;
@property (nonatomic, strong) GIDGoogleUserInfo *loggedUser;
+ (instancetype)sharedLoginManager;
+ (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;


- (void)tryLoginWithDelegateAndSetDelegates:(id<LoginManagerDelegate>)delegate forButton:(FBSDKLoginButton *)btn;
- (void)tryLogout;
-(void)fbLogout;

@end
