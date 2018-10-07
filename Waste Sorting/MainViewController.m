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

@interface MainViewController ()<QBImagePickerControllerDelegate>
@property (strong, nonatomic) UIImage *image;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)uploadPhotoToServer:(id)sender {
    
    if(self.image){
        
        [[ServerCommunication   alloc] uploadImage:self.image];
    }
        
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showCamera:(id)sender {
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"CaptureImage"
                                                             bundle: nil];
    
    //    [self.navigationController setNavigationBarHidden:YES];
    //    [self.navigationController setToolbarHidden:YES animated:YES];
    
    CameraViewController *controller = (CameraViewController*)[mainStoryboard
                                                               instantiateViewControllerWithIdentifier:@"CameraViewController"];
    
    
    //    controller.hidesBottomBarWhenPushed=YES;
    
    [self.navigationController showViewController:controller sender:nil];
    
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
                        weakSelf.image= image;
                          });
                            
                        }];

    }];
    
  
    
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
  
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
