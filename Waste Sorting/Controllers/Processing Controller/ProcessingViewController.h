//
//  ProcessingViewController.h
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/19/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcessingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *progressPercentage;


@end
