# RDImageViewerController

[![CI Status](http://img.shields.io/travis/Akira Matsuda/RDImageViewerController.svg?style=flat)](https://travis-ci.org/Akira Matsuda/RDImageViewerController)
[![Version](https://img.shields.io/cocoapods/v/RDImageViewerController.svg?style=flat)](http://cocoadocs.org/docsets/RDImageViewerController)
[![License](https://img.shields.io/cocoapods/l/RDImageViewerController.svg?style=flat)](http://cocoadocs.org/docsets/RDImageViewerController)
[![Platform](https://img.shields.io/cocoapods/p/RDImageViewerController.svg?style=flat)](http://cocoadocs.org/docsets/RDImageViewerController)

![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/1.png)
![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/2.png)

## Requirements

- Runs on iOS 7.0 or later.

## Installation

RDImageViewerController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "RDImageViewerController"

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Initialize RDImageViewerController with number of images and image handler.

	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithImageHandler:^UIImage *(NSInteger pageIndex) {
		NSString *imageName = [NSString stringWithFormat:@"%ld.JPG", (long)pageIndex + 1];
		return [UIImage imageNamed:imageName];
	} numberOfImage:10];

or

	RDImageViewerController *viewController = [[RDImageViewerController alloc] initWithAsynchronousImageHandler:^(RDImageScrollView *imageView, NSInteger pageIndex) {
		// set image in another thread(not main thread)
	} numberOfImages:array.count];

You can set the number of preloading images like this.

	RDImageViewerController *viewController = ...
	viewController.preloadCount = 2;

![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/3.png)
![](https://raw.githubusercontent.com/0x0c/RDImageViewerController/master/Example/Screenshot/4.png)

The image view will be reused when scrolled.

## Author

Akira Matsuda, akira.m.itachi@gmail.com

## License

RDImageViewerController is available under the MIT license. See the LICENSE file for more info.

