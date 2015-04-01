//
//  XYHttpClient.m
//  Designer
//
//  Created by 罗 显扬 on 4/1/15.
//  Copyright (c) 2015 罗 显扬. All rights reserved.
//

#import "XYHttpClient.h"
#import <AFNetworking/AFNetworking.h>

@implementation XYHttpClient

- (void)downloadArticleInGroup:(int)group
                 withLoadCount:(int)loadCount
                       success:(void (^)(XYArticleListManager *))successBlock
                          fail:(void (^)(NSError *))failBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    NSDictionary *parameters = @{@"load":[NSString stringWithFormat:@"%ld", (long)loadCount],
                                 @"group":[NSString stringWithFormat:@"%ld", (long)group]};
    
    [manager POST:@"http://shejishi.ios.hop8.com/designer_app//index.php?r=Data/listgroup"
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  NSError *error = nil;
                  XYArticleListManager *xyArticleListManager = [[XYArticleListManager alloc] initWithDictionary:responseObject
                                                                                                          error:&error];
                  if (xyArticleListManager) {
                      successBlock(xyArticleListManager);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failBlock(error);
          }];
}

- (void)downloadTopImageURL:(void (^)(XYTopImageManager *xyTopImageManager))successBlock
                       fail:(void (^)(NSError *error))failBlock
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:@"http://shejishi.ios.hop8.com/designer_app/index.php?r=Data/focuslist"
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                  NSError *error = nil;
                  XYTopImageManager *xyTopImageManager = [[XYTopImageManager alloc] initWithDictionary:responseObject
                                                                                                 error:&error];
                  if (xyTopImageManager) {
                      successBlock(xyTopImageManager);
                  }
              }
          }
          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              failBlock(error);
          }];
}

- (UIImage*)downloadImage:(NSString*)url
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    return [UIImage imageWithData:data];
}

@end
