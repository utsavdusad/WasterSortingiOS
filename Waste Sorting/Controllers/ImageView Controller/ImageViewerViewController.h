//This viewController is for preseting the image before uplaoding
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
/*
 This class previews the image and shows buttot for upload. 
 */


@interface ImageViewerViewController : UIViewController
- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic) CLLocation *location;
@end
