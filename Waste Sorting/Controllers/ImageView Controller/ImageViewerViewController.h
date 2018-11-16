//This viewController is for preseting the image before uplaoding
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>



@interface ImageViewerViewController : UIViewController
- (instancetype)initWithImage:(UIImage *)image;

@property (nonatomic) CLLocation *location;
@end
