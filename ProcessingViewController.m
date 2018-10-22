//
//  ProcessingViewController.m
//  Waste Sorting
//
//  Created by Utsav Dusad on 10/19/18.
//  Copyright © 2018 Hygiea. All rights reserved.
//

#import "ProcessingViewController.h"

@interface ProcessingViewController ()

@end

@implementation ProcessingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.progressView.progress=0;
    self.progressPercentage.text=@"0.0";
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgress:) name:@"UPLOAD_PROGRESS" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Clique Sync Delete" object:nil];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//-(void)updateProgress:(NSNotification *)notification{
//    
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSDictionary* userInfo = notification.userInfo;
//        double p= [[userInfo valueForKey:@"progress"] doubleValue];
//        self.progressView.progress  = p;
//        self.progressPercentage.text=[NSString stringWithFormat:@"%.2f",p*100];
//    });
//    
//}

@end
