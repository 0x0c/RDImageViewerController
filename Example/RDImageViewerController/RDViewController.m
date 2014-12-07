//
//  RDViewController.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 09/21/2014.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDViewController.h"
#import "RDImageViewerController.h"

const NSInteger kPreloadCount = 1;

@interface RDViewController ()
{
	NSMutableArray *array;
	__weak IBOutlet UISwitch *sliderSwitch;
	__weak IBOutlet UISwitch *hudSwitch;
}

@end

@implementation RDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	sliderSwitch.on = NO;
	hudSwitch.on = NO;
	
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController setToolbarHidden:YES animated:YES];
}

#pragma mark -

- (IBAction)showImageAsAspectFit:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)pageIndex + 1];
		return [UIImage imageNamed:imageName];
	} numberOfImages:10 direction:self.directionSwitch.on ? RDPagingViewDirectionLeft : RDPagingViewDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.landscapeMode = RDImageScrollViewResizeModeAspectFit;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showImageAsDisplayFit:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)pageIndex + 1];
		return [UIImage imageNamed:imageName];
	} numberOfImages:10 direction:self.directionSwitch.on ? RDPagingViewDirectionLeft : RDPagingViewDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.landscapeMode = RDImageScrollViewResizeModeDisplayFit;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showView:(id)sender
{
	CGRect frame = self.view.bounds;
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithViewHandler:^UIView *(NSInteger pageIndex, UIView *reusedView) {
		if (reusedView == nil) {
			UIView *view = [[UIView alloc] initWithFrame:frame];
			UILabel *label = [[UILabel alloc] initWithFrame:frame];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [UIFont systemFontOfSize:50];
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.tag = 100;
			[view addSubview:label];
			view.backgroundColor = [UIColor whiteColor];
			reusedView = view;
		}

		UILabel *label = (UILabel *)[reusedView viewWithTag:100];
		label.text = [NSString stringWithFormat:@"%ld", (long)pageIndex];
		
		return reusedView;
	} reuseIdentifier:^NSString *(NSInteger pageIndex) {
		return @"view";
	} numberOfImages:10 direction:self.directionSwitch.on ? RDPagingViewDirectionLeft : RDPagingViewDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.landscapeMode = RDImageScrollViewResizeModeDisplayFit;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showImageAsync:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSLog(@"downloading...:%@", [array[pageIndex] absoluteString]);
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:array[pageIndex]] returningResponse:&response error:&error];
		UIImage *image = [UIImage imageWithData:data];
		if (image == nil) {
			NSLog(@"error:%@", [error localizedDescription]);
		}
		else {
			NSLog(@"done:%@", response.URL.absoluteString);
		}
		
		return image;
	} numberOfImages:10 direction:self.directionSwitch.on ? RDPagingViewDirectionLeft : RDPagingViewDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.landscapeMode = RDImageScrollViewResizeModeAspectFit;
	viewController.loadAsync = YES;
	viewController.preloadCount = kPreloadCount;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showImageAndView:(id)sender
{
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSLog(@"downloading...:%@", [array[pageIndex] absoluteString]);
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:array[pageIndex]] returningResponse:&response error:&error];
		UIImage *image = [UIImage imageWithData:data];
		if (image == nil) {
			NSLog(@"error:%@", [error localizedDescription]);
		}
		else {
			NSLog(@"done:%@", response.URL.absoluteString);
		}
		
		return image;
	} numberOfImages:10 direction:self.directionSwitch.on ? RDPagingViewDirectionLeft : RDPagingViewDirectionRight];
	CGRect frame = self.view.bounds;
	[viewController setViewHandler:^UIView *(NSInteger pageIndex, UIView *reusedView) {
		if (reusedView == nil) {
			UIView *view = [[UIView alloc] initWithFrame:frame];
			UILabel *label = [[UILabel alloc] initWithFrame:frame];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [UIFont systemFontOfSize:50];
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.tag = 100;
			[view addSubview:label];
			view.backgroundColor = [UIColor whiteColor];
			reusedView = view;
		}
		
		UILabel *label = (UILabel *)[reusedView viewWithTag:100];
		label.text = [NSString stringWithFormat:@"%ld", (long)pageIndex];
		
		return reusedView;
	}];
	[viewController setReuseIdentifierHandler:^NSString *(NSInteger index) {
		if (index % 2 == 0) {
			return @"view";
		}
		
		return RDImageViewerControllerReuseIdentifierImage;
	}];
	
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.landscapeMode = RDImageScrollViewResizeModeAspectFit;
	viewController.loadAsync = YES;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showScrollView:(id)sender
{
	CGRect frame = self.view.bounds;
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithViewHandler:^UIView *(NSInteger pageIndex, UIView *reusedView) {
		if (reusedView == nil) {
			UIScrollView *view = [[UIScrollView alloc] initWithFrame:frame];
			UILabel *label = [[UILabel alloc] initWithFrame:frame];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [UIFont systemFontOfSize:50];
			label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			label.tag = 100;
			[view addSubview:label];
			view.backgroundColor = [UIColor whiteColor];
			view.contentSize = CGSizeMake(1000, 1000);
			reusedView = view;
		}
		
		UILabel *label = (UILabel *)[reusedView viewWithTag:100];
		label.text = [NSString stringWithFormat:@"%ld", (long)pageIndex];
		
		return reusedView;
	} reuseIdentifier:^NSString *(NSInteger pageIndex) {
		return @"view";
	} numberOfImages:10 direction:self.directionSwitch.on ? RDPagingViewDirectionLeft : RDPagingViewDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.landscapeMode = RDImageScrollViewResizeModeDisplayFit;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark -

@end
