//
//  LoginViewController.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"


@interface LoginViewController () <GoogleLoginManagerDelegate, GIDSignInUIDelegate>
@property (weak, nonatomic)  UIButton *googleSignInBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [GoogleLoginManager sharedLoginManager].delegate=self;
    [GIDSignIn sharedInstance].uiDelegate = self;
   
    
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
//                UIWindow *window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
                
//                [self.navigationController popToViewController:rootViewController animated:YES];
                
                
                [self.navigationController pushViewController:rootViewController animated:YES];
            
//                [window makeKeyAndVisible];
            }else{
                //Alert Invalid credentials
                
                
                
            }
            
        }];
    
    NSLog(@"error");
    
}
- (void)didLogout{
    NSLog(@"error");
}
- (void)didDisconnect{
    
    NSLog(@"error");
    
}
- (void)didFailWithError:(NSError*)error{
    NSLog(@"%@",error);
    
}


-(void)authenticateUser:(NSString *)idToken withCompletionHandler:(void (^)(bool isLoginSuccessfull, NSString* error))completionHandler{
    
    completionHandler(true,nil);
    
    //check token with the server
    
//    NSString *signinEndpoint = @"https://localhost:8080/tokensignin/";
//
//
//
//
//
//    //    NSLog(@"%d",[self checkTokenExpired:idToken]);
//
//
//
//
//
//    //NOTE: We don't have to send clientID to the server. It should be already present at the server.
//    //See comment: http://stackoverflow.com/questions/37552759/authentication-on-backend-server-from-web-ios-and-android
//    NSDictionary *params = @{@"idtoken": idToken };
//
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:signinEndpoint]];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    [request setHTTPMethod:@"POST"];
//    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
//
//    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//
//    //
//    //    [NSURLConnection sendAsynchronousRequest:request
//    //                                       queue:queue
//    //                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
//    //                               if (error) {
//    //                                   NSLog(@"Error: %@", error.localizedDescription);
//    //                               } else {
//    //                                   NSLog(@"Signed in as %@", data.bytes);
//    //                               }
//    //                           }];
//
//    //
//    //    NSError *error;
//    //
//    //    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    //    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
//    //
//    //    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//    //
//    //        if (error) {
//    //            NSLog(@"Error: %@", error.localizedDescription);
//    //        } else {
//    //            //                    NSLog(@"Signed in as %@", data.bytes);
//    //
//    //            NSError *errorJson=nil;
//    //            NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
//    //            KeychainWrapper *myKeychainWrapper=[KeychainWrapper new];
//    //
//    //
//    //            //        NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[responseDict valueForKey:@"access_token"],@"access_token",[responseDict valueForKey:@"refresh_token"],@"refresh_token", nil];
//    //
//    //            //        [myKeychainWrapper mySetObject:[responseDict valueForKey:@"access_token"] forKey:(id)kSecAttrAccount];
//    //            NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:responseDict];
//    //            [dic setValue:idToken forKey:@"idtoken"];
//    //
//    //            //        NSLog(@"%@",[myKeychainWrapper myObjectForKey:(id)kSecAttrAccount]);
//    //            NSData * encodedData = [NSKeyedArchiver archivedDataWithRootObject:dic];
//    //            NSString *base64Encoded = [encodedData base64EncodedStringWithOptions:0];
//    //
//    //            [myKeychainWrapper mySetObject:base64Encoded forKey:(id)kSecValueData ];
//    //            [myKeychainWrapper writeToKeychain];
//    //
//    //            NSLog(@"responseDict=%@",responseDict);
//    //        }
//    //        //        NSLog(@"%@",data);
//    //
//    //
//    //
//    //
//    //
//    //    }];
//
//
//    NSURLSessionDataTask *postDataTask =[[DefaultSessionManager sharedManager] dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//
//
//        if (error) {
//            NSLog(@"Error: %@", error.localizedDescription);
//        } else {
//            //                    NSLog(@"Signed in as %@", data.bytes);
//
//            NSError *errorJson=nil;
//            //           NSDictionary* responseDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJson];
//            KeychainWrapper *myKeychainWrapper=[KeychainWrapper new];
//
//
//            //        NSMutableDictionary *mutableDict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[responseDict valueForKey:@"access_token"],@"access_token",[responseDict valueForKey:@"refresh_token"],@"refresh_token", nil];
//
//            //        [myKeychainWrapper mySetObject:[responseDict valueForKey:@"access_token"] forKey:(id)kSecAttrAccount];
//            NSMutableDictionary *dic=[[NSMutableDictionary alloc]initWithDictionary:responseObject];
//            [dic setValue:idToken forKey:@"idtoken"];
//
//            //        NSLog(@"%@",[myKeychainWrapper myObjectForKey:(id)kSecAttrAccount]);
//            NSData * encodedData = [NSKeyedArchiver archivedDataWithRootObject:dic];
//            NSString *base64Encoded = [encodedData base64EncodedStringWithOptions:0];
//
//            [myKeychainWrapper mySetObject:base64Encoded forKey:(id)kSecValueData ];
//            [myKeychainWrapper writeToKeychain];
//
//            //           NSLog(@"responseDict=%@",responseDict);
//        }
//        //        NSLog(@"%@",data);
//
//
//
//    }];
//
//    [postDataTask resume];
//
//
//
    
}













@end
