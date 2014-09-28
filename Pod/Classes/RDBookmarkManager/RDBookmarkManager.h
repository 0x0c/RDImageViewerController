//
//  RDBookmarkManager.h
//
//  Created by Akira Matsuda on 2014/04/28.
//  Copyright (c) 2014年 Akira Matsuda. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger InvalidIndex = -2;

@interface RDBookmarkItem : NSObject <NSCoding, NSCopying>

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSInteger pageIndex;

+ (instancetype)bookmarkItemWithIdentifier:(NSString *)identifier pageIndex:(NSInteger)page;
- (instancetype)initWithIdentifier:(NSString *)identifier pageIndex:(NSInteger)page;

@end

@interface RDBookmarkManager : NSObject

+ (NSArray *)bookmarks;
+ (void)addBookmarkWithIdentifier:(NSString *)identifier pageIndex:(NSInteger)page;
+ (void)addBookmarkWithItem:(RDBookmarkItem *)item;
+ (void)removeBookmarkWithIdentifier:(NSString *)identifier;
+ (RDBookmarkItem *)getBookmarkIndexWithIdentifier:(NSString *)identifier;

@end
