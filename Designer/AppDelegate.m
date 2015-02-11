//
//  AppDelegate.m
//  Designer
//
//  Created by 罗 显扬 on 11/27/14.
//  Copyright (c) 2014 罗 显扬. All rights reserved.
//

#import "AppDelegate.h"
#import <RESideMenu/RESideMenu.h>
#import "FirstViewController.h"
#import "SecondViewController.h"
#import <ASIHTTPRequest/ASIFormDataRequest.h>
#import <ASIHTTPRequest/ASIHTTPRequest.h>

#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboSDK.h"
#import <RennSDK/RennSDK.h>

#import "MobClick.h"

#define IS_WIDESCREEN ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface AppDelegate ()

@end

@implementation AppDelegate {
    NSMutableArray *_addedItems;
    NSMutableArray *_menuItems;
}

+ (NSInteger)OSVersion
{
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    return _deviceSystemMajorVersion;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //判断是否首次进入
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firstLogin"]) {
        NSDictionary *dic = [self getSideMenuTitles];
        if ([dic count]) {
            id array = [dic objectForKey:@"group_array"];
            if ([array isKindOfClass:[NSArray class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"SideMenuTitles"];
            }
        }
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstLogin"];
    }
    
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * path = [bundle pathForResource:@"channelid" ofType:nil];
    NSString * channelname = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];

    [MobClick startWithAppkey:@"548000f4fd98c5f440000e7f" reportPolicy:BATCH channelId:channelname];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    [MobClick setLogEnabled:YES];
    
    //设置社交平台
    [ShareSDK registerApp:@"5ba046852942"];
    
    [self initializePlat];
    
    return YES;
}

- (void)initializePlat
{
    //1.Wechat
    [ShareSDK connectWeChatWithAppId:@"wx606d3cb001243b32"
                              appSecret:@"4ecec4a1f013c05950b8f6c228b3d49e"
                              wechatCls:[WXApi class]];
    
    //2.QQ
    [ShareSDK connectQQWithQZoneAppKey:@"1104153828"
                     qqApiInterfaceCls:[TencentApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //3.微博
    [ShareSDK connectSinaWeiboWithAppKey:@"2370731359"
                               appSecret:@"2d9bedf493e5b81657993461ea21381e"
                             redirectUri:@"http://www.sharesdk.cn"];
    
    //4.QQ控件
    [ShareSDK connectQZoneWithAppKey:@"1104153828"
                           appSecret:@"LG8vODHsfY8sSRVn"
                   qqApiInterfaceCls:[TencentApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
}

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (NSDictionary *)getSideMenuTitles
{
    //获取文章分组
    NSURL *url = [NSURL URLWithString:@"http://121.41.35.78/news_app/index.php?r=Data/grouplist"];
    ASIFormDataRequest *asiHttpRequest = [ASIFormDataRequest requestWithURL:url];
    [asiHttpRequest startSynchronous];
    
    NSError *error = [asiHttpRequest error];
    if (!error) {
        NSData *data = [asiHttpRequest responseData];
        
        if (data) {
            NSDictionary *dic = [[NSDictionary alloc] init];
            
            dic = [NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingMutableContainers
                                                    error:&error];
            
            return dic;
        }
        
        NSLog(@"fail to get article data");
        return nil;
    } else {
        NSLog(@"fail to get article data");
        return nil;
    }

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
