//
//  ProcessingViewController.h
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/19/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import <UIKit/UIKit.h>
/*
 This class is used to show the upload progress of the image. We also show the upload progress in percentage.
 */

@interface ProcessingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressPercentage;


@end
