//
//  ArticleImageCell.h
//  Designer
//
//  Created by 罗 显扬 on 11/27/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *customImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

@end
