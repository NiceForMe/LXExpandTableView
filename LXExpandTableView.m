//
//  LXExpandTableView.m
//  LXExpandTableView
//
//  Created by NiceForMe on 16/12/9.
//  Copyright © 2016年 BHEC. All rights reserved.
//

#define JsonKey @"list"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define TableViewRowHeight 50 //cell的高度
#define SectionTitleColor [UIColor purpleColor]
#define SectionHeaderViewBackgroundColor [UIColor grayColor]
#define DefaultMargin 10
#define SmallMargin 5
#define BigMargin 15

#import "LXExpandTableView.h"
#import "Masonry.h"
/**
 *  -----------------------LXExpandTableView-----------------------
 */
@interface LXExpandTableView ()
@property (nonatomic,strong) LXTableView *tableView;
@end

@implementation LXExpandTableView
+ (LXExpandTableView *)shareInstance
{
    static LXExpandTableView *share;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        share = [[LXExpandTableView alloc]init];
    });
    return share;
}
- (LXTableView *)tableView
{
    if (!_tableView) {
        _tableView = [[LXTableView alloc]init];
    }
    return _tableView;
}
+ (void)showExpandTableViewWithSuperView:(UIView *)superView dataDic:(NSDictionary *)dataDic expandBlock:(LXExpandTableViewExpandBlock)expandBlock
{
    [[LXExpandTableView shareInstance]showExpandTableViewWithSuperView:superView dataDic:dataDic expandBlock:expandBlock];
}
- (void)showExpandTableViewWithSuperView:(UIView *)superView dataDic:(NSDictionary *)dataDic expandBlock:(LXExpandTableViewExpandBlock)expandBlock
{
    [self.tableView showExpandTableViewWithSuperView:superView dataDic:dataDic expandBlock:expandBlock];
}
@end

/**
 *  -----------------------LXTableView-----------------------
 */
@interface LXTableView ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *expandTableView;
@property (nonatomic,strong) NSMutableArray *dataSrouce;
@property (nonatomic,strong) UIImageView *arrow;
@end

