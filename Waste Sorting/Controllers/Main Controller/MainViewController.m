//
//  ViewController.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 9/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "MainViewController.h"
#import "QBImagePickerController.h"
#import "ServerCommunication.h"
#import "CameraViewController.h"
#import "GoogleLoginManager.h"
#import "LoginViewController.h"

@interface MainViewController ()<QBImagePickerControllerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (strong, nonatomic) PHAsset *asset;
@property (strong, nonatomic) UIImage *image;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationItem setHidesBackButton:YES animated:YES];
}
- (IBAction)uploadPhotoToServer:(id)sender {
    
    if(self.asset){
        
        [[ServerCommunication   alloc] testUploadAsset:self.asset];
    }else if (self.image){
        [[ServerCommunication   alloc] testUploadImage:self.image];
       
    }
        
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showCamera:(id)sender {
    
//    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"CaptureImage"
//                                                             bundle: nil];
//
//    //    [self.navigationController setNavigationBarHidden:YES];
//    //    [self.navigationController setToolbarHidden:YES animated:YES];
//
//    CameraViewController *controller = (CameraViewController*)[mainStoryboard
//                                                               instantiateViewControllerWithIdentifier:@"CameraViewController"];
//
//
//    //    controller.hidesBottomBarWhenPushed=YES;
//
//    [self.navigationController showViewController:controller sender:nil];
//    [self showCustomCamera];
    
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//
//    [self presentViewController:picker animated:YES completion:NULL];
    
}   

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
      [self dismissViewControllerAnimated:YES completion:NULL];
//   UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = image;
        self.image=image;
    });
    
}
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker{
   [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)selectPhoto:(id)sender {
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.mediaType = QBImagePickerMediaTypeImage;
    imagePickerController.allowsMultipleSelection = 1;
    imagePickerController.showsNumberOfSelectedAssets = YES;
    imagePickerController.prompt = @"Select the photo you want to add!";
    imagePickerController.maximumNumberOfSelection = 1;
    [self presentViewController:imagePickerController animated:YES completion:nil];
    
}


#pragma mark - QBImagePickerControllerDelegate
//******************************************
//Description: This method is called when the user is done selecting of images.
- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    
    __weak MainViewController *weakSelf = self;
    [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset=(PHAsset *)obj;
        weakSelf.asset=asset;
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc] init];
        requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        requestOptions.synchronous = YES;
        
        PHImageManager *manager = [PHImageManager defaultManager];
        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.imageView.image = image;
                          });
                            
                        }];

    }];
    
  
    
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


- (IBAction)logout:(id)sender {

    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Important"
                                 message:@"Do you want to logout?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    //Add Buttons
    
    UIAlertAction* yesButton = [UIAlertAction
                               actionWithTitle:@"Yes"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   //Handle your yes please button action here
                                    [[GoogleLoginManager sharedLoginManager] tryLogout];
                                   
                               }];
    
    UIAlertAction* noButton = [UIAlertAction
                                actionWithTitle:@"No"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                    
                                }];
    
    //Add your buttons to alert controller
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];

}



//- (void)showCustomCamera
//{
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        [self showNoCameraError];
//        return;
//    }
//    
//    CameraViewController *cameraViewController = [[CameraViewController alloc] init];
//    [self presentViewController:cameraViewController animated:YES completion:nil];
//}
//
//
//- (void)showNoCameraError
//{
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device doesn't have a camera" preferredStyle:UIAlertControllerStyleAlert];
//    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//    [self presentViewController:alertController animated:YES completion:nil];
//}


@end
