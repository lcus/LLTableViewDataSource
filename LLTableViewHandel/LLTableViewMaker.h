//
//  LLTableViewMaker.h
//  LLTableViewHandel
//
//  Created by lcus on 2018/7/11.
//  Copyright © 2018年 lcus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol LLTableViewDataSource;
@protocol LLTableViewDelegate;


@interface LLTableViewDataSourceMaker : NSObject<UITableViewDataSource>

//单行
-(instancetype)initWithData:(NSArray *)data
                  cellClass:(Class)cellClass
                 cellConfig:(void(^)(UITableView *tableView,id cell,id cellData))cellConfig;

//多行
-(instancetype)initWithData:(NSArray*)data
                  cellMaker:(id<LLTableViewDataSource>)cellMaker
                 cellConfig:(void(^)(UITableView *tableView,id cell,id cellData))cellConfig;

-(void)reloadDataSoure:(NSArray*)dataSource;

-(void)updateCellData:(id)data indexPath:(NSIndexPath*)indexPath;

-(void)deleteDataWithIndexs:(NSArray<NSIndexPath*>*)indexs;

-(void)loadMoreData:(NSArray*)data;

-(void)loadMoreData:(NSArray *)data section:(NSInteger)section;

-(id) getDataAtIndexPath:(NSIndexPath*)index;

@end

@interface LLTableViewDelegateMake : NSObject<UITableViewDelegate>


//-(instancetype)initWithDelegate:(id<LLTableViewDelegate>)delegate;

@property(nonatomic,copy) void(^cellDidSelect)(UITableView*tableView,id cell,NSIndexPath *indexPath);
@property(nonatomic,copy) void(^cellWillDisplay)(UITableView*tableView,id cell,NSIndexPath *indexPath);

@end




