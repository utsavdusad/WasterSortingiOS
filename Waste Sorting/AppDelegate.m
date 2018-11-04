//
//  AppDelegate.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 9/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "LoginViewController.h"
#import "Constants.h"
#import "GoogleLoginManager.h"
@import GoogleSignIn;

@interface AppDelegate () <UIApplicationDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [AFNetworkActivityIndicatorManager sharedManager].enabled =YES;
    [AFNetworkActivityIndicatorManager sharedManager].activationDelay =0;
    [GIDSignIn sharedInstance].clientID = CLIENT_ID;
    
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle: nil];
    LoginViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginNavId"];
    self.window.rootViewController = rootViewController;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

-(BOOL)checkIfLoginKeyAvailable{
    return true;
    //    return  [[NSUserDefaults standardUserDefaults] boolForKey:@"hasCameraLoginKey"];
    
//    KeychainItemWrapper* keychain = [[KeychainItemWrapper alloc] initWithIdentifier:kCameraAppIdentifier accessGroup:nil];
//    //    [keychain setObject:email forKey:(id)kSecAttrService];
//    NSString* username = [keychain objectForKey:(id)kSecAttrAccount];
//    NSString* password = [keychain objectForKey:(id)kSecValueData];
//
//
//    if(![password isEqualToString:@""]){
//        return true;
//    }else{
//        return false;
//    }
    
    
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)app
            openURL:(NSURL *)url
            options:(NSDictionary<NSString *, id> *)options {

    
    if ([GoogleLoginManager handleURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]]) {
        return [GoogleLoginManager handleURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    return YES;
}


@end
