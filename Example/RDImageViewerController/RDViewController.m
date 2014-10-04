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
		[array addObject:[NSURL URLWithString:[NSString stringWithFormat:@"https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Images/%ld.JPG", (long)i]]];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (IBAction)showImageViewControllerAspectFit:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)pageIndex + 1];
		return [UIImage imageNamed:imageName];
	} numberOfImages:10 direction:RDPagingViewDirectionRight];
	viewController.landscapeMode = RDImageViewControllerLandscapeModeAspectFit;
	viewController.preloadCount = 1;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showImageViewControllerDisplayFit:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)pageIndex + 1];
		return [UIImage imageNamed:imageName];
	} numberOfImages:10 direction:RDPagingViewDirectionRight];
	viewController.landscapeMode = RDImageViewControllerLandscapeModeDisplayFit;
	viewController.preloadCount = 1;
	[self.navigationController pushViewController:viewController animated:YES];
}


- (IBAction)showAsyncImageViewController:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSLog(@"downloading...:%@", [array[pageIndex] absoluteString]);
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:array[pageIndex]] returningResponse:&response error:&error];
		UIImage *image = [UIImage imageWithData:data];
		if (image == nil) {
			NSLog(@"error:%@", response.URL.absoluteString);
		}
		else {
			NSLog(@"done:%@", response.URL.absoluteString);
		}
		
		return image;
	} numberOfImages:10 direction:RDPagingViewDirectionRight];
	viewController.landscapeMode = RDImageViewControllerLandscapeModeAspectFit;
	viewController.loadAsync = YES;
	viewController.preloadCount = 1;
	[self.navigationController pushViewController:viewController animated:YES];

}

#pragma mark -

@end