@implementation LXTableView : UIView
- (NSMutableArray *)dataSrouce
{
    if (!_dataSrouce) {
        _dataSrouce = [NSMutableArray array];
    }
    return _dataSrouce;
}
- (UITableView *)expandTableView
{
    if (!_expandTableView) {
        _expandTableView = [[UITableView alloc]init];
        _expandTableView.dataSource = self;
        _expandTableView.delegate = self;
        _expandTableView.showsVerticalScrollIndicator = NO;
        _expandTableView.showsHorizontalScrollIndicator = NO;
        _expandTableView.layer.cornerRadius = 4.0;
        _expandTableView.showsVerticalScrollIndicator = YES;
        _expandTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _expandTableView.tableHeaderView = [[UIView alloc]init];
    }
    return _expandTableView;
}
- (void)showExpandTableViewWithSuperView:(UIView *)superView dataDic:(NSDictionary *)dataDic expandBlock:(LXExpandTableViewExpandBlock)expandBlock
{
    for (NSDictionary *dic in dataDic[JsonKey]) {
        LXTableViewModel *model = [[LXTableViewModel alloc]init];
        model.isExpand = NO;
        model.sectionName = dic[@"listName"];
        model.sectionArray = dic[@"listArray"];
        [self.dataSrouce addObject:model];
        [self.expandTableView reloadData];
    };
    self.expandBlock = expandBlock;
    self.expandTableView.frame = superView.bounds;
    [superView addSubview:self.expandTableView];
}
#pragma mark - datasource and delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSrouce.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LXTableViewModel *model = self.dataSrouce[section];
    NSInteger count = model.isExpand ? model.sectionArray.count : 0;
    return count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LXTableViewModel *model = self.dataSrouce[indexPath.section];
    LXTableViewCell *cell = [LXTableViewCell cellWithTableView:tableView];
    cell.titleLable.text = model.sectionArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LXTableViewModel *model = self.dataSrouce[indexPath.section];
    NSString *name = model.sectionArray[indexPath.row];
    if (self.expandBlock) {
        self.expandBlock(name);
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    LXTableViewModel *model = self.dataSrouce[section];
    //headerView
    UIView *headerView = [[UIView alloc]init];
    headerView.frame = CGRectMake(0, 0, ScreenWidth, TableViewRowHeight);
    headerView.backgroundColor = SectionHeaderViewBackgroundColor;
    //sectionBtn
    UIButton *sectionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    sectionBtn.backgroundColor = SectionHeaderViewBackgroundColor;
    sectionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [sectionBtn setTag:section];
    [sectionBtn setTitle:model.sectionName forState:UIControlStateNormal];
    [sectionBtn setTitleColor:SectionTitleColor forState:UIControlStateNormal];
    [sectionBtn addTarget:self action:@selector(expandSectionWithSender:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:sectionBtn];
    //arrow
    UIImageView *arrow = [[UIImageView alloc]init];
    self.arrow = arrow;
    arrow.contentMode = UIViewContentModeScaleAspectFit;
    arrow.userInteractionEnabled = YES;
    if (model.isExpand == YES) {
        arrow.image = [UIImage imageNamed:@"up"];
    }else{
        arrow.image = [UIImage imageNamed:@"down"];
    }
    [headerView addSubview:arrow];
    //seperat line
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView).with.offset(DefaultMargin);
        make.right.mas_equalTo(headerView).with.offset(-DefaultMargin);
        make.height.mas_equalTo(1.1);
        make.bottom.mas_equalTo(headerView).with.offset(0);
    }];
    
    [sectionBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(headerView).with.offset(DefaultMargin);
        make.top.bottom.mas_equalTo(headerView).with.offset(0);
        make.right.mas_equalTo(arrow.mas_left).with.offset(-DefaultMargin);
    }];
    [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sectionBtn.mas_right).with.offset(BigMargin);
        make.top.mas_equalTo(headerView).with.offset(BigMargin);
        make.bottom.mas_equalTo(headerView).with.offset(-BigMargin);
        make.right.mas_equalTo(headerView).with.offset(-BigMargin);
    }];
    
    return headerView;
}
- (void)expandSectionWithSender:(UIButton *)sender
{
    LXTableViewModel *model = self.dataSrouce[sender.tag];
    model.isExpand = !model.isExpand;
    [self.expandTableView reloadSections:[NSIndexSet indexSetWithIndex:sender.tag] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (model.isExpand == YES) {
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
            CGAffineTransform transform = self.arrow.transform;
            CGAffineTransform newTransform = CGAffineTransformRotate(transform, M_PI * 2);
            self.arrow.transform = newTransform;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionTransitionNone animations:^{
            CGAffineTransform transform = self.arrow.transform;
            CGAffineTransform newTransform = CGAffineTransformRotate(transform, -M_PI * 2);
            self.arrow.transform = newTransform;
        } completion:^(BOOL finished) {
            
        }];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TableViewRowHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return TableViewRowHeight;
}
@end

/**
 *  -----------------------LXTableViewSectionCell-----------------------
 */
@implementation LXTableViewCell : UITableViewCell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"Identifier";
    LXTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[LXTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
    return cell;
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}
- (void)initUI
{
    UILabel *titleLable = [[UILabel alloc]init];
    self.titleLable = titleLable;
    titleLable.backgroundColor = titleLable.superview.backgroundColor;
    titleLable.textAlignment = NSTextAlignmentLeft;
    titleLable.textColor = [UIColor blackColor];
    [self.contentView addSubview:titleLable];
    [titleLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).with.offset(BigMargin);
        make.right.mas_equalTo(self.contentView).with.offset(-DefaultMargin);
        make.top.bottom.mas_equalTo(self.contentView).with.offset(0);
    }];
}
@end

/**
 *  -----------------------LXTableViewModel-----------------------
 */
@implementation LXTableViewModel : NSObject

@end
