//
//  ArticleImageCell.m
//  Designer
//
//  Created by 罗 显扬 on 11/27/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "ArticleImageCell.h"

@implementation ArticleImageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setCommentAndLikeHidden
{
    [self.commentCountLabel setHidden:YES];
    [self.likeCountLabel setHidden:YES];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
