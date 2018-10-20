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
        NSString *mssg;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        if (error || (long)[httpResponse statusCode]!=200)
            mssg = @"Image not uploaded";
        else
            mssg = [responseObject valueForKey:@"trashBin"];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window.rootViewController = [UIViewController new];
            window.windowLevel = UIWindowLevelAlert + 1;
            UIAlertController* alertCtrl = [UIAlertController alertControllerWithTitle:@"Important" message:mssg preferredStyle:UIAlertControllerStyleAlert];
            
            
           UIAlertAction *okAction= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                window.hidden = YES;
                NSLog(@"Oh Yeah!");
            }];
            
            [alertCtrl addAction:okAction];
            //http://stackoverflow.com/questions/25260290/makekeywindow-vs-makekeyandvisible
            [window makeKeyAndVisible]; //The makeKeyAndVisible message makes a window key, and moves it to be in front of any other windows on its level
            [alertCtrl.view setNeedsLayout];
            [window.rootViewController presentViewController:alertCtrl animated:YES completion:nil];
            
        });
        
       
        
    }];
    [task resume];
    // send the request
    
    
}

-(UIImage *) compressImage:(UIImage *)image{
    float actualHeight = image.size.height;
    float actualWidth = image.size.width;
    float maxHeight = 600.0;
    float maxWidth = 800.0;
    float imgRatio = actualWidth/actualHeight;
    float maxRatio = maxWidth/maxHeight;
    float compressionQuality = 0.5;//50 percent compression
    NSData *imgData = UIImageJPEGRepresentation(image, 1.0);
    NSLog(@"Size of Image before compression(bytes):%lu",(unsigned long)[imgData length]);
    if (actualHeight > maxHeight || actualWidth > maxWidth){
        if(imgRatio < maxRatio){
            //adjust width according to maxHeight
            imgRatio = maxHeight / actualHeight;
            actualWidth = imgRatio * actualWidth;
            actualHeight = maxHeight;
        }
        else if(imgRatio > maxRatio){
            //adjust height according to maxWidth
            imgRatio = maxWidth / actualWidth;
            actualHeight = imgRatio * actualHeight;
            actualWidth = maxWidth;
        }
        else{
            actualHeight = maxHeight;
            actualWidth = maxWidth;
        }
    }
    CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [image drawInRect:rect];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
    NSLog(@"Size of Image after compression(bytes):%lu",(unsigned long)[imageData length]);
    UIGraphicsEndImageContext();
    return [UIImage imageWithData:imageData];
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
                      UIImage *compressImage=[weakSelf compressImage:image ];
                      [weakSelf uploadImage:compressImage withImageName:filename];
                    }];
}


@end
