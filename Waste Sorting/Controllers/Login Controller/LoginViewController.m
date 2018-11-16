//
//  LoginViewController.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "LoginViewController.h"
#import "ServerCommunication.h"
#import "CameraViewController.h"


@interface LoginViewController () <GoogleLoginManagerDelegate, GIDSignInUIDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [GoogleLoginManager sharedLoginManager].delegate=self;
    [GIDSignIn sharedInstance].uiDelegate = self;
    
    
    //    [[GIDSignIn sharedInstance] signInSilently];
    
    
    //    [[[[GIDSignIn sharedInstance] currentUser] authentication] accessToken]
    
    [[GoogleLoginManager sharedLoginManager] tryLoginWithDelegateAndSetDelegates:self forButton:self.fbLoginButton];
//    if ([[GIDSignIn sharedInstance] hasAuthInKeychain] ){
//        [[GoogleLoginManager sharedLoginManager] tryLoginWith:self];
//        //        [[GIDSignIn sharedInstance] signInSilently];
//    }else if ([FBSDKAccessToken currentAccessToken]){
//        [self showCustomCamera];
//    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signIn:(id)sender {
    //1
//    [[GoogleLoginManager sharedLoginManager] tryLoginWith:self];
        [[GoogleLoginManager sharedLoginManager] tryLoginWithDelegateAndSetDelegates:self forButton:self.fbLoginButton];
}
- (IBAction)fbLogin:(id)sender {
    
    [[GoogleLoginManager sharedLoginManager] tryLoginWithDelegateAndSetDelegates:self forButton:self.fbLoginButton];
}



//Called when the login for FB/Google is done by their respective server then we get a callback in the callback function we call didLogin()
- (void)didLogin{
    
    
    [self authenticateUserWithCompletionHandler:^(bool isLoginSuccessfull, NSString *error    ) {
        if (isLoginSuccessfull){
            //Show main window
            
            [self showCustomCamera];
            
        }else{
            //Alert Invalid credential
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"SignIn Failed"
                                         message:error
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            //Add Buttons
            
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:@"ok"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           //Handle your yes please button action here
                                           
                                       }];
            
            
            //Add your buttons to alert controller
            
            [alert addAction:okButton];
            
            
            [self presentViewController:alert animated:YES completion:nil];
            
            
            
        }
        
    }];

}
- (void)didLogout{
    NSLog(@"error");
}
//Called when the logout is done by google/FB respective server. This is called by the callback method in GoogleLoginManager
- (void)didDisconnect{
    
//    [self.navigationController popToViewController:self animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    
    
}
- (void)didFailWithError:(NSError*)error{
    NSLog(@"%@",error);
    
}

//This method sends google/FB token to our custom server where the server authenticates the user. Upon successfull authentication the user is allowed to login the application.
-(void)authenticateUserWithCompletionHandler:(void (^)(bool isLoginSuccessfull, NSString *error))completionHandler{
    
    [[ServerCommunication   alloc] signInWithCompletion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error){
            completionHandler(true,nil);
        }else{
            
            completionHandler(false,[error localizedDescription]);
        }
        
    }];
    
    
    //check token with the server
}








//Used to show custom camera view
- (void)showCamera {

    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    //    picker.showsCameraControls = NO;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    //    self.overlay = [[OverlayViewController alloc] initWithNibName:@"Overlay" bundle:nil];
    //    self.overlay.pickerReference = self.picker;
    //
    //    self.picker.cameraOverlayView = self.overlay.view;
    //    self.picker.delegate = self.overlay;
    
    [self presentViewController:picker animated:YES completion:NULL];
    
}

//Allow user to select image frome the Photos app.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];
    //   UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    //    dispatch_async(dispatch_get_main_queue(), ^{
    //        self.imageView.image = image;
    //        self.image=image;
    //    });
    
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


//Used to show custom camera.
- (void)showCustomCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self showNoCameraError];
        return;
    }
    
    CameraViewController *cameraViewController = [[CameraViewController alloc] init];
    NSLog(@"%@",[self.navigationController viewControllers]);
    
    [self.navigationController pushViewController:cameraViewController animated:YES];
    
//    [self.navigationController presentViewController:cameraViewController animated:YES completion:^{
//        NSLog(@"%@",[self.navigationController viewControllers]);
//    }];
}

//In simulator camera is not available so we need to handle the error.
- (void)showNoCameraError
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device doesn't have a camera" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
