//
//  CZJMyInfoSettingController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/11/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyInfoSettingController.h"
#import "CZJCouponsCell.h"
#import "CZJBaseDataManager.h"
#import "CZJLoginModelManager.h"
#import "SVHTTPRequest.h"
#import "CZJNetworkManager.h"

@interface CZJMyInfoSettingController ()
<
UITableViewDelegate,
UITableViewDataSource
>
{
    NSArray* settingAry;
    UIProgressView* processView;
}
//创建TableView，注册Cell
@property (strong, nonatomic)UITableView* myTableView;
- (IBAction)exitLoginAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *exitBtn;

@end

@implementation CZJMyInfoSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    [self initViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

- (void)initViews
{
    settingAry = @[@"推送消息",
                   @"引导页",
                   @"清除本地缓存",
                   @"检测新版本",
                   @"关于车之健"
                   ];
    
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, PJ_SCREEN_WIDTH, 250) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = NO;
    self.myTableView.backgroundColor = CZJNAVIBARGRAYBG;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJCouponsCell"];
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
    
    [self.myTableView reloadData];
    
    self.exitBtn.hidden = ![USER_DEFAULT boolForKey:kCZJIsUserHaveLogined];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJCouponsCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJCouponsCell" forIndexPath:indexPath];
    cell.couponNameLabel.textColor = [UIColor blackColor];
    cell.couponNameLabel.font = SYSTEMFONT(16);
    cell.couponNameLabel.text = settingAry[indexPath.row];
    NSString* versionStr = settingAry[indexPath.row];
    CGSize size = [CZJUtils calculateTitleSizeWithString:versionStr AndFontSize:16];
    cell.coupontNameWidth.constant = size.width + 10;
    cell.myDetailLabel.hidden = YES;
    if (0 == indexPath.row)
    {
        cell.arrowImg.hidden = YES;
        cell.chooseButton.hidden = NO;
        [cell.chooseButton addTarget:self action:@selector(pushAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    if (3 == indexPath.row)
    {
        cell.arrowImg.hidden = YES;
        cell.myDetailLabel.hidden = NO;
        cell.myDetailLabel.text = [NSString stringWithFormat:@"V%@",[self getCurrentVersion]];
    }
    if (2 == indexPath.row)
    {
        cell.arrowImg.hidden = YES;
        cell.myDetailLabel.hidden = NO;
        float size = [CZJUtils folderSizeAtPath:CachesDirectory];
        cell.myDetailLabel.text = [NSString stringWithFormat:@"%.2fM",size];
    }
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 0;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (4 == indexPath.row)
    {
        [self performSegueWithIdentifier:@"segueToAboutUs" sender:self];
    }
    if (2 == indexPath.row)
    {
        __weak typeof(self) weak = self;
        [self showCZJAlertView:@"确定清除本地缓存" andConfirmHandler:^{
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [CZJUtils clearCache:^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                [weak.myTableView reloadData];
            }];
            [weak hideWindow];
        } andCancleHandler:nil];
    }
    if (3 == indexPath.row)
    {
        [self getAppID];
    }
}


- (void)pushAction:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
}

- (IBAction)exitLoginAction:(id)sender
{
    
    __weak typeof(self) weak = self;
    [self showCZJAlertView:@"确定退出" andConfirmHandler:^{
        //清除所有数据
        //省份信息
        [FileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:kCZJPlistFileProvinceCitys] error:nil];
        //搜索历史
        [FileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:kCZJPlistFileSearchHistory] error:nil];
        //默认收货地址
        [FileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:kCZJPlistFileDefaultDeliveryAddr] error:nil];
        
        //车主信息
        [FileManager removeItemAtPath:[DocumentsDirectory stringByAppendingPathComponent:kCZJPlistFileUserBaseForm] error:nil];
        
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultTimeDay];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultTimeMin];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultRandomCode];
        
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedCarModelType];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedCarModelID];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultChoosedBrandID];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPrice];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultEndPrice];
        [USER_DEFAULT setValue:@"" forKey:kUSerDefaultStockFlag];
        [USER_DEFAULT setValue:@"" forKey:kUSerDefaultPromotionFlag];
        [USER_DEFAULT setValue:@"" forKey:kUSerDefaultRecommendFlag];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultServicePlace];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultDetailStoreItemPid];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultDetailItemCode];
        
        [USER_DEFAULT setObject:@"" forKey:kUSerDefaultSexual];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageUrl];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageImagePath];
        [USER_DEFAULT setValue:@"" forKey:kUserDefaultStartPageForm];
        [USER_DEFAULT setObject:[NSNumber numberWithBool:NO] forKey:kCZJIsUserHaveLogined];
        [USER_DEFAULT setObject:@"0" forKey:kUserDefaultShoppingCartCount];
        [USER_DEFAULT setObject:@"" forKey:kCZJDefaultCityID];
        [USER_DEFAULT setObject:@"" forKey:kCZJDefaultyCityName];
        
        CZJBaseDataInstance.userInfoForm = nil;
        CZJLoginModelInstance.usrBaseForm = nil;
        [CZJBaseDataInstance refreshChezhuID];
        
        
        [weak.navigationController popViewControllerAnimated:YES];
         [weak hideWindow];
    } andCancleHandler:nil];
    
}


