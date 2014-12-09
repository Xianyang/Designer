//
//  WriteCommentViewController.m
//  Designer
//
//  Created by 罗 显扬 on 12/1/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "WriteCommentViewController.h"
#import "GetArticleData.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface WriteCommentViewController () <MBProgressHUDDelegate>
{
    NSInteger _articleID;
}
@property (weak, nonatomic) IBOutlet UITextView *writeCommentTextView;

@property (strong, nonatomic) GetArticleData *articleData;

@end

@implementation WriteCommentViewController
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigationBg"]
                                                  forBarMetrics:UIBarMetricsDefault];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    [self.writeCommentTextView becomeFirstResponder];
}

- (void)setArticleID:(NSInteger)articleID
{
    _articleID = articleID;
}

- (IBAction)cancleClick
{
    [self.writeCommentTextView resignFirstResponder];
    [self.delegate dimissWriteCommentController];
}

- (IBAction)sendClick
{
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    hud.delegate = self;
    
    //[hud showWhileExecuting:@selector(sending:) onTarget:self withObject:hud animated:YES];
    if (self.writeCommentTextView.text.length == 0) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"请输入评论";
        hud.minSize = CGSizeMake(120.0f, 120.0f);
        hud.margin = 20.0f;
        hud.yOffset = -50.0f;
        [hud show:YES];
        [hud hide:YES afterDelay:2.0f];
    } else if (self.writeCommentTextView.text.length > 4000) {
        hud.mode = MBProgressHUDModeText;
        hud.labelText = @"字数超出限制";
        hud.minSize = CGSizeMake(120.0f, 120.0f);
        hud.margin = 20.0f;
        hud.yOffset = -50.0f;
        [hud show:YES];
        [hud hide:YES afterDelay:2.0f];
    } else {
        hud.labelText = @"发送中";
        hud.yOffset = -50.0f;
        hud.minSize = CGSizeMake(120.0f, 120.0f);
        [hud showWhileExecuting:@selector(sending:) onTarget:self withObject:hud animated:YES];
    }
}

- (void)sending:(MBProgressHUD *)HUD
{
    //获取发送的时间
    NSDate *sendDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm"];
    NSString *sendDateString = [dateFormatter stringFromDate:sendDate];
    NSDictionary *dic = [self.articleData sendACommentInArticle:_articleID commentContent:self.writeCommentTextView.text atTime:sendDateString];
    if ([dic count]) {
        __block UIImageView *imageView;
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageNamed:@"send_success"];
            imageView = [[UIImageView alloc] initWithImage:image];
        });
        HUD.customView = imageView;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"发送成功";
        sleep(1);
        
        [self performSelectorOnMainThread:@selector(textViewResignFirstResponder) withObject:nil waitUntilDone:NO];
        
        [self performSelectorOnMainThread:@selector(reloadComment:) withObject:dic waitUntilDone:NO];
        
        
    } else {
        __block UIImageView *imageView;
        dispatch_sync(dispatch_get_main_queue(), ^{
            UIImage *image = [UIImage imageNamed:@"send_fail"];
            imageView = [[UIImageView alloc] initWithImage:image];
        });
        HUD.customView = imageView;
        HUD.mode = MBProgressHUDModeCustomView;
        HUD.labelText = @"发送失败";
        sleep(1);
    }
}

- (void)textViewResignFirstResponder
{
    [self.delegate dimissWriteCommentController];
    [self.writeCommentTextView resignFirstResponder];
}

- (void)reloadComment:(NSDictionary *)dic
{
    CommentModel *allComment = [[CommentModel alloc] init];
    
    id commentArray = [[dic objectForKey:@"comment_array"] mutableCopy];
    if ([commentArray isKindOfClass:[NSArray class]]) {
        NSArray *reversedArray = [[commentArray reverseObjectEnumerator] allObjects];
        if ([reversedArray count] > 0) {
            for (NSDictionary *aDic in reversedArray) {
                id comment = [aDic objectForKey:@"comment"];
                if ([comment isKindOfClass:[NSString class]]) {
                    [allComment.commentContents addObject:comment];
                }
                id userName = [aDic objectForKey:@"who"];
                if ([userName isKindOfClass:[NSString class]]) {
                    [allComment.commentUserName addObject:userName];
                } else {
                    [allComment.commentUserName addObject:@"设计师"];
                }
                id time = [aDic objectForKey:@"time"];
                if ([time isKindOfClass:[NSString class]]) {
                    [allComment.commentTimes addObject:time];
                }
                id avatar = [aDic objectForKey:@"avatar"];
                if ([avatar isKindOfClass:[NSString class]]) {
                    [allComment.commentAvatars addObject:avatar];
                }
            }
            
            [self.delegate reloadCommentData:allComment];
        }
    }
}

- (GetArticleData *)articleData
{
    if (!_articleData) _articleData = [[GetArticleData alloc] init];
    return _articleData;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
