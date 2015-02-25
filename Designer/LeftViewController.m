//
//  LeftViewController.m
//  Designer
//
//  Created by 罗 显扬 on 11/27/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "LeftViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "FifthViewController.h"
#import "UIViewController+RESideMenu.h"

@interface LeftViewController ()
@property (strong, readwrite, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UINavigationController *firstNav;
@property (strong, nonatomic) UINavigationController *secondNav;
@property (strong, nonatomic) UINavigationController *thirdNav;
@property (strong, nonatomic) UINavigationController *fourthNav;
@property (strong, nonatomic) UINavigationController *fifthNav;

@end

@implementation LeftViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 5) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    
//    self.firstNav;
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstTabTapped"];
            [self.sideMenuViewController setContentViewController:self.firstNav
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 1:
            [self.sideMenuViewController setContentViewController:self.secondNav
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 2:
            [self.sideMenuViewController setContentViewController:self.thirdNav
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 3:
            [self.sideMenuViewController setContentViewController:self.fourthNav
                                                         animated:YES];
            [self.sideMenuViewController hideMenuViewController];
            break;
        case 4:
//            [self.sideMenuViewController setContentViewController:self.fifthNav
//                                                         animated:YES];
//            [self.sideMenuViewController hideMenuViewController];
            break;
        default:
            break;
    }
}

- (UINavigationController *)firstNav
{
    if (!_firstNav) {
        FirstViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FirstViewController"];
        _firstNav = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    
    return _firstNav;
}


- (UINavigationController *)secondNav
{
    if (!_secondNav) {
        SecondViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SecondViewController"];
        viewController.group= 1;
        _secondNav = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    
    return _secondNav;
}

- (UINavigationController *)thirdNav
{
    if (!_thirdNav) {
        ThirdViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ThirdViewController"];
        viewController.group = 2;
        _thirdNav = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    
    return _thirdNav;
}

- (UINavigationController *)fourthNav
{
    if (!_fourthNav) {
        FourthViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FourthViewController"];
        viewController.group = 3;
        _fourthNav = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    
    return _fourthNav;
}

- (UINavigationController *)fifthNav
{
    if (!_fifthNav) {
        FifthViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FifthViewController"];
        viewController.group = 4;
        _fifthNav = [[UINavigationController alloc] initWithRootViewController:viewController];
    }
    
    return _fifthNav;
}

- (UINavigationController *)aNavToInitNav:(UINavigationController *)nav withID:(NSString *)viewCID
{
    if (!nav) {
        nav = [[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:viewCID]];
    }
    
    return nav;
}


#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
//    NSArray *images = @[@"IconHome", @"IconCalendar", @"IconProfile", @"IconSettings", @"IconEmpty"];
    cell.textLabel.text = [LeftViewController titlesOfTable][indexPath.row];
//    cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
    
    return cell;
}

//+ (NSArray *)titlesOfTable
//{
//    return @[@"                首  页",
//             @"                G U I",
//             @"                网  页",
//             @"                平  面",
//             @"                插  画"];
//}


+ (NSArray *)titlesOfTable
{
    return @[@"                首  页",
             @"                G U I",
             @"                网  页",
             @"                平  面",
             @""];
}

@end
