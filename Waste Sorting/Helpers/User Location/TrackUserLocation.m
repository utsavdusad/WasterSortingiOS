#import "TrackUserLocation.h"

@implementation TrackUserLocation
@synthesize location;

-(id)init{
    self = [super init];
    if(self){

    self.location=[[CLLocationManager alloc]init];
    // Create the location manager if this object does not already have one.
        if([CLLocationManager locationServicesEnabled]){
        
            [self.location setDelegate:self];
    

            //location manager delegate is our self. we will get error here if dont synthesize location.
            
            [self.location setDesiredAccuracy:kCLLocationAccuracyBest];
            //self.location.desiredAccuracy=kCLLocationAccuracyBest;
            //k=constant, greater accuracy requires more time and power. Therefore it can be a battery drain because it has to keep sending and receiving constant updates.
    
            
            [self.location requestWhenInUseAuthorization];
            
            [self.location requestAlwaysAuthorization];
            
            
        
            [self.location setDistanceFilter:kCLDistanceFilterNone];
            // Set a movement threshold for new events.
            //distance filter is the property of the core location manager class. and its the minimum distance measured in meteres that the device has to move horizontally before an update event is generated. this means when DistanceFileterNone is used, we will be notified of all movements. and again thats going to eat more battery power but if you want more accuracy and constant updates then this is the property to set.
    
            [self.location startUpdatingLocation];
            //To start updating the location. so that starts the location manager sending and receving information based on movement. and this will use above assoined properties for desired accuracy and distance filter settings. when it receives information it notifies the delegate. and it is going to call some other methods(as you can see below: locationManager:didUpdateLocation is called when updation of location is done).
            
            
            
            
        }
        
        
        
        
    }
    return self;

}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"Location services are off" : @"Background location is not enabled";
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.location requestAlwaysAuthorization];
    }
}



//This method is called automatically when there is error in updating location.
//Error in updation can be due to: Network related error or user denied the to use current location
- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

    
    //check why we are not able to update location.
    switch ([error code]) {
        case kCLErrorNetwork:
            NSLog(@"Check your network connection or that you are not in airplane mode");
            break;
        case kCLErrorDenied:
            NSLog(@"User has denied to use current location");
            break;
            
        default:
            NSLog(@"Unknown network error");
            break;
    }

    
  }

@end
