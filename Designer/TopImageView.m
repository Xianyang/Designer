//
//  TopImageView.m
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/13.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import "TopImageView.h"

#define DEVICE_FRAME [UIScreen mainScreen].bounds.size
#define TOPIMAGE_HEIGHT 213.0f

@implementation TopImageView

- (id)initWithImageUrl:(NSString *)url title:(NSString *)title articleID:(NSString *)articleID
{
    if ([super init]) {
        self.frame = CGRectMake(0.0f, 0.0f, DEVICE_FRAME.width, TOPIMAGE_HEIGHT);
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, TOPIMAGE_HEIGHT - 50.0f, DEVICE_FRAME.width, 34.0f)];
        titleLabel.backgroundColor = [UIColor clearColor];
        
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:18];
        [titleLabel setText:[@"    " stringByAppendingString:title]];
        [self addSubview:titleLabel];
        
        self.articleID = articleID;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DownloadImageNotification"
                                                            object:self
                                                          userInfo:@{@"imageView":self, @"url":url}];
    }
    
    return self;
}

@end
