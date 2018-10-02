//
//  ViewController.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 9/22/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "ViewController.h"
#import "QBImagePickerController.h"

@interface ViewController ()<QBImagePickerControllerDelegate>
@property (strong, nonatomic) UIImage *image;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    
    __weak ViewController *weakSelf = self;
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
