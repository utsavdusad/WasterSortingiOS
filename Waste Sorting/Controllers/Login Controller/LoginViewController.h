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

@interface LoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;

@end
