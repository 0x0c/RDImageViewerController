//
//  RDViewController.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 09/21/2014.
//  Copyright (c) 2014 Akira Matsuda. All rights reserved.
//

#import "RDViewController.h"
#import "RDImageViewerController.h"
#import "RDImageContentData.h"
#import "RDRemoteImageContentData.h"

#import "RDViewPageContentData.h"
#import "RDScrollViewPageContentData.h"

const NSInteger kPreloadCount = 3;
const NSInteger kNumberOfImages = 12;

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
	for (NSInteger i = 1; i <= 12; i++) {
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
	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)i + 1];
		RDImageContentData *data = [[RDImageContentData alloc] initWithImageName:imageName];
		[contentData addObject:data];
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showImageAsDisplayFit:(id)sender
{
	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)i + 1];
		RDImageContentData *data = [[RDImageContentData alloc] initWithImageName:imageName];
		data.landscapeMode = RDImageScrollViewResizeModeDisplayFit;
		[contentData addObject:data];
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showView:(id)sender
{
	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		RDViewPageContentData *data = [[RDViewPageContentData alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)i + 1]];
		[contentData addObject:data];
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showImageAsync:(id)sender
{
	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		RDRemoteImageContentData *data = [[RDRemoteImageContentData alloc] initWithRequest:[NSURLRequest requestWithURL:array[i]] pageIndex:i];
		[contentData addObject:data];
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showImageAndView:(id)sender
{
	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		if (i % 2) {
			RDViewPageContentData *data = [[RDViewPageContentData alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)i + 1]];
			[contentData addObject:data];
		}
		else {
			NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)i + 1];
			RDImageContentData *data = [[RDImageContentData alloc] initWithImageName:imageName];
			data.landscapeMode = RDImageScrollViewResizeModeDisplayFit;
			[contentData addObject:data];
		}
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];
	[viewController setContentViewWillAppearHandler:^(NSInteger index, UIView *view) {
		NSLog(@"%ld %@", (long)index, [view description]);
	}];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.loadAsync = YES;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)showScrollView:(id)sender
{
	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		RDScrollViewPageContentData *data = [[RDScrollViewPageContentData alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)i + 1]];
		[contentData addObject:data];
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];
	viewController.showSlider = sliderSwitch.on;
	viewController.showPageNumberHud = hudSwitch.on;
	viewController.loadAsync = YES;
	viewController.preloadCount = kPreloadCount;
	viewController.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:viewController animated:YES];
}
#pragma mark -

@end
