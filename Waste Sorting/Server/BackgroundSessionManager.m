//
//  BackgroundSessionManager.m
//  Waste Sorting
//
//  Created by Rhythm Sharma  on 10/29/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "BackgroundSessionManager.h"

@implementation BackgroundSessionManager


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
    NSURLSessionConfiguration *configuration=[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundsessionID"];
    [configuration setURLCache:[NSURLCache sharedURLCache]];
    
    self=[super initWithSessionConfiguration:configuration];
    return self;
}


@end
