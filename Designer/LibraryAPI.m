//
//  LibraryAPI.m
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/12.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "LibraryAPI.h"
#import "ArticleManager.h"
#import "TopImageManager.h"
#import "HTTPClient.h"
#import "TopImage.h"

@interface LibraryAPI()

@property (strong, nonatomic) NSMutableArray *articleManagers;
@property (strong, nonatomic) TopImageManager *topImageManager;
@property (strong, nonatomic) HTTPClient *httpClient;

@end

@implementation LibraryAPI

+ (LibraryAPI *)sharedInstance
{
    // 1
    static LibraryAPI *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        self.articleManagers = [[NSMutableArray alloc] initWithObjects:
                                [[ArticleManager alloc] init],
                                [[ArticleManager alloc] init],
                                [[ArticleManager alloc] init],
                                [[ArticleManager alloc] init],
                                [[ArticleManager alloc] init], nil];
        self.topImageManager = [[TopImageManager alloc] init];
        self.httpClient = [[HTTPClient alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadImage:)
                                                     name:@"DownloadImageNotification"
                                                   object:nil];
    }
    
    return self;
}

- (NSArray *)getArticlesInGroup:(int)group
{
    return [self.articleManagers[group] getArticles];
}

- (void)addArticleToGroup:(ArticleInList *)articleInList atIndex:(int)index inGroup:(int)group
{
    [self.articleManagers[group] addArticle:articleInList];
}

#pragma mark - 下载文章列表
- (void)downloadArticleInGroup:(int)group withLoadCount:(int)loadCount
{
    NSDictionary *dic = [self.httpClient downloadArticleInGroup:group withLoadCount:loadCount];
    
    if ([dic[@"list_size"] isEqualToString:@"0"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadAllArticlesFinish"
                                                            object:self
                                                          userInfo:@{@"group":[NSString stringWithFormat:@"%d", group]}];
    } else {
        [self setArticleManagersWithDic:dic inGroup:group withLoadCount:loadCount];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableViewInGroup"
                                                            object:self
                                                          userInfo:@{@"group":[NSString stringWithFormat:@"%d", group]}];
    }
}

- (void)setArticleManagersWithDic:(NSDictionary *)dic inGroup:(int)group withLoadCount:(int)loadCount
{
    NSArray *articles = [self changeDicToArticles:dic];
    
    //分为第一次加载和再次加载
    if (loadCount == 0) {
        [self.articleManagers[group] removeAllArticles];
        
        for (ArticleInList *article in articles) {
            [self.articleManagers[group] addArticle:article];
        }
    } else {
        for (ArticleInList *article in articles) {
            [self.articleManagers[group] addArticle:article];
        }
    }
    
}

- (NSArray *)changeDicToArticles:(NSDictionary *)dic
{
    NSMutableArray *articleInListsArray = [[NSMutableArray alloc] init];
    for (NSDictionary *articleDic in [dic objectForKey:@"list"]) {
        ArticleInList *articleInList = [[ArticleInList alloc] initWithID:[articleDic objectForKey:@"id"]
                                                                   title:[articleDic objectForKey:@"title"]
                                                                imageUrl:[articleDic objectForKey:@"pic"]
                                                               likeCount:[articleDic objectForKey:@"like_count"]
                                                            commentCount:[articleDic objectForKey:@"comment_count"]];
        
        [articleInListsArray addObject:articleInList];
    }
    
    return articleInListsArray;
}

#pragma mark - 获取焦点图

- (NSArray *)getTopImages
{
    return [self.topImageManager getTopImages];
}

- (void)downloadTopImage
{
    NSDictionary *dic = [self.httpClient downloadTopImageURL];
    
    [self setTopImageManagerWithDic:dic];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadScroller"
                                                        object:self
                                                      userInfo:nil];
}

- (void)setTopImageManagerWithDic:(NSDictionary *)dic
{
    NSArray *topImages = [self changeDicToTopImages:dic];
    
    [self.topImageManager setTopImagesWithArray:topImages];
}

- (NSArray *)changeDicToTopImages:(NSDictionary *)dic
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (NSDictionary *topImageDic in dic[@"focus_list"]) {
        TopImage *topImage = [[TopImage alloc] initWithArticleID:topImageDic[@"id"]
                                                           title:topImageDic[@"title"]
                                                        imageUrl:topImageDic[@"pic"]];
        [array addObject:topImage];
    }
    
    return array;
}

#pragma mark - 下载图片
- (void)downloadImage:(NSNotification *)notification
{
    // 1
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *coverUrl = notification.userInfo[@"url"];
    NSInteger group = [notification.userInfo[@"group"] integerValue];
    
    // 2
    imageView.image = [self.articleManagers[group] getImage:[coverUrl lastPathComponent]];
    
    if (imageView.image == nil)
    {
        // 3
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [self.httpClient downloadImage:coverUrl];
            
            // 4
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [self.articleManagers[group] saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }
}

- (void)downloadTenMoreArticles
{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
