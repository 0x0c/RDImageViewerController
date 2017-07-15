//
//  RDPageContentData.m
//  RDImageViewerController
//
//  Created by Akira Matsuda on 9/18/16.
//  Copyright © 2016 Akira Matsuda. All rights reserved.
//

#import "RDPageContentData.h"

@implementation RDPageContentData

- (void)preload
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"You have to override this method." userInfo:nil];
}

- (void)reload
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"You have to override this method." userInfo:nil];
}

- (void)stopPreloading
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"You have to override this method." userInfo:nil];
}

- (void)configureForView:(UIView * _Nonnull)view
{
	@throw [NSException exceptionWithName:NSGenericException reason:@"You have to override this method." userInfo:nil];
}

- (BOOL)preloadable
{
	return YES;
}

@end
