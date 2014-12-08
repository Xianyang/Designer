//
//  CommentCell.h
//  Designer
//
//  Created by 罗 显扬 on 12/2/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameOfComment;
@property (weak, nonatomic) IBOutlet UILabel *timeOfComment;
@property (weak, nonatomic) IBOutlet UILabel *contentOfComment;
@property (weak, nonatomic) IBOutlet UIImageView *touxiangImage;

@end
