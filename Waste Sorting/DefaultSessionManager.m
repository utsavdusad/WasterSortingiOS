#import "DefaultSessionManager.h"
#import "AppDelegate.h"

//  Created by Rhythm Sharma on 9/30/18.
//  Copyright © 2018 Hygiea. All rights reserved.

@implementation DefaultSessionManager

+ (instancetype)sharedManager{
    static id sharedMyManager= nil;
    static dispatch_once_t onceToken;
    
    // Singleton session object will get initialized here.
    dispatch_once(&onceToken, ^{
        sharedMyManager =[[self alloc]init];
    });
    return sharedMyManager;
}

-(instancetype)init{
    
    //  Session configuration to be set once in init
    NSURLSessionConfiguration *configuration=[NSURLSessionConfiguration defaultSessionConfiguration];
    [configuration setURLCache:[NSURLCache sharedURLCache]];
    [configuration setRequestCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    self=[super initWithSessionConfiguration:configuration];
    return self;
}

@end
