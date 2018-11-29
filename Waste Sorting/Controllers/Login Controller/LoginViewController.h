//
//  LoginViewController.h
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginManager.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
/*
 This class is called first when the app open. If the credentials are already present then it do silent signIn and if credentials are not present then the user has to do either google signIn or FBSignIn.
 */

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;

@end
