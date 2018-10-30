
//  BackgroundSessionManager.h
//  Waste Sorting
//
//  Created by Rhythm Sharma on 10/29/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface BackgroundSessionManager : AFHTTPSessionManager

+(instancetype) sharedManager;

@end

NS_ASSUME_NONNULL_END
