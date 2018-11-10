#import "ServerCommunication.h"
#import "Constants.h"
#import "DefaultSessionManager.h"
#import "MZFormSheetPresentationViewController.h"
#import "ProcessingViewController.h"
#import "GoogleLoginManager.h"
#import "BackgroundSessionManager.h"



//  Created by Rhythm Sharma on 9/30/18.
//  Copyright © 2018 Hygiea. All rights reserved.

@implementation ServerCommunication{}


//
////Inputs: 1. PHAsset
////Outputs: returns the file name for the PHasset.
//-(NSString *) getFileNameForAsset:(PHAsset *)asset {
//        //If a new file then add a random string to the caption otherwise return the file name form the file list object.
//        NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
//        NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
//        NSString *fileWithoutExtension=[orgFilename stringByDeletingPathExtension];
//        NSString *fileExtension=[orgFilename pathExtension];
//        return [[fileWithoutExtension stringByAppendingString:[NSString stringWithFormat:@"_%ld",(long)[self randomNumberGenerator]] ]stringByAppendingPathExtension:fileExtension];
//
//}
////It geneates random 8 digit number.
-(NSInteger)randomNumberGenerator{
    
    return arc4random_uniform(100000000) -1 ;
    
}


//This method compresses the image. See the issue: https://tree.taiga.io/project/utsavdusad-capstone-ser-517-software-factory-i/task/92?kanban-status=1437704
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

