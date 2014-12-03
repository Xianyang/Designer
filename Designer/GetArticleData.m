//
//  GetArticleData.m
//  HahaFarm
//
//  Created by 罗 显扬 on 10/19/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "GetArticleData.h"

static NSString *urlString = @"http://121.41.35.78/hahafarm/index.php?r=tblArticleJson/post";

@implementation GetArticleData

//加载首页数据，参数load
- (NSDictionary *)getArtilcleListWithLoadNumber:(NSInteger)loadCount
{
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/listall"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)loadCount] forKey:@"load"];
    return [self loadData:asiHttpRequest];
}

//加载分组文章数据
- (NSDictionary *)getArtilcleByGroupNumber:(NSInteger)group withLoadNumber:(NSInteger)loadCount
{
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/listgroup"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)loadCount] forKey:@"load"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)group] forKey:@"group"];
    
    return [self loadData:asiHttpRequest];
}

//获取文章数据
- (NSDictionary *)getArticleData:(NSInteger)articleID
{
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/article"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)articleID] forKey:@"id"];
    
    //get iphone uuid
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [asiHttpRequest addPostValue:idfv forKey:@"uuid"];
    
    return [self loadData:asiHttpRequest];
}

//获取文章评论数据
- (NSDictionary *)getCommentData:(NSInteger)articleID
{
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/commentlist"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];

    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)articleID] forKey:@"id"];
    
    return [self loadData:asiHttpRequest];
}

- (NSDictionary *)loadData:(ASIFormDataRequest *)asiHttpRequest
{
//    NSLog(@"load data");
    [asiHttpRequest startSynchronous];
    
    NSError *error = [asiHttpRequest error];
    if (!error) {
        NSData *data = [asiHttpRequest responseData];
        
        if (data) {
            NSDictionary *dic = [[NSDictionary alloc] init];
            
            dic = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingMutableContainers
                                                    error:&error];
            
            return dic;
        }
        
        NSLog(@"fail to get article data");
        return nil;
    } else {
        NSLog(@"fail to get article data");
        return nil;
    }
}

//获取三个image
- (NSDictionary *)getTopImageDataOnce
{
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/focuslist"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    
    return [self loadData:asiHttpRequest];
}

//根据url获取图片
- (UIImage *)getImageByUrl:(NSString *)urlString
{
    NSLog(@"get a image by url");
    ASIHTTPRequest *request;
    NSURL *url = [NSURL URLWithString:urlString];
    request = [ASIHTTPRequest requestWithURL:url];
    [request setDelegate:self];
    [request startSynchronous];
    
    NSError *error = [request error];
    if (!error) {
        NSData *data = [request responseData];
        UIImage *image = [UIImage imageWithData:data];
        
        if (image) {
            //write image to documents directory
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *imagePath = [documentsDirectory stringByAppendingPathComponent:@"1.jpeg"];
            [imageData writeToFile:imagePath atomically:YES];
            
            return image;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (NSDictionary *)sendACommentInArticle:(NSInteger)articleID commentContent:(NSString *)contentString atTime:(NSString *)dateString
{
    NSLog(@"send a comment data");
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/comment"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    
    id userArea = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserLocationCity"];
    if ([userArea isKindOfClass:[NSString class]]) {
        userArea = [userArea stringByAppendingString:@"设计师"];
        [asiHttpRequest addPostValue:userArea forKey:@"who"];
    } else {
        [asiHttpRequest addPostValue:@"设计师" forKey:@"who"];
    }
    
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)articleID] forKey:@"id"];
    [asiHttpRequest addPostValue:dateString forKey:@"time"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%@", contentString] forKey:@"comment"];
    return [self loadData:asiHttpRequest];
}

- (NSDictionary *)sendADianzan:(NSInteger)articleID
{
    NSLog(@"send a dianzan data");
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/like"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];

    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)articleID] forKey:@"id"];
    
    //get iphone uuid
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"the deviceToken is%@", idfv);
    [asiHttpRequest addPostValue:idfv forKey:@"uuid"];
    return [self loadData:asiHttpRequest];
}


- (NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [[NSMutableArray alloc] init];
    }
    
    return _imageArray;
}

@end

