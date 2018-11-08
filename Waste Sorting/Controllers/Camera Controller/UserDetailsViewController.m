//
//  UserDetailsViewController.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 11/6/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "UserDetailsViewController.h"
#import "GoogleLoginManager.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface UserDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageview;
@property (weak, nonatomic) IBOutlet UILabel *Username;

@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;


@end

@implementation UserDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.imageview.layer.cornerRadius = 25;
    
    self.imageview.layer.masksToBounds = YES;
    // Do any additional setup after loading the view.
//    GIDGoogleUserInfo  *user=[[GoogleLoginManager sharedLoginManager] loggedUser];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.Username.text=[defaults objectForKey:@"name"];
    });
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[defaults objectForKey:@"picture"]]];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            // WARNING: is the cell still using the same data by this point??
            self.imageview.image = [UIImage imageWithData: data];
        });
      
    });
    

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)logout:(id)sender {
    
    
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain] ){
            [[GoogleLoginManager sharedLoginManager] tryLogout];
        
    }else if ([FBSDKAccessToken currentAccessToken]){
        
        [[GoogleLoginManager sharedLoginManager] fbLogout];
    }
}

@end