//-(void) uploadImage:(UIImage *)image withImageName:(NSString *)imageName withCompletion:(void(^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))completionHandler{
//    NSURL *theURL = [NSURL URLWithString:SERVER_PATH];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:theURL];
//
//    // setting the HTTP method
//    [request setHTTPMethod:@"POST"];
//
//
//
//    // we want a JSON response
//    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    // Prepare a temporary file to store the multipart request prior to sending it to the server due to an alleged
//    // bug in NSURLSessionTask.
//    NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
//    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
//
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//    ProcessingViewController *pvc = (ProcessingViewController   *)[mainStoryboard
//                                                                   instantiateViewControllerWithIdentifier:@"ProcessingViewController"];
//    UIWindow *windowp= [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
//    [self showProcessingView:pvc onWindow:windowp];
//
//    // Create a multipart form request.
//    NSMutableURLRequest *multipartRequest = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SERVER_PATH parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
//        NSString *fileName=imageName;
//        NSData *imageData = UIImageJPEGRepresentation(image, 1);
//        [formData appendPartWithFileData:imageData name:@"upload" fileName:fileName mimeType:@"image/jpeg"];
//
//    } error:nil];
//
//    multipartRequest.timeoutInterval = 1000 * 60.0;
//
//
//    if ([[GIDSignIn sharedInstance] hasAuthInKeychain] ){
//         NSString *token = [NSString stringWithFormat:@"%@",[[[[GIDSignIn sharedInstance] currentUser] authentication ] accessToken]];
//        [multipartRequest setValue:[NSString stringWithFormat:@"google"] forHTTPHeaderField:SSO_TYPE];
//        [multipartRequest setValue:token forHTTPHeaderField:@"token"];
//
//    }else if([FBSDKAccessToken currentAccessToken]){
//        NSString *fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
//        NSLog(@"%@",fbAccessToken);
//        NSString *token = [NSString stringWithFormat:@"%@",[FBSDKAccessToken currentAccessToken].tokenString];
//
//        [multipartRequest setValue:[NSString stringWithFormat:@"facebook"] forHTTPHeaderField:SSO_TYPE];
//        [multipartRequest setValue:token forHTTPHeaderField:@"token"];
//    }
//
//
//    // Dump multipart request into the temporary file.
//    [[AFHTTPRequestSerializer serializer]
//     requestWithMultipartFormRequest:multipartRequest
//     writingStreamContentsToFile:tmpFileUrl
//     completionHandler:^(NSError *error) {
//         // Here note that we are submitting the initial multipart request. We are, however,
//         // forcing the body stream to be read from the temporary file.
//         NSURLSessionUploadTask *uploadTask = [[DefaultSessionManager sharedManager] uploadTaskWithRequest:multipartRequest fromFile:tmpFileUrl progress:^(NSProgress * _Nonnull uploadProgress) {
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 pvc.progressView.progress=uploadProgress.fractionCompleted;
//                 pvc.progressPercentage.text= [NSString stringWithFormat:@"%.2f",uploadProgress.fractionCompleted*100];
//             });
//
//         }
//                completionHandler:^(NSURLResponse *response,
//                                    id responseObject,
//                                    NSError *error){
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                                        windowp.hidden=YES;
//                                                                                                 // Cleanup: remove temporary file.
//                                                                                                 [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
//
//                                                                                                 NSLog(@"%@",error);
//                                                                                                 NSLog(@"%@",response);
//                                                                                                 NSString *mssg;
//                                                                                                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
//
//                                                                                                 if (error || (long)[httpResponse statusCode]!=200)
//                                                                                                     mssg = @"Image not uploaded";
//                                                                                                 else{
//                                                                                                     NSString *temp=[NSString stringWithFormat:@"Thrash bin: %@ \nConfidence:%@%%",[responseObject valueForKey:@"trashBin"], [responseObject valueForKey:@"Percent"]];
//                                                                                                     mssg = temp;
//                                                                                                 }
//
//                                                                                                 UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//                                                                                                 window.rootViewController = [UIViewController new];
//                                                                                                 window.windowLevel = UIWindowLevelAlert + 1;
//
//                                                                                                 UIAlertController* alertCtrl = [UIAlertController alertControllerWithTitle:@"Important" message:mssg preferredStyle:UIAlertControllerStyleAlert];
//
//                                                                                                 UIAlertAction *okAction= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//
//                                                                                                     window.hidden = YES;
//
//                                                                                                     NSLog(@"Oh Yeah!");
//                                                                                                     completionHandler(response, responseObject,error);
//                                                                                                 }];
//
//
//                                                                                                 [alertCtrl addAction:okAction];
//
//                                                                                                 //http://stackoverflow.com/questions/25260290/makekeywindow-vs-makekeyandvisible
//
//                                                                                                 [window makeKeyAndVisible]; //The makeKeyAndVisible message makes a window key, and moves it to be in front of any other windows on its level
//
//                                                                                                 [alertCtrl.view setNeedsLayout];
//
//                                                                                                 [window.rootViewController presentViewController:alertCtrl animated:YES completion:nil];
//
//
//                                                                                             });
//
//                                                                                         }];
//
//
//         // Start the upload.
//
//         [uploadTask resume];
//
//
//
//     }];
//
//}



-(void)setupBackgroundWindow{
    // Set Default Background collor for all presentation controllers
    [[MZFormSheetPresentationController appearance] setBackgroundColor:[[UIColor darkGrayColor] colorWithAlphaComponent:0.3]];
    
}

-(void)showProcessingView:(ProcessingViewController *)pvc onWindow:(UIWindow *)window{
    [self setupBackgroundWindow];
    
    window.windowLevel = UIWindowLevelAlert + 1;
    window.rootViewController = [UIViewController new];
    MZFormSheetPresentationViewController *formSheetController = [[MZFormSheetPresentationViewController alloc] initWithContentViewController:pvc];
    
    formSheetController.presentationController.contentViewSize = CGSizeMake(window.rootViewController.view.frame.size.width*0.40, window.rootViewController.view.frame.size.height*0.15);
    
    
    formSheetController.presentationController.shouldCenterVertically = YES;
    
    
    
     [window makeKeyAndVisible];
    [window.rootViewController presentViewController:formSheetController animated:YES completion:nil];
}

// This method does signIn call
-(void) signInWithCompletion:(void(^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))completionHandler{
    NSURL *theURL = [NSURL URLWithString:SIGN_IN_PATH];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:theURL];
