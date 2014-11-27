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

//更新首页数据
- (NSDictionary *)getArticleListOnce
{
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:@"1" forKey:@"type"];
    return [self loadData:asiHttpRequest];
}

//加载更多首页数据
- (NSDictionary *)getMoreArticleList:(NSInteger)loadCount
{
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:@"2" forKey:@"type"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)loadCount] forKey:@"load"];
    return [self loadData:asiHttpRequest];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    
}

//获取文章数据
- (NSDictionary *)getArticleData:(NSInteger)articleID
{
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:@"3" forKey:@"type"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)articleID] forKey:@"id"];
    
    //get iphone udid
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [asiHttpRequest addPostValue:idfv forKey:@"phone_id"];
    
    return [self loadData:asiHttpRequest];
}

//获取文章评论数据
- (NSDictionary *)getCommentData:(NSInteger)articleID
{
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:@"6" forKey:@"type"];
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
- (NSMutableArray *)getTopImageDataOnce:(NSMutableArray *)urlArray
{
    NSLog(@"获取顶部的三张图片");
    [self.imageArray removeAllObjects];
    
    ASIHTTPRequest *request;
    
    for (NSString *string in urlArray) {
        NSURL *url = [NSURL URLWithString:string];
        request = [ASIHTTPRequest requestWithURL:url];
        [request setDelegate:self];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (!error) {
            NSData *data = [request responseData];
            UIImage *image = [UIImage imageWithData:data];
            
            if (image) {
                [self.imageArray addObject:image];
            }
            
            
        } else {
            NSObject *object = [[NSObject alloc] init];
            [self.imageArray addObject:object];
            
        }
    }
    
    return self.imageArray;
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
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    
    id userArea = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserLocationCity"];
    if ([userArea isKindOfClass:[NSString class]]) {
        userArea = [userArea stringByAppendingString:@"菜友"];
        [asiHttpRequest addPostValue:userArea forKey:@"area"];
    } else {
        [asiHttpRequest addPostValue:@"菜友" forKey:@"area"];
    }
    
    [asiHttpRequest addPostValue:@"5" forKey:@"type"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)articleID] forKey:@"id"];
    [asiHttpRequest addPostValue:dateString forKey:@"time"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%@", contentString] forKey:@"comment"];
    return [self loadData:asiHttpRequest];
}

- (NSDictionary *)sendADianzan:(NSInteger)articleID
{
    NSLog(@"send a dianzan data");
    NSURL *url = [NSURL URLWithString:urlString];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:@"4" forKey:@"type"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)articleID] forKey:@"id"];
    
    //get iphone udid
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"the deviceToken is%@", idfv);
    [asiHttpRequest addPostValue:idfv forKey:@"phone_id"];
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

