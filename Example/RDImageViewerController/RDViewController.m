//
//  RDViewController.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 09/21/2014.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDViewController.h"
#import "RDImageViewerController.h"

@interface RDViewController ()
{
	NSMutableArray *array;
}

@end

@implementation RDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	array = [NSMutableArray new];
	for (NSInteger i = 1; i <= 10; i++) {
		[array addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/%ld.JPG", i]]];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)showImageViewController:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)pageIndex + 1];
		return [UIImage imageNamed:imageName];
	} numberOfImage:10];
	viewController.preloadCount = 2;
	UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationViewController animated:YES completion:^{
	}];
}


- (IBAction)showAsyncImageViewController:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithAsynchronousImageHandler:^(RDImageScrollView *imageView, NSInteger pageIndex) {
		__block __weak RDImageScrollView *bimageView = imageView;
		[NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:array[pageIndex]] queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
			UIImage *image = [UIImage imageWithData:data];
			if (image == nil) {
				NSLog(@"error:%@", response.URL.absoluteString);
			}
			else {
				NSLog(@"done:%@", response.URL.absoluteString);
				dispatch_async(dispatch_get_main_queue(), ^{
					bimageView.image = image;
				});
			}
		}];
	} numberOfImage:array.count];
	UINavigationController *navigationViewController = [[UINavigationController alloc] initWithRootViewController:viewController];
	[self presentViewController:navigationViewController animated:YES completion:^{
	}];
}

#pragma mark -

@end
