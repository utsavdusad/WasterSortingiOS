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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)didLogin{
    
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain] ){
        
        
        GIDGoogleUserInfo *user = [[GoogleLoginManager sharedLoginManager] loggedUser];
        NSString *fullName = user.user.profile.name;
        NSString *givenName = user.user.profile.givenName;
        NSString *familyName = user.user.profile.familyName;
        NSString *email = @"utsavdusad@gmail.com";//user.profile.email;
        
        NSString *idToken=user.user.authentication.idToken;
        if(idToken)
            [self authenticateUser:idToken withCompletionHandler:^(bool isLoginSuccessfull, NSString *error    ) {
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
        
        NSLog(@"error");
       
        
    }else if ([FBSDKAccessToken currentAccessToken]){
        
           [self showCustomCamera];
        
    }
    
    
    
}
- (void)didLogout{
    NSLog(@"error");
    //    UIAlertController * alert = [UIAlertController
    //                                 alertControllerWithTitle:@"Important"
    //                                 message:@"Login Not successful"
    //                                 preferredStyle:UIAlertControllerStyleAlert];
    //
    //    //Add Buttons
    //
    //    UIAlertAction* okButton = [UIAlertAction
    //                                actionWithTitle:@"ok"
    //                                style:UIAlertActionStyleDefault
    //                                handler:^(UIAlertAction * action) {
    //                                    //Handle your yes please button action here
    //
    //                                }];
    //
    //
    //    //Add your buttons to alert controller
    //
    //    [alert addAction:okButton];
    //
    //
    //    [self presentViewController:alert animated:YES completion:nil];
    
}
- (void)didDisconnect{
    
//    [self.navigationController popToViewController:self animated:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    
    
    
}
- (void)didFailWithError:(NSError*)error{
    NSLog(@"%@",error);
    
}


-(void)authenticateUser:(NSString *)idToken withCompletionHandler:(void (^)(bool isLoginSuccessfull, NSString *error))completionHandler{
    
    [[ServerCommunication   alloc] signInWithCompletion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error){
            completionHandler(true,nil);
        }else{
            
            completionHandler(true,[error localizedDescription]);
        }
        
    }];
    
    
    //check token with the server
}









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


- (void)showNoCameraError
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device doesn't have a camera" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
