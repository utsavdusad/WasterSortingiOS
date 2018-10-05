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

// Test method to upload the image to server
-(void)testUploadImage:(UIImage *)image{
    
    NSMutableURLRequest *request;
    AFHTTPRequestSerializer *reqSerializer = [AFJSONRequestSerializer serializer];
    
    // compressing the image with UIImageJPEGRepresentation
    request = [reqSerializer requestWithMethod:@"POST" URLString:UPLOAD_PATH parameters:nil error:nil];
    NSData* imageData = UIImageJPEGRepresentation(image, 1 /* =compression factor*/);
    
    NSURLSessionUploadTask *task = [[DefaultSessionManager manager] uploadTaskWithRequest:request fromData:imageData progress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"Image uploaded to server successfully");
    }];
   
    
    [task resume];
}

@end
