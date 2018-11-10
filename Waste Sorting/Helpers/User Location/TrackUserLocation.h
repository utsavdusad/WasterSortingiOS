
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>




//This class is used to get current location of the user.
@interface TrackUserLocation : NSObject <CLLocationManagerDelegate>


@property (strong,nonatomic)  CLLocationManager *location;

@end