#pragma mark- 版本检测
- (void)getAppID {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    
    CZJSuccessBlock success = ^(id json) {
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        NSDictionary* dict = [CZJUtils DataFromJson:json];
        NSArray *infoArray = [dict objectForKey:@"results"];
        if ([infoArray count])
        {
            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
            
            if (![lastVersion isEqualToString:[self getCurrentVersion]]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
                alert.tag = 10000;
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                alert.tag = 10001;
                [alert show];
            }
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无更新信息" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 10002;
            [alert show];
        }
    };
    
//    [CZJBaseDataInstance generalPost:@{@"term":@"车之健",@"entity":@"software"} success:^(id json) {
//        NSDictionary* dict = [CZJUtils DataFromJson:json];
//        NSArray *infoArray = [dict objectForKey:@"results"];
//        if ([infoArray count]) {
//            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
//            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
//            
//            if (![lastVersion isEqualToString:[self getCurrentVersion]]) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
//                alert.tag = 10000;
//                [alert show];
//            }
//            else
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//                alert.tag = 10001;
//                [alert show];
//            }
//        }
//    } andServerAPI:@"http://itunes.apple.com/search"];
    [CZJNetWorkInstance postJSONWithNoServerAPI:@"http://itunes.apple.com/search"
                                     parameters:@{@"term":@"车之健",@"entity":@"software"}
                                        success:success
                                           fail:nil];
    
    
    
//    [SVHTTPRequest POST:@"http://itunes.apple.com/search"
//             parameters:@{@"term":@"车之健",@"entity":@"software"}
//            completion:^(id response, NSHTTPURLResponse *urlResponse, NSError *error) {
//                if (!error&&[urlResponse statusCode]==200) {
//                    NSData *data = (NSData *)response;
//                    id res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//                    NSLog(@"res.class==%@",[res class]);
//                    NSLog(@"res == %@",res);
//                    NSLog(@"results class == %@",[[res objectForKey:@"results"]class]);
//                    NSArray *arr = [res objectForKey:@"results"];
//                    for (id config in arr)
//                    {
//                        NSString *bundle_id = [config valueForKey:@"bundleId"];
//                        if ([bundle_id isEqualToString:@"APP_BUNDLE_IDENTIFIER"]) {
//                            NSString* app_id  = [config valueForKey:@"trackId"];
//                            NSString* updateURL = [config valueForKey:@"trackViewUrl"];
//                            NSString *app_Name = [config valueForKey:@"trackName"];
//                            NSString *version = [config valueForKey:@"version"];
//                            NSLog(@"app_id == %@,app_Name == %@,version == %@",app_id,app_Name,version);
//                            [self checkUpdate:version];
//                        }
//                    }
//                } else {
//                    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//                    [CZJUtils tipWithText:@"检测失败，当前无网络连接！" andView:nil];
//                }
//            }];
}



/*
 * 第二步：通过比较从App Store获取的应用版本与当前程序中设定的版本是否一致，然后判断版本是否有更新
 */
- (NSString*)getCurrentVersion
{
    //获取bundle里面关于当前版本的信息
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSLog(@"nowVersion == %@",nowVersion);
    return nowVersion;
}

- (void)checkUpdate:(NSString *)versionFromAppStroe {
    
    //获取bundle里面关于当前版本的信息
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *nowVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSLog(@"nowVersion == %@",nowVersion);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    //检查当前版本与appstore的版本是否一致
    if (![versionFromAppStroe isEqualToString:nowVersion])
    {
        UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:@"提示" message: @"有新的版本可供下载" delegate:self cancelButtonTitle:@"下次再说" otherButtonTitles: @"去下载", nil];
        [createUserResponseAlert show];
    } else {
        [CZJUtils tipWithText:@"暂无新版本" andView:nil];
    }
    
}

