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
#import "XYHttpClient.h"
#import "XYArticleList.h"
#import "XYArticleListManager.h"

@interface LibraryAPI()

@property (strong, nonatomic) __block NSMutableArray *articleManagers;
@property (strong, nonatomic) TopImageManager *topImageManager;
@property (strong, nonatomic) XYHttpClient *xyHttpClient;

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
        self.xyHttpClient = [[XYHttpClient alloc] init];
        
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

#pragma mark - 下载文章列表
- (void)downloadArticleInGroup:(int)group withLoadCount:(int)loadCount
{
    [self.xyHttpClient downloadArticleInGroup:group
                                withLoadCount:loadCount
                                      success:^(XYArticleListManager *xyArticleListManager) {
                                          //判断文章是否加载完
                                          if ([xyArticleListManager.list_size isEqualToString:@"0"]) {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadAllArticlesFinish"
                                                                                                  object:self
                                                                                                userInfo:@{@"group":[NSString stringWithFormat:@"%d", group]}];
                                          } else {
                                              //分为刷新和加载更多
                                              if (loadCount == 0) {
                                                  [self.articleManagers[group] removeAllArticles];
                                                  for (XYArticleList *article in xyArticleListManager.list) {
                                                      [self.articleManagers[group] addArticle:article];
                                                  }
                                              } else {
                                                  for (XYArticleList *article in xyArticleListManager.list) {
                                                      [self.articleManagers[group] addArticle:article];
                                                  }
                                              }
                                              
                                              //通知刷新
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableViewInGroup"
                                                                                                  object:self
                                                                                                userInfo:@{@"group":[NSString stringWithFormat:@"%d", group]}];
                                          }
                                      } fail:^(NSError *error) {
                                          NSLog(@"Download Article List Error:%@", error);
                                      }];
}

- (void)downloadArticleInGroup:(int)group withLoadCount:(int)loadCount success:(void (^)(NSArray *articlesInList))successBlock fail:(void (^)(NSError *error))failBlock
{
    [self.xyHttpClient downloadArticleInGroup:group
                                withLoadCount:loadCount
                                      success:^(XYArticleListManager *xyArticleListManager) {
                                          //判断文章是否加载完
                                          if ([xyArticleListManager.list_size isEqualToString:@"0"]) {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadAllArticlesFinish"
                                                                                                  object:self
                                                                                                userInfo:@{@"group":[NSString stringWithFormat:@"%d", group]}];
                                          } else {
                                              //分为刷新和加载更多
                                              if (loadCount == 0) {
                                                  [self.articleManagers[group] removeAllArticles];
                                                  for (XYArticleList *article in xyArticleListManager.list) {
                                                      [self.articleManagers[group] addArticle:article];
                                                  }
                                              } else {
                                                  for (XYArticleList *article in xyArticleListManager.list) {
                                                      [self.articleManagers[group] addArticle:article];
                                                  }
                                              }
                                              
                                              //通知刷新
//                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadTableViewInGroup"
//                                                                                                  object:self
//                                                                                                userInfo:@{@"group":[NSString stringWithFormat:@"%d", group]}];
                                              NSArray *array = [self getArticlesInGroup:group];
                                              successBlock(array);
                                          }
                                      } fail:^(NSError *error) {
                                          NSLog(@"Download Article List Error:%@", error);
                                      }];
}

#pragma mark - 获取焦点图

- (NSArray *)getTopImages
{
    return [self.topImageManager getTopImages];
}

- (void)downloadTopImage
{
    [self.xyHttpClient downloadTopImageURL:^(XYTopImageManager *xyTopImageManager) {
        [self.topImageManager setTopImagesWithArray:xyTopImageManager.focus_list];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadScroller"
                                                            object:self
                                                          userInfo:nil];
    }
                                      fail:^(NSError *error) {
                                          NSLog(@"Download Top Images URL Error:%@", error);
                                      }];
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
            UIImage *image = [self.xyHttpClient downloadImage:coverUrl];
            
            // 4
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [self.articleManagers[group] saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
