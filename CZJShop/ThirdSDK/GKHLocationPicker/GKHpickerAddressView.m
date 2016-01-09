//
//  VTSelectionPickerView.m
//  huiyang
//
//  Created by Mac on 14-2-21.
//  Copyright (c) 2014年 wwj. All rights reserved.
//
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#import "GKHpickerAddressView.h"
@interface GKHpickerAddressView ()

@property (weak,nonatomic) UITextField *textfield;

//data
@property (strong, nonatomic) NSDictionary *pickerDic;
@property (strong, nonatomic) NSArray *provinceArray;
@property (strong, nonatomic) NSArray *cityArray;
@property (strong, nonatomic) NSArray *townArray;
@property (strong, nonatomic) NSArray *selectedArray;
@end
@implementation GKHpickerAddressView
GKHpickerAddressView * instance;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (GKHpickerAddressView *)shareInstancePickerAddressByctrl:(UIViewController *)ctrl block:(passStrValueBlock)block;{
    static dispatch_once_t   p;
    dispatch_once(&p,^{
        instance=[[GKHpickerAddressView alloc] init];
        [instance setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.94 alpha:1.0]];
        [instance setUserInteractionEnabled:YES];
        [instance createPickerView];
        [ctrl.view endEditing:YES];
        [ctrl.view addSubview:instance];
        [instance.textfield becomeFirstResponder];
    });
    //
    [instance getPickerData];
    [instance.textfield becomeFirstResponder];
    instance.valueBlock=block;
    instance.ctrl=ctrl;
    [instance.pickerView reloadAllComponents];
    return instance;
}
#pragma mark - get data
- (void)getPickerData {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Address" ofType:@"plist"];
    self.pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    self.provinceArray = [self.pickerDic allKeys];
    self.selectedArray = [self.pickerDic objectForKey:[[self.pickerDic allKeys] objectAtIndex:0]];
    
    if (self.selectedArray.count > 0) {
        self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
    }
    
    if (self.cityArray.count > 0) {
        self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:0]];
    }
    
}
-(void)createPickerView
{
    if (self.pickerView==nil) {
        UITextField *TextField=[[UITextField alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        TextField.hidden=YES;
        [self addSubview:TextField];
        self.textfield=TextField;
        self.pickerView= [[UIPickerView alloc] init];
        self.pickerView.delegate=self;
        self.pickerView.dataSource=self;
        UIToolbar *keyboardToolbar;
        if (keyboardToolbar == nil) {
            keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 38.0f)];
            keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        }
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"完成",@"") style:UIBarButtonItemStylePlain target:self   action:@selector(dismiss)];
        [doneBarItem setTintColor:[UIColor whiteColor]];
        keyboardToolbar.backgroundColor=[UIColor blackColor];
        keyboardToolbar.superview.backgroundColor=[UIColor clearColor];
        [keyboardToolbar setItems:[NSArray arrayWithObjects:doneBarItem,nil]];
        //    NSLog(@"%lu",(unsigned long)self.keyboardToolbar.subviews.count);
        self.textfield.inputAccessoryView =keyboardToolbar;
        self.textfield.inputView=self.pickerView;
    }
}
#pragma  mark -UIPickViewDelegate-

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinceArray.count;
    } else if (component == 1) {
        return self.cityArray.count;
    } else {
        return self.townArray.count;
    }
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lable=[[UILabel alloc]init];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.font=[UIFont systemFontOfSize:13];
    if (component == 0) {
        lable.text=[self.provinceArray objectAtIndex:row];
    } else if (component == 1) {
        lable.text=[self.cityArray objectAtIndex:row];
    } else {
        lable.text=[self.townArray objectAtIndex:row];
    }
    return lable;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (component == 0) {
        return kScreenWidth/3-10;
    } else if (component == 1) {
        return kScreenWidth/3;
    } else {
        return kScreenWidth/3;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        self.selectedArray = [self.pickerDic objectForKey:[self.provinceArray objectAtIndex:row]];
        if (self.selectedArray.count > 0) {
            self.cityArray = [[self.selectedArray objectAtIndex:0] allKeys];
        } else {
            self.cityArray = nil;
        }
        if (self.cityArray.count > 0) {
            self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:0]];
        } else {
            self.townArray = nil;
        }
    }
    [pickerView selectedRowInComponent:1];
    [pickerView reloadComponent:1];
    [pickerView selectedRowInComponent:2];
    
    if (component == 1) {
        if (self.selectedArray.count > 0 && self.cityArray.count > 0) {
            self.townArray = [[self.selectedArray objectAtIndex:0] objectForKey:[self.cityArray objectAtIndex:row]];
        } else {
            self.townArray = nil;
        }
        [pickerView selectRow:1 inComponent:2 animated:YES];
    }
    [pickerView reloadComponent:2];
}
-(void)dismiss{
    [self.textfield resignFirstResponder];
    NSString *provinceStr=self.provinceArray[[self.pickerView selectedRowInComponent:0]];
    NSString *cityStr=self.cityArray[[self.pickerView selectedRowInComponent:1]];
     NSString *townStr=self.townArray[[self.pickerView selectedRowInComponent:2]];
    NSString *string=[NSString stringWithFormat:@"%@ %@ %@",provinceStr,cityStr,townStr];
    self.valueBlock(self.ctrl,string);
}



@end
