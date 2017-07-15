//
//  RDViewPageContentData.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import "RDViewPageContentData.h"

@implementation RDViewPageContentData

- (instancetype)initWithString:(NSString *)string
{
	self = [super init];
	if (self) {
		self.labelString = string;
	}
	
	return self;
}

#pragma mark -

- (UIView * _Nonnull)contentViewWithFrame:(CGRect)frame
{
	UIView *view = [[UIView alloc] initWithFrame:frame];
	UILabel *label = [[UILabel alloc] initWithFrame:frame];
	label.textAlignment = NSTextAlignmentCenter;
	label.font = [UIFont systemFontOfSize:50];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	label.tag = 100;
	[view addSubview:label];
	view.backgroundColor = [UIColor whiteColor];

	return view;
}

- (void)preload
{
	
}

- (void)reload
{
	
}

- (void)stopPreloading
{
	
}

- (void)configureForView:(UIView * _Nonnull)view
{
	UILabel *label = (UILabel *)[view viewWithTag:100];
	label.text = self.labelString;
}

@end
