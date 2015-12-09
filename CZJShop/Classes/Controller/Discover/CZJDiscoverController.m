//
//  CZJDiscoverViewController.m
//  CZJShop
//
//  Created by Joe.Pen on 12/1/15.
//  Copyright © 2015 JoeP. All rights reserved.
//

#import "CZJDiscoverController.h"
#import "CZJHomeViewManager.h"
#import "CZJDiscoverDetailController.h"

#define kTypeLabelTag 10
#define kNewsLabelTag 11
#define kDotViewTag 12

@interface CZJDiscoverViewController ()
@property (nonatomic,strong) NSMutableDictionary* discoverForms;
@end

@implementation CZJDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDataFromServer];
    self.discoverTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.discoverTableView.backgroundColor = RGB(239, 239, 239);
    self.discoverForms = [NSMutableDictionary dictionary];
}


- (void)getDataFromServer
{
    //从服务器获取数据成功返回回调
    CZJSuccessBlock successBlock = ^(id json){
        
        [self.discoverForms setValuesForKeysWithDictionary:CZJHomeViewInstance.discoverForms];
        [self updateTableView];
    };
    
    CZJFailureBlock failBlock = ^{};
    
    [CZJHomeViewInstance showDiscoverWithBlocksuccess:successBlock fail:failBlock];
}



- (void)viewDidAppear:(BOOL)animated
{
    NSArray* cells = [self.discoverTableView visibleCells];
    for (id cell in cells) {
        UIView* dotTagView = [[cell contentView]viewWithTag:kDotViewTag];
        dotTagView.layer.cornerRadius = 2.5;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return 15;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJTableViewCell* cell = (CZJTableViewCell*)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([cell.reuseIdentifier isEqualToString:@"activity"])
    {
        [self performSegueWithIdentifier:@"segueToActivity" sender:self];
    }
    UIView* dotTagView = [[cell contentView]viewWithTag:kDotViewTag];
    dotTagView.hidden = YES;
}


- (void)updateTableView
{
    NSArray* cells = [self.discoverTableView visibleCells];
    for (id cell in cells) {
        UIView* dotTagView = [[cell contentView]viewWithTag:kDotViewTag];
        NSString* reuseID = ((CZJTableViewCell*)cell).reuseIdentifier;
        NSString* newsBody = [[self.discoverForms valueForKey:reuseID]valueForKey:@"desc"];
        if ([newsBody isEqualToString:@""]) {
            DLog(@"%@",reuseID);
            dotTagView.hidden = YES;
            return;
        }
        ((UILabel*)[[cell contentView]viewWithTag:kNewsLabelTag]).text = newsBody;
        NSString* updatetime = [[self.discoverForms valueForKey:reuseID] valueForKey:@"updateTime"];
        NSString* value = [USER_DEFAULT valueForKey:reuseID];
        if (!value)
        {
            [USER_DEFAULT setValue:updatetime forKey:reuseID];
            dotTagView.hidden = NO;
        }
        else if ([value isEqualToString:updatetime])
        {
            dotTagView.hidden = YES;
        }
        else
        {
            DLog(@"%@",reuseID);
            dotTagView.hidden = NO;
        }
    }
}


- (void)dealWithDotTagView:(CZJTableViewCell*)_cell andUpdateTime:(NSString*)_updateTime
{
    
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CZJDiscoverDetailController* view = [segue destinationViewController];
    
    if ([segue.identifier isEqualToString:@"segueToCarnews"])
    {
        view.navigationItem.title = @"汽车资讯";
    }
    if ([segue.identifier isEqualToString:@"segueToActivity"])
    {
        view.navigationItem.title = @"活动中心";
    }
    if ([segue.identifier isEqualToString:@"segueToYao"])
    {
        view.navigationItem.title = @"摇一摇";
    }

}


@end


@implementation CZJDiscoverForm

- (instancetype)initWithDictionary:(NSDictionary *)dic
{
    if (self = [super init]) {
        self.newsBody = [dic valueForKey:@"desc"];
        self.newsUpdateTime = [dic valueForKey:@"updateTime"];
        return self;
    }
    return nil;
}

@end