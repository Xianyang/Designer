//
//  TopImageView.h
//  Guangyingji
//
//  Created by 罗 显扬 on 14/12/13.
//  Copyright (c) 2014年 罗 显扬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopImageView : UIImageView

@property (strong, nonatomic) NSString *articleID;

- (id)initWithImageUrl:(NSString *)url title:(NSString *)title articleID:(NSString *)articleID;

@end