//     NSString *token = [NSString stringWithFormat:@"%@",[[[[GIDSignIn sharedInstance] currentUser] authentication ] accessToken]];
    [request setHTTPMethod:@"POST"];
    
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain] ){
        NSString *token = [NSString stringWithFormat:@"%@",[[[[GIDSignIn sharedInstance] currentUser] authentication ] accessToken]];
    
        [request setValue:[NSString stringWithFormat:@"google"] forHTTPHeaderField:SSO_TYPE];
        [request setValue:token forHTTPHeaderField:@"token"];
        
    }else if([FBSDKAccessToken currentAccessToken]){
        NSString *token = [NSString stringWithFormat:@"%@",[FBSDKAccessToken currentAccessToken].tokenString];
        NSLog(@"%@",[FBSDKAccessToken currentAccessToken].tokenString);
        [request setValue:[NSString stringWithFormat:@"facebook"] forHTTPHeaderField:SSO_TYPE];
        [request setValue:token forHTTPHeaderField:@"token"];
    }
    
    
    NSURLSessionDataTask *task=[[DefaultSessionManager sharedManager] dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        completionHandler(response,responseObject,error);
    }];
    
    [task resume];
}

//-(void)testUploadImage:(UIImage *)image WithCompletion:(void(^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))completionHandler{
//
//    NSString *filename = [NSString stringWithFormat:@"Camera-%ld.jpg",(long)[self randomNumberGenerator]];
//    UIImage *compressImage=[self compressImage:image ];
//    [self uploadImage:compressImage withImageName:filename withCompletion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        completionHandler(response,responseObject,error);
//    }];
//
//}

-(void)testUploadImage:(UIImage *)image atLocation:(CLLocation *) location WithCompletion:(void(^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))completionHandler{
    
    NSString *filename = [NSString stringWithFormat:@"Camera-%ld.jpg",(long)[self randomNumberGenerator]];
    UIImage *compressImage=[self compressImage:image ];
    
    [self uploadImage:compressImage atlocation:location withImageName:filename withCompletion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        completionHandler(response,responseObject,error);
    }];

    
}



