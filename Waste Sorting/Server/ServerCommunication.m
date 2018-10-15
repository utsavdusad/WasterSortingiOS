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

//Inputs: 1. PHAsset
//Outputs: returns the file name for the PHasset.
-(NSString *) getFileNameForAsset:(PHAsset *)asset {
    
    
 
        //If a new file then add a random string to the caption otherwise return the file name form the file list object.
        NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
        NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
        NSString *fileWithoutExtension=[orgFilename stringByDeletingPathExtension];
        NSString *fileExtension=[orgFilename pathExtension];
        return [[fileWithoutExtension stringByAppendingString:[NSString stringWithFormat:@"_%ld",(long)[self randomNumberGenerator]] ]stringByAppendingPathExtension:fileExtension];

    
}
//It geneates random 8 digit number.
-(NSInteger)randomNumberGenerator{
    
    return arc4random_uniform(100000000) -1 ;
    
}

-(void) uploadImage:(UIImage *)image withImageName:(NSString *)imageName{
    
    
    NSURL *theURL = [NSURL URLWithString:SERVER_PATH];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:theURL];
    
    // setting the HTTP method
    [request setHTTPMethod:@"POST"];
    
    // we want a JSON response
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    // the boundary string. Can be whatever we want, as long as it doesn't appear as part of "proper" fields
    NSString *boundary = @"wasteSorting";
    
    // setting the Content-type and the boundary
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // we need a buffer of mutable data where we will write the body of the request
    NSMutableData *body = [NSMutableData data];
    
    // creating a NSData representation of the image
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    
    
    // if we have successfully obtained a NSData representation of the image
    if (imageData) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"upload\"; filename=\"%@\"\r\n", imageName] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else
        NSLog(@"no image data!!!");
    
    
    // we close the body with one last boundary
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    // assigning the completed NSMutableData buffer as the body of the HTTP POST request
    [request setHTTPBody:body];
    
    
    
    
    NSURLSessionDataTask *task =[[DefaultSessionManager manager] dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSLog(@"%@",error);
        NSLog(@"%@",response);
    }];
    [task resume];
    // send the request
    
    
}
-(void)testUploadImage:(PHAsset *)asset{
    
    PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = YES;
    
    PHImageManager *manager = [PHImageManager defaultManager];
    __weak ServerCommunication *weakSelf = self;
    [manager requestImageForAsset:asset
                       targetSize:PHImageManagerMaximumSize
                      contentMode:PHImageContentModeDefault
                          options:requestOptions
                    resultHandler:^void(UIImage *image, NSDictionary *info) {
                        
                        if ([info objectForKey:@"PHImageFileURLKey"]) {
                            // path looks like this -
                            NSURL *path = [info objectForKey:@"PHImageFileURLKey"];
                            NSLog(@"%@",path);
                        }
                       NSString *filename=[weakSelf getFileNameForAsset:asset];
                      [weakSelf uploadImage:image withImageName:filename];
                        
                        
                    }];
    
    
    
   

}


@end
