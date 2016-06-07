//
//  CZJMyWalletCardCell.m
//  CZJShop
//
//  Created by Joe.Pen on 2/17/16.
//  Copyright © 2016 JoeP. All rights reserved.
//

#import "CZJMyWalletCardCell.h"
#import "CZJMyWalletCardItemCell.h"
@interface CZJMyWalletCardCell ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (weak, nonatomic) IBOutlet UIImageView *myImg;
@property (strong, nonatomic) NSArray* cardItemInfosAry;
@property (strong, nonatomic)UITableView* myTableView;
@property (weak, nonatomic) IBOutlet UIView *myContentView;
@end

@implementation CZJMyWalletCardCell

- (void)awakeFromNib {
    self.separatorViewHeight.constant = 0.5;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setCardCellWithCardDetailInfo:(CZJMyCardInfoForm*)cardInfo
{
    self.myImg.hidden = YES;
    self.cardItemInfosAry = cardInfo.items;
    if (self.cardItemInfosAry.count > 0)
    {
        [self getTableView:self.cardItemInfosAry.count];
        [self.myTableView reloadData];
    }
}

- (void)getTableView:(NSInteger)itemCount
{
    self.myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 150, PJ_SCREEN_WIDTH- 20, itemCount* 25) style:UITableViewStylePlain];
    self.myTableView.tableFooterView = [[UIView alloc]init];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    self.myTableView.scrollEnabled = NO;
    self.myTableView.clipsToBounds = NO;
    self.myTableView.showsVerticalScrollIndicator = NO;
    self.myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.myTableView.backgroundColor = CLEARCOLOR;
    [self.myContentView addSubview:self.myTableView];
    
    NSArray* nibArys = @[@"CZJMyWalletCardItemCell",
                         ];
    
    for (id cells in nibArys) {
        UINib *nib=[UINib nibWithNibName:cells bundle:nil];
        [self.myTableView registerNib:nib forCellReuseIdentifier:cells];
    }
}


#pragma mark-UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cardItemInfosAry.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CZJMyCardDetailInfoForm* detailForm = self.cardItemInfosAry[indexPath.row];
    CZJMyWalletCardItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"CZJMyWalletCardItemCell" forIndexPath:indexPath];
    CGSize labeSize = [CZJUtils calculateStringSizeWithString:detailForm.itemName Font:SYSTEMFONT(11) Width:200];
    cell.itemNamelabelWidth.constant = labeSize.width;
    cell.itemNameLabel.text = detailForm.itemName;
    cell.totalTimeLabel.text = detailForm.itemCount;
    cell.leftTimeLabel.text = detailForm.currentCount;
    if ([detailForm.currentCount integerValue] == 0)
    {
        cell.dotLabel.backgroundColor = CZJGRAYCOLOR;
        cell.itemNameLabel.textColor = CZJGRAYCOLOR;
        cell.totalTimeLabel.textColor = CZJGRAYCOLOR;
        cell.leftTimeLabel.textColor = CZJGRAYCOLOR;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark-UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25;
}

@end