#pragma mark - AertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        //去appstore中更新
        //方法一：根据应用的id打开appstore，并跳转到应用下载页面
        //NSString *appStoreLink = [NSString stringWithFormat:@"http://itunes.apple.com/cn/app/id%@",app_id];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:appStoreLink]];
        
        //方法二：直接通过获取到的url打开应用在appstore，并跳转到应用下载页面
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:updateURL]];
    } else if (buttonIndex == 2) {
        //去itunes中更新
//        [[UIApplicationsharedApplication] openURL:[NSURLURLWithString:@"itms://itunes.apple.com/cn/app/guang-dian-bi-zhi/id511587202?mt=8"]];
    }
    
}

/*
 #pragma mark-获取appstore最新app版本
 - (NSString *)getCurrentAppStoreVersion
 {
 //        具体步骤如下：
 {
 //        具体步骤如下：
 //        1，用 POST 方式发送请求：
 //    http://itunes.apple.com/search?term=你的应用程序名称&entity=software
 //
 //        更加精准的做法是根据 app 的 id 来查找：
 //    http://itunes.apple.com/lookup?id=你的应用程序的ID
 //#define APP_URL http://itunes.apple.com/lookup?id=你的应用程序的ID
 //
 //        你的应用程序的ID 是 itunes connect里的 Apple ID
 //
 //        2，从获得的 response 数据中解析需要的数据。因为从 appstore 查询得到的信息是 JSON 格式的，所以需要经过解析。解析之后得到的原始数据就是如下这个样子的：
 //        {
 //            resultCount = 1;
 //            results =     (
 //                           {
 //                               artistId = 开发者 ID;
 //                               artistName = 开发者名称;
 //                               price = 0;
 //                               isGameCenterEnabled = 0;
 //                               kind = software;
 //                               languageCodesISO2A =             (
 //                                                                 EN
 //                                                                 );
 //                               trackCensoredName = 审查名称;
 //                               trackContentRating = 评级;
 //                               trackId = 应用程序 ID;
 //                               trackName = 应用程序名称";
 //                               trackViewUrl = 应用程序介绍网址;
 //                               userRatingCount = 用户评级;
 //                               userRatingCountForCurrentVersion = 1;
 //                               version = 版本号;
 //                               wrapperType = software;
 //                           }
 //                           );
 //        }
 //
 //        然后从中取得 results 数组即可，具体代码如下所示：
 //
 //        NSDictionary *jsonData = [dataPayload JSONValue];
 //        NSArray *infoArray = [jsonData objectForKey:@"results"];
 //        NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
 //        NSString *latestVersion = [releaseInfo objectForKey:@"version"];
 //        NSString *trackViewUrl = [releaseInfo objectForKey:@"trackViewUrl"];
 //
 //        如果你拷贝 trackViewUrl 的实际地址，然后在浏览器中打开，就会打开你的应用程序在 appstore 中的介绍页面。当然我们也可以在代码中调用 safari 来打开它。
 //        UIApplication *application = [UIApplication sharedApplication];
 //        [application openURL:[NSURL URLWithString:trackViewUrl]];
 //
 
 }
 //        具体代码如下：
 {
 //        NSString *URL = @"http://itunes.apple.com/lookup?id=你的应用程序的ID";
 //        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
 //        [request setURL:[NSURL URLWithString:URL]];
 //        [request setHTTPMethod:@"POST"];
 //        NSHTTPURLResponse *urlResponse = nil;
 //        NSError *error = nil;
 //        NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
 //
 //        NSString *results = [[NSString alloc] initWithBytes:[recervedData bytes] length:[recervedData length] encoding:NSUTF8StringEncoding];
 //        NSDictionary *dic = [results JSONValue];
 //        NSArray *infoArray = [dic objectForKey:@"results"];
 //        if ([infoArray count]) {
 //            NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
 //            NSString *lastVersion = [releaseInfo objectForKey:@"version"];
 //
 //            if (![lastVersion isEqualToString:currentVersion]) {
 //                //trackViewURL = [releaseInfo objectForKey:@"trackVireUrl"];
 //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"有新的版本更新，是否前往更新？" delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"更新", nil];
 //                alert.tag = 10000;
 //                [alert show];
 //            }
 //            else
 //            {
 //                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新" message:@"此版本为最新版本" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
 //                alert.tag = 10001;
 //                [alert show];
 //            }
 //        }
 }
 NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com"];
 [[UIApplication sharedApplication]openURL:url];
 return @"1234";
 */

@end
