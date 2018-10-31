//
//  LoginViewController.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "ServerCommunication.h"


@interface LoginViewController () <GoogleLoginManagerDelegate, GIDSignInUIDelegate>
@property (weak, nonatomic)  UIButton *googleSignInBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [GoogleLoginManager sharedLoginManager].delegate=self;
    [GIDSignIn sharedInstance].uiDelegate = self;
   
//    [[GIDSignIn sharedInstance] signInSilently];
    
 
//    [[[[GIDSignIn sharedInstance] currentUser] authentication] accessToken]
    
    if ([[GIDSignIn sharedInstance] hasAuthInKeychain] ){
        [[GoogleLoginManager sharedLoginManager] tryLoginWith:self];
//        [[GIDSignIn sharedInstance] signInSilently];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)signIn:(id)sender {
    //1
      [[GoogleLoginManager sharedLoginManager] tryLoginWith:self];
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
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                        MainViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];

                            
                [self.navigationController pushViewController:rootViewController animated:YES];
            
//                [window makeKeyAndVisible];
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
    
}
- (void)didLogout{
    NSLog(@"error");
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Important"
                                 message:@"Login Not successful"
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
- (void)didDisconnect{

    [self.navigationController popToViewController:self animated:YES];
 
    
}
- (void)didFailWithError:(NSError*)error{
    NSLog(@"%@",error);
    
}


-(void)authenticateUser:(NSString *)idToken withCompletionHandler:(void (^)(bool isLoginSuccessfull, NSString* error))completionHandler{
    
    [[ServerCommunication   alloc] signInWithCompletion:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (!error){
            completionHandler(true,nil);
        }else{
          
             completionHandler(true,[error localizedDescription]);
        }
            
    }];
    
    
    //check token with the server
}













@end
