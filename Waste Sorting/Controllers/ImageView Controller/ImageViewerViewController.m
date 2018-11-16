#import "ImageViewerViewController.h"


@interface ImageViewerViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;
@end


@implementation ImageViewerViewController


- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.imageView.image = self.image;
}


@end
