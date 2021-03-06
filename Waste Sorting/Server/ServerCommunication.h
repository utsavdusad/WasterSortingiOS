#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

//  Created by Rhythm Sharma on 9/30/18.
//  Copyright © 2018 Hygiea. All rights reserved.


@interface ServerCommunication : NSObject

-(void) signInWithCompletion:(void(^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))completionHandler;

-(void)testUploadImage:(UIImage *)image atLocation:(CLLocation *) location WithCompletion:(void(^)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error))completionHandler;
@end
