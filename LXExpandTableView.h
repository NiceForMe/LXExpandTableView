//
//  LXExpandTableView.h
//  LXExpandTableView
//
//  Created by NiceForMe on 16/12/9.
//  Copyright © 2016年 BHEC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/**
 *  -----------------------LXExpandTableView-----------------------
 */
typedef void (^LXExpandTableViewExpandBlock)(id selectRow);

@interface LXExpandTableView : NSObject
+ (void)showExpandTableViewWithSuperView:(UIView *)superView dataDic:(NSDictionary *)dataDic expandBlock:(LXExpandTableViewExpandBlock)expandBlock;
@end

/**
 *  -----------------------LXTableView-----------------------
 */
@interface LXTableView : UIView
@property (nonatomic,assign) LXExpandTableViewExpandBlock expandBlock;
- (void)showExpandTableViewWithSuperView:(UIView *)superView dataDic:(NSDictionary *)dataDic expandBlock:(LXExpandTableViewExpandBlock)expandBlock;
@end

/**
 *  -----------------------LXTableViewSectionCell-----------------------
 */
@interface LXTableViewCell : UITableViewCell
@property (nonatomic,strong) UILabel *titleLable;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end


/**
 *  -----------------------LXTableViewModel-----------------------
 */
@interface LXTableViewModel : NSObject
@property (nonatomic,assign) BOOL isExpand;
@property (nonatomic,strong) NSString *sectionName;
@property (nonatomic,strong) NSArray *sectionArray;
@end
