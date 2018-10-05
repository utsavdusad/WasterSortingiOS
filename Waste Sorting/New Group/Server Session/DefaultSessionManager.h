#import <AFNetworking/AFNetworking.h>

//  Created by Rhythm Sharma on 9/30/18.
//  Copyright © 2018 Hygiea. All rights reserved.

@interface DefaultSessionManager : AFHTTPSessionManager

+(instancetype) sharedManager;

@end
