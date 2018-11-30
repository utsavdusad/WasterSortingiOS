//
//  GIDGoogleUserInfo.h
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import <GoogleSignIn/GoogleSignIn.h>

/*
 This class is used to store the logged in user info.
 */

@interface GIDGoogleUserInfo : GIDGoogleUser
@property (nonatomic,strong) GIDGoogleUser *user;

@property (nonatomic,strong) NSString *picture;
@property (nonatomic,strong) NSString  *name;
@end