-(void) uploadImage:(UIImage *)image atlocation:(CLLocation *)location withImageName:(NSString *)imageName withCompletion:(void(^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))completionHandler{
    NSURL *theURL = [NSURL URLWithString:SERVER_PATH];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:theURL];
    
    // setting the HTTP method
    [request setHTTPMethod:@"POST"];
    
    
    
    // we want a JSON response
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    // Prepare a temporary file to store the multipart request prior to sending it to the server due to an alleged
    
   
    // bug in NSURLSessionTask.
    NSString* tmpFilename = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]];
    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    ProcessingViewController *pvc = (ProcessingViewController   *)[mainStoryboard
                                                                   instantiateViewControllerWithIdentifier:@"ProcessingViewController"];
    UIWindow *windowp= [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [self showProcessingView:pvc onWindow:windowp];
    
    // Create a multipart form request.
    NSMutableURLRequest *multipartRequest = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:SERVER_PATH parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData){
        NSString *fileName=imageName;
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [formData appendPartWithFileData:imageData name:@"upload" fileName:fileName mimeType:@"image/jpeg"];
        
    } error:nil];
    
    multipartRequest.timeoutInterval = 1000 * 60.0;
    
    [multipartRequest setValue:[NSString stringWithFormat:@"%f",location.coordinate.latitude] forHTTPHeaderField:@"latitude"];
    [multipartRequest setValue:[NSString stringWithFormat:@"%f",location.coordinate.longitude] forHTTPHeaderField:@"longitude"];
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain] ){
        NSString *token = [NSString stringWithFormat:@"%@",[[[[GIDSignIn sharedInstance] currentUser] authentication ] accessToken]];
        [multipartRequest setValue:[NSString stringWithFormat:@"google"] forHTTPHeaderField:SSO_TYPE];
        [multipartRequest setValue:token forHTTPHeaderField:@"token"];
        
    }else if([FBSDKAccessToken currentAccessToken]){
        NSString *fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
        NSLog(@"%@",fbAccessToken);
        NSString *token = [NSString stringWithFormat:@"%@",[FBSDKAccessToken currentAccessToken].tokenString];
        
        [multipartRequest setValue:[NSString stringWithFormat:@"facebook"] forHTTPHeaderField:SSO_TYPE];
        [multipartRequest setValue:token forHTTPHeaderField:@"token"];
    }
    
    
    // Dump multipart request into the temporary file.
    [[AFHTTPRequestSerializer serializer]
     requestWithMultipartFormRequest:multipartRequest
     writingStreamContentsToFile:tmpFileUrl
     completionHandler:^(NSError *error) {
         // Here note that we are submitting the initial multipart request. We are, however,
         // forcing the body stream to be read from the temporary file.
         NSURLSessionUploadTask *uploadTask = [[DefaultSessionManager sharedManager] uploadTaskWithRequest:multipartRequest fromFile:tmpFileUrl progress:^(NSProgress * _Nonnull uploadProgress) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 pvc.progressView.progress=uploadProgress.fractionCompleted;
                 pvc.progressPercentage.text= [NSString stringWithFormat:@"%.2f",uploadProgress.fractionCompleted*100];
             });
             
         }
                                                                                         completionHandler:^(NSURLResponse *response,
                                                                                                             id responseObject,
                                                                                                             NSError *error){
                                                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                                                 windowp.hidden=YES;
                                                                                                 // Cleanup: remove temporary file.
                                                                                                 [[NSFileManager defaultManager] removeItemAtURL:tmpFileUrl error:nil];
                                                                                                 
                                                                                                 NSLog(@"%@",error);
                                                                                                 NSLog(@"%@",response);
                                                                                                 NSString *mssg;
                                                                                                 NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                                                                                                 
                                                                                                 if (error || (long)[httpResponse statusCode]!=200)
                                                                                                     mssg = @"Image not uploaded";
                                                                                                 else{
                                                                                                     NSString *temp=[NSString stringWithFormat:@"Thrash bin: %@ \nConfidence:%@%%",[responseObject valueForKey:@"trashBin"], [responseObject valueForKey:@"Percent"]];
                                                                                                     mssg = temp;
                                                                                                 }
                                                                                                 
                                                                                                 UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
                                                                                                 window.rootViewController = [UIViewController new];
                                                                                                 window.windowLevel = UIWindowLevelAlert + 1;
                                                                                                 
                                                                                                 UIAlertController* alertCtrl = [UIAlertController alertControllerWithTitle:@"Important" message:mssg preferredStyle:UIAlertControllerStyleAlert];
                                                                                                 
                                                                                                 UIAlertAction *okAction= [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                                                                     
                                                                                                     
                                                                                                     window.hidden = YES;
                                                                                                     
                                                                                                     NSLog(@"Oh Yeah!");
                                                                                                     completionHandler(response, responseObject,error);
                                                                                                 }];
                                                                                                 
                                                                                                 
                                                                                                 [alertCtrl addAction:okAction];
                                                                                                 
                                                                                                 //http://stackoverflow.com/questions/25260290/makekeywindow-vs-makekeyandvisible
                                                                                                 
                                                                                                 [window makeKeyAndVisible]; //The makeKeyAndVisible message makes a window key, and moves it to be in front of any other windows on its level
                                                                                                 
                                                                                                 [alertCtrl.view setNeedsLayout];
                                                                                                 
                                                                                                 [window.rootViewController presentViewController:alertCtrl animated:YES completion:nil];
                                                                                                 
                                                                                                 
                                                                                             });
                                                                                             
                                                                                         }];
         
         
         // Start the upload.
         
         [uploadTask resume];
         
         
         
     }];
    
}


@end
