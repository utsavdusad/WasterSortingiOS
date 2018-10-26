//
//  GIDGoogleUserInfo.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "GIDGoogleUserInfo.h"

@implementation GIDGoogleUserInfo

- (instancetype)initWithUser:(GIDGoogleUser*)signInUser {
    self = [super init];
    if( self ) {
        self.user = signInUser;
    }
    return self;
}


@end
