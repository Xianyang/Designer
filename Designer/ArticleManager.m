//
//  ArticleManager.m
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/12.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "ArticleManager.h"

@interface ArticleManager()

@property (strong, nonatomic) NSMutableArray *articles;

@end

@implementation ArticleManager

- (NSArray *)getArticles
{
    if (self.articles) return self.articles;
    else return nil;
}

- (void)removeAllArticles
{
    [self.articles removeAllObjects];
}

- (void)addArticle:(XYArticleList *)articleInList
{
    [self.articles addObject:articleInList];
}

- (void)saveImage:(UIImage*)image filename:(NSString*)filename;
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filename atomically:YES];
}

- (UIImage*)getImage:(NSString*)filename;
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    return [UIImage imageWithData:data];
}

- (NSMutableArray *)articles
{
    if (!_articles) {
        _articles = [[NSMutableArray alloc] init];
    }
    
    return _articles;
}

@end
