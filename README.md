# RDImageViewerController

Simple image or custom view viewer.

[![CI Status](http://img.shields.io/travis/Akira Matsuda/RDImageViewerController.svg?style=flat)](https://travis-ci.org/Akira Matsuda/RDImageViewerController)
[![Version](https://img.shields.io/cocoapods/v/RDImageViewerController.svg?style=flat)](http://cocoadocs.org/docsets/RDImageViewerController)
[![License](https://img.shields.io/cocoapods/l/RDImageViewerController.svg?style=flat)](http://cocoadocs.org/docsets/RDImageViewerController)
[![Platform](https://img.shields.io/cocoapods/p/RDImageViewerController.svg?style=flat)](http://cocoadocs.org/docsets/RDImageViewerController)

![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/1.png)
![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/2.png)
![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/view_and_image.png)

## Requirements
- Runs on iOS 8.0 or later.


## Installation

RDImageViewerController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "RDImageViewerController"

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Initialize RDImageViewerController with page data.

	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)i + 1];
		RDImageContentData *data = [[RDImageContentData alloc] initWithImageName:imageName];
		[contentData addObject:data];
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];

You can show a custom view like this (See `RDScrollViewPageContentData` class).

	NSMutableArray <RDPageContentData *> *contentData = [NSMutableArray new];
	for (NSInteger i = 0; i < kNumberOfImages; i++) {
		RDScrollViewPageContentData *data = [[RDScrollViewPageContentData alloc] initWithString:[NSString stringWithFormat:@"%ld", (long)i + 1]];
		[contentData addObject:data];
	}
	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithContentData:contentData direction:self.directionSwitch.on ? RDPagingViewForwardDirectionLeft : RDPagingViewForwardDirectionRight];

To create own page, inherit the `RDPageContentData` class and implement `RDPageContentDataDelegate` methods.

Please check the sample code to know how to use.

The property of 'landscapeMode' is meaning zooming style in landscape.
If it is setted RDImageViewerControllerLandscapeModeAspectFit
![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/aspect.png)

The other side it is setted RDImageViewerControllerLandscapeModeDisplayFit
![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/display.png)

You can set the number of preloading images like this.

	RDImageViewerController *viewController = ...
	viewController.preloadCount = 2;

![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/3.png)
![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/4.png)

The view will be reused when scrolled.

## Author

Akira Matsuda, akira.m.itachi@gmail.com

## License

RDImageViewerController is available under the MIT license. See the LICENSE file for more info.

