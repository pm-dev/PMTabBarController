//
//  PMViewController.m
//  PMRotatingPrismContainer-iOSExample
//
//  Created by Peter Meyers on 3/23/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMViewController.h"

@interface PMViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageView.image = self.image;
}

- (void) setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

@end
