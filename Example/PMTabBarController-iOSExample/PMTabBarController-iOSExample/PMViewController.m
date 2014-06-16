//
//  PMViewController.m
//  PMTabBarController-iOSExample
//
//  Created by Peter Meyers on 3/23/14.
//  Copyright (c) 2014 Peter Meyers. All rights reserved.
//

#import "PMViewController.h"

static CGFloat const TitleFontSize = 18.0f;
static CGFloat const TitleTextColor = 181.0f/255.0f;
static NSString * const TitleFontName = @"HelveticaNeue-Light";

@interface PMViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation PMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView.image = self.image;
}

- (void) setImage:(UIImage *)image
{
    _image = image;
    self.imageView.image = image;
}

- (void) setTitle:(NSString *)title
{
	[super setTitle:title];
	self.titleLabel.text = title;
}

- (UILabel *) titleLabel
{
	if (!_titleLabel) {
		_titleLabel = [UILabel new];
		_titleLabel.text = self.title;
		_titleLabel.font = [UIFont fontWithName:TitleFontName size:TitleFontSize];
		_titleLabel.textColor = [UIColor colorWithWhite:TitleTextColor alpha:1.0];
		[_titleLabel sizeToFit];
	}
    return _titleLabel;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.titleLabel.textColor = [UIColor whiteColor];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];    
    self.titleLabel.textColor = [UIColor colorWithWhite:TitleTextColor alpha:1.0];
}

@end
