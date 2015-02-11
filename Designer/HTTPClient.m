//
//  HTTPClient.m
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/12.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "HTTPClient.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>

@implementation HTTPClient

- (NSDictionary *)downloadArticleInGroup:(int)group withLoadCount:(int)loadCount
{
    NSURL *url = [NSURL URLWithString:@"http://shejishi.ios.hop8.com/designer_app//index.php?r=Data/listgroup"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)loadCount] forKey:@"load"];
    [asiHttpRequest addPostValue:[NSString stringWithFormat:@"%ld", (long)group] forKey:@"group"];
    
    return [self loadData:asiHttpRequest];
}

- (NSDictionary *)downloadTopImageURL
{
    NSURL *url = [NSURL URLWithString:@"http://shejishi.ios.hop8.com/designer_app/index.php?r=Data/focuslist"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    
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
            
            if ([dic count]) {
                return dic;
            } else {
                return nil;
            }
        }
        
        NSLog(@"fail to get article data");
        return nil;
    } else {
        NSLog(@"fail to get article data");
        return nil;
    }
}

- (UIImage*)downloadImage:(NSString*)url
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [UIImage imageWithData:data];
}

@end
