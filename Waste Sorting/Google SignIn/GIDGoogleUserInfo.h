//
//  GIDGoogleUserInfo.h
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>

@interface GIDGoogleUserInfo : GIDGoogleUser
@property (nonatomic,strong) GIDGoogleUser *user;

@property (nonatomic,strong) NSString *picture;
@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *locale;
@end
