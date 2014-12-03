//
//  GetArticleData.h
//  HahaFarm
//
//  Created by 罗 显扬 on 10/19/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>

@interface GetArticleData : NSObject <ASIHTTPRequestDelegate>

@property (strong, nonatomic) NSMutableArray *imageArray;

- (NSDictionary *)getArtilcleListWithLoadNumber:(NSInteger)loadCount;
- (NSDictionary *)getArtilcleByGroupNumber:(NSInteger)group withLoadNumber:(NSInteger)loadCount;
- (NSDictionary *)getTopImageDataOnce;
- (UIImage *)getImageByUrl:(NSString *)urlString;

- (NSDictionary *)getArticleData:(NSInteger)articleID;
- (NSDictionary *)getCommentData:(NSInteger)articleID;
- (NSDictionary *)sendACommentInArticle:(NSInteger)articleID commentContent:(NSString *)contentString atTime:(NSString *)dateString;
- (NSDictionary *)sendADianzan:(NSInteger)articleID;

@end
