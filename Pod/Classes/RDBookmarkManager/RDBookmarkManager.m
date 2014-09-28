//
//  RDBookmarkManager.m
//
//  Created by Akira Matsuda on 2014/04/28.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import "RDBookmarkManager.h"

@implementation RDBookmarkItem

+ (instancetype)bookmarkItemWithIdentifier:(NSString *)identifier pageIndex:(NSInteger)page
{
	__autoreleasing RDBookmarkItem *item = [[[self  class] alloc] initWithIdentifier:identifier pageIndex:page];
	
	return item;
}

- (instancetype)initWithIdentifier:(NSString *)identifier pageIndex:(NSInteger)page
{
	self = [super init];
	if (self) {
		_identifier = [identifier copy];
		_pageIndex = page;
	}
	
	return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	if (self) {
		_identifier = [aDecoder decodeObjectForKey:@"identifier"];
		_pageIndex = [aDecoder decodeIntegerForKey:@"page"];
	}
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:_identifier forKey:@"identifier"];
	[aCoder encodeInteger:_pageIndex forKey:@"page"];
}

- (id)copyWithZone:(NSZone *)zone
{
	RDBookmarkItem *copy = [[[self class] allocWithZone:zone] initWithIdentifier:self.identifier pageIndex:self.pageIndex];
	return copy;
}

@end

@implementation RDBookmarkManager

static const NSString *RDBookmarkManagerKey = @"RDBookmarkManagerKey";

+ (NSArray *)bookmarks
{
	NSMutableOrderedSet *set = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]? [[NSMutableOrderedSet alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]] :[NSMutableOrderedSet new];
	return [set array];
}

+ (void)addBookmarkWithIdentifier:(NSString *)identifier pageIndex:(NSInteger)page
{
	[self addBookmarkWithItem:[RDBookmarkItem bookmarkItemWithIdentifier:identifier pageIndex:page]];
}

+ (void)addBookmarkWithItem:(RDBookmarkItem *)item;
{
	NSMutableOrderedSet *set = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]? [[NSMutableOrderedSet alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]] :[NSMutableOrderedSet new];
	NSArray *array = [set array];
	for (RDBookmarkItem *bookmark in array) {
		if ([bookmark.identifier isEqualToString:item.identifier]) {
			[set removeObject:item];
			break;
		}
	}
	[set addObject:item];
	[[NSUserDefaults standardUserDefaults] setObject:[set array] forKey:(NSString *)RDBookmarkManagerKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)removeBookmarkWithIdentifier:(NSString *)identifier
{
	NSMutableOrderedSet *set = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]? [[NSMutableOrderedSet alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]] :[NSMutableOrderedSet new];
	NSArray *array = [set array];
	for (RDBookmarkItem *item in array) {
		if ([item.identifier isEqualToString:identifier]) {
			[set removeObject:item];
			break;
		}
	}
	[[NSUserDefaults standardUserDefaults] setObject:[set array] forKey:(NSString *)RDBookmarkManagerKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (RDBookmarkItem *)getBookmarkIndexWithIdentifier:(NSString *)identifier
{
	NSMutableOrderedSet *set = [[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]? [[NSMutableOrderedSet alloc] initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:(NSString *)RDBookmarkManagerKey]] :[NSMutableOrderedSet new];
	NSArray *array = [set array];
	RDBookmarkItem *info = nil;
	for (RDBookmarkItem *item in array) {
		if ([item.identifier isEqualToString:identifier]) {
			info = item;
			break;
		}
	}
	return info;
}

@end
