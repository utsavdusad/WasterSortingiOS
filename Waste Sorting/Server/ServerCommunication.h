#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

//  Created by Rhythm Sharma on 9/30/18.
//  Copyright © 2018 Hygiea. All rights reserved.

@interface ServerCommunication : NSObject

-(void) uploadImage:(UIImage *)image;
-(void)testUploadImage:(PHAsset *)asset;
@end
