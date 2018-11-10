//Source: https://github.com/brightec/CustomCamera_Objc
//
//  ImageViewerViewController.h
//  Custom Camera
//
//  Created by Chris Leversuch on 30/06/2016.
//  Copyright © 2016 Brightec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>



@interface ImageViewerViewController : UIViewController
- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic) CLLocation *location;
@end
