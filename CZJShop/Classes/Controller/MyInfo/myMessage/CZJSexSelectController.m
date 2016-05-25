//
//  CZJSexSelectController.m
//  CZJShop
//
//  Created by Joe.Pen on 1/14/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJSexSelectController.h"

@interface CZJSexSelectController ()
{
    NSIndexPath* currentIndexPath;
    NSInteger _indext;
}
@property(assign,nonatomic) NSInteger selectIndex;

@end

@implementation CZJSexSelectController

- (void)viewDidLoad {
    [super viewDidLoad];
    [CZJUtils customizeNavigationBarForTarget:self];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.tableView.tintColor = CZJREDCOLOR;
    NSString* sexStr = [USER_DEFAULT objectForKey:kUSerDefaultSexual];
    if ([sexStr isEqualToString:@""] || [sexStr isEqualToString:@"男"])
    {
        _indext = 0;
    }
    else if ([sexStr isEqualToString:@"女"])
    {
        _indext = 1;
    }
    else if ([sexStr isEqualToString:@"保密"])
    {
        _indext = 2;
    }
    self.selectIndex = _indext;
    currentIndexPath = [NSIndexPath indexPathForRow:_indext inSection:0];
    
    [self tableView:self.tableView didSelectRowAtIndexPath:currentIndexPath];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectIndex == _indext)
    {
        [self tableView:tableView didDeselectRowAtIndexPath:currentIndexPath];
    }
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    self.selectIndex = indexPath.row;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    DLog(@"section:%ld, row:%ld",indexPath.section,indexPath.row);
    [USER_DEFAULT setObject:cell.textLabel.text forKey:kUSerDefaultSexual];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}


@end
