#import "ServerCommunication.h"
#import "Constants.h"
#import "DefaultSessionManager.h"

//  Created by Rhythm Sharma on 9/30/18.
//  Copyright © 2018 Hygiea. All rights reserved.

@implementation ServerCommunication{}

// Upload the image to server
-(void) uploadImage:(UIImage *)image{

    NSURLSessionConfiguration *configuration=[NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:SERVER_ADDRESS]];
    NSURLSession *session =[NSURLSession sessionWithConfiguration:configuration];
    NSURLSessionDataTask *task= [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSLog(@"Error: %@", error);
            NSString* newStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"Answer: %@", newStr);
            NSLog(@"%@",error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]);
            NSString* ErrorResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
            NSLog(@"%@",ErrorResponse);
    }];
    [task resume];
}


@end
