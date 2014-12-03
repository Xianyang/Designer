//
//  CommentViewController.m
//  Designer
//
//  Created by 罗 显扬 on 12/2/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "CommentViewController.h"
#import "CommentCell.h"
#import "GetArticleData.h"
#import "CommentModel.h"
#import "WriteCommentViewController.h"

static NSString *CommentCellIdentifier = @"CommentCell";

@interface CommentViewController () <UITableViewDataSource, UITableViewDelegate, WriteCommentViewControllerDelegate>
{
    NSInteger _articleID;

    NSInteger _commentCount;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *writeCommentButton;
@property (strong, nonatomic) GetArticleData *articleData;
@property (strong, nonatomic) CommentModel *allComment;

@end

@implementation CommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.backButton addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];

    [self performSelectorInBackground:@selector(loadArticleCommentData) withObject:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES];
    [super viewWillAppear:animated];
}

- (void)setArticleID:(NSInteger)articleID
{
    _articleID = articleID;
}

- (void)popViewController
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 加载评论数据

- (void)loadArticleCommentData
{
    NSDictionary *dic = [self.articleData getCommentData:_articleID];
    
    if (dic) {
        [self performSelectorOnMainThread:@selector(finishLoadArticleCommentData:)
                               withObject:dic
                            waitUntilDone:NO];
    } else {
        //TODO加载文章数据失败
    }
}

- (void)finishLoadArticleCommentData:(NSDictionary *)dic
{
    id commentArray = [[dic objectForKey:@"comment_array"] mutableCopy];
    if ([commentArray isKindOfClass:[NSMutableArray class]]) {
        //将评论数组倒序
        NSArray *reversedArray = [[commentArray reverseObjectEnumerator] allObjects];
        if ([reversedArray count] > 0) {
            _commentCount = [reversedArray count];
            
            [self.allComment.commentTimes removeAllObjects];
            [self.allComment.commentUserName removeAllObjects];
            [self.allComment.commentContents removeAllObjects];
            
            for (NSDictionary *aDic in reversedArray) {
                id comment = [aDic objectForKey:@"comment"];
                if ([comment isKindOfClass:[NSString class]]) {
                    [self.allComment.commentContents addObject:comment];
                }
                id userName = [aDic objectForKey:@"who"];
                if ([userName isKindOfClass:[NSString class]]) {
                    [self.allComment.commentUserName addObject:userName];
                } else {
                    [self.allComment.commentUserName addObject:@"设机师"];
                }
                id time = [aDic objectForKey:@"time"];
                if ([time isKindOfClass:[NSString class]]) {
                    [self.allComment.commentTimes addObject:time];
                }
            }
            
            [self.tableView reloadData];
        } else {
            //TODO无评论
            
        }
    }
}

#pragma mark - delegate

- (void)dimissWriteCommentController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)writeCommentControllerDone
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)reloadCommentData:(CommentModel *)allComment
{
    self.allComment = allComment;
    [self.tableView reloadData];
    NSLog(@"reload comment");
}

#pragma mark - UITableViewDelegate

#pragma mark - UITableViewDatasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allComment.commentTimes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 102.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.tableView]) {
        CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CommentCellIdentifier
                                                             forIndexPath:indexPath];
        [self setContent:cell atIndexPath:indexPath];
        return cell;
    } else {
        return nil;
    }
}

- (void)setContent:(CommentCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.userNameOfComment.text = self.allComment.commentUserName[indexPath.row];
    cell.timeOfComment.text = self.allComment.commentTimes[indexPath.row];
    cell.contentOfComment.text = self.allComment.commentContents[indexPath.row];
}

- (CommentModel *)allComment
{
    if (!_allComment) _allComment = [[CommentModel alloc] init];
    return _allComment;
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"PresentWriteCommentViewSegue"]) {
        UINavigationController *navigationC = segue.destinationViewController;
        WriteCommentViewController *writeCommentViewController = navigationC.viewControllers[0];
        writeCommentViewController.delegate = self;
        [writeCommentViewController setArticleID:_articleID];
    }
}


@end
