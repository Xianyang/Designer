//
//  ArticleManager.h
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/12.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "ArticleInList.h"
#import "XYArticleList.h"

@interface ArticleManager : NSObject

- (NSArray *)getArticles;
- (void)removeAllArticles;
- (void)addArticle:(XYArticleList *)articleInList;

- (void)saveImage:(UIImage*)image filename:(NSString*)filename;
- (UIImage*)getImage:(NSString*)filename;

@end
