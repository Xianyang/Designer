//
//  WriteCommentViewController.h
//  Designer
//
//  Created by 罗 显扬 on 12/1/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentModel.h"

@protocol WriteCommentViewControllerDelegate

- (void)reloadCommentData:(CommentModel *)allComment;
- (void)dimissWriteCommentController;
- (void)writeCommentControllerDone;

@end

@interface WriteCommentViewController : UIViewController
{
//    id <WriteCommentViewControllerDelegate> __unsafe_unretained delegate;
}

- (void)setArticleID:(NSInteger)articleID;

@property (assign, nonatomic) id <WriteCommentViewControllerDelegate> delegate;

@end
