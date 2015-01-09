//
//  LibraryAPI.h
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/12.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "ArticleInList.h"

@interface LibraryAPI : NSObject

+ (LibraryAPI*)sharedInstance;

- (NSArray *)getArticlesInGroup:(int)group;
- (void)addArticleToGroup:(ArticleInList *)articleInList atIndex:(int)index inGroup:(int)group;

- (NSArray *)getTopImages;
- (void)downloadTopImage;

- (void)downloadArticleInGroup:(int)group withLoadCount:(int)loadCount;
- (void)downloadTenMoreArticles;


@end
