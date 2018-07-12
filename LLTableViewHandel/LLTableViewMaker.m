//
//  LLTableViewMaker.m
//  LLTableViewHandel
//
//  Created by lcus on 2018/7/11.
//  Copyright © 2018年 lcus. All rights reserved.
//

#import "LLTableViewMaker.h"
#import "LLTableViewMakerProtocol.h"

typedef NS_ENUM(NSInteger,LLTableViewCellType) {
    LLTableViewCellTypeSingle,
    LLTableViewCellTypeMultil
    
};


@interface LLTableViewDataItem : NSObject

@property(nonatomic,strong) NSMutableArray * items;

-(instancetype)initWithItems:(NSArray*)items;

@end

@implementation LLTableViewDataItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.items =@[].mutableCopy;
    }
    return self;
}
-(instancetype)initWithItems:(NSArray *)items{
    
    LLTableViewDataItem *dataitem =[LLTableViewDataItem new];
    [dataitem.items addObjectsFromArray:items];
    return dataitem;
}

@end


@interface LLTableViewDataSource : NSObject

-(instancetype)initWithDataSource:(NSArray*)dataSource;
-(NSInteger)getSectionCount;
-(NSInteger)getSectionCellsCount:(NSInteger)section;

-(id)_getSectionData:(NSInteger)index;
-(id)_getDataAtIndexPath:(NSIndexPath*)indexPath;

-(void)_updateCellData:(id)data indexPath:(NSIndexPath *)indexPath;
-(void)_deleteDataWithIndexs:(NSArray<NSIndexPath *> *)indexs section:(NSInteger)section;

-(void)_loadMoreData:(NSArray *)data section:(NSInteger)section;
@end

@interface LLTableViewDataSource ()
@property(nonatomic,readonly) NSMutableArray <LLTableViewDataItem*>* sectionArray;
@end


@implementation LLTableViewDataSource

@synthesize sectionArray = _sectionArray;

-(instancetype)initWithDataSource:(NSArray *)dataSource{
    
    if (dataSource.count == 0) return nil;
    
    LLTableViewDataSource *ll_dataSource =[LLTableViewDataSource new];
    NSArray *warpArray = [self warpData:dataSource];

    for (NSArray *temp in warpArray) {
        
        LLTableViewDataItem *dataItem = [[LLTableViewDataItem alloc]initWithItems:temp];
        [ll_dataSource.sectionArray addObject:dataItem];
    }
    return ll_dataSource;
}


-(NSInteger)getSectionCount{
    return self.sectionArray.count;
}

-(NSInteger)getSectionCellsCount:(NSInteger)section{
    return ((LLTableViewDataItem*)self.sectionArray[section]).items.count;
}

-(id)_getSectionData:(NSInteger)index{

    return ((LLTableViewDataItem*)self.sectionArray[index]).items;
}

-(id)_getDataAtIndexPath:(NSIndexPath *)indexPath{
    
    return  ((LLTableViewDataItem*)self.sectionArray[indexPath.section]).items[indexPath.row];
}

-(void)_updateCellData:(id)data indexPath:(NSIndexPath *)indexPath{
    
    LLTableViewDataItem *cellItem = self.sectionArray[indexPath.row];
    [cellItem.items replaceObjectAtIndex:indexPath.row withObject:data];
}

-(void)_deleteDataWithIndexs:(NSArray<NSIndexPath *> *)indexs section:(NSInteger)section{
    
    NSMutableIndexSet *insets = [[NSMutableIndexSet alloc] init];
    [indexs enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [insets addIndex:obj.row];
    }];
    LLTableViewDataItem *item = [self _getSectionData:section];
    [item.items removeObjectsAtIndexes:insets];
}

-(void)_loadMoreData:(NSArray *)data section:(NSInteger)section{
    LLTableViewDataItem *dataItem =[self _getSectionData:section];

    [dataItem.items addObjectsFromArray:data];
}

-(NSArray *)warpData:(NSArray *)data{
    
    id indexData = data[0];
    if ([[indexData class]isKindOfClass:[NSArray class]]||[[indexData class] isSubclassOfClass:[NSArray class]]) {
        
        return data;
    }
    NSMutableArray *warp =[NSMutableArray array];
    [warp addObject:data];
    
    return warp;
}

-(NSMutableArray<LLTableViewDataItem *> *)sectionArray{
    if (!_sectionArray) {
        
        _sectionArray =[NSMutableArray array];
    }
    return _sectionArray;
}

@end

@interface LLTableViewDataSourceMaker ()

@property(nonatomic,assign) LLTableViewCellType cellsType;
@property(nonatomic,strong) id<LLTableViewDataSource> cellMaker;
@property(nonatomic,copy) void(^cellConfig)(UITableView *tablView,id cell,id cellData);
@property(nonatomic,strong) LLTableViewDataSource * dataSoure;
@property(nonatomic,strong) Class singleCellClass;

@end

@implementation LLTableViewDataSourceMaker

-(instancetype)initWithData:(NSArray *)data
                  cellClass:(Class)cellClass
                 cellConfig:(void (^)(UITableView *, id, id))cellConfig{
  
    self = [super init];
    if (self) {
        _cellsType = LLTableViewCellTypeSingle;
        _dataSoure = [[LLTableViewDataSource alloc]initWithDataSource:data];
        self.cellConfig = [cellConfig copy];
    }
    return self;
}

-(instancetype)initWithData:(NSArray *)data
                  cellMaker:(id<LLTableViewDataSource>)cellMaker
                 cellConfig:(void (^)(UITableView *, id, id))cellConfig{
    self = [super init];
    if (self) {
        _cellsType = LLTableViewCellTypeMultil;
        _dataSoure = [[LLTableViewDataSource alloc]initWithDataSource:data];
        _cellMaker = cellMaker;
        self.cellConfig = [cellConfig copy];
    }
    return self;
}

-(id)getDataAtIndexPath:(NSIndexPath *)index{
    
    return [self.dataSoure _getDataAtIndexPath:index];
}

-(void)updateCellData:(id)data indexPath:(NSIndexPath *)indexPath{
    
    [self.dataSoure _updateCellData:data indexPath:indexPath];
}

-(void)reloadDataSoure:(NSArray *)dataSource{
    
    self.dataSoure =[[LLTableViewDataSource alloc]initWithDataSource:dataSource];
}
-(void)deleteDataWithIndexs:(NSArray<NSIndexPath *> *)indexs{
    
    [self.dataSoure _deleteDataWithIndexs:indexs section:0];
}

-(void)loadMoreData:(NSArray *)data{
    
    [self.dataSoure _loadMoreData:data section:0];
}

-(void)loadMoreData:(NSArray *)data section:(NSInteger)section{
    [self.dataSoure _loadMoreData:data section:section];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (self.cellsType == LLTableViewCellTypeSingle) {
        
        return [self _singleCellForTableView:tableView indexPath:indexPath];
    }
    id cellData  = [self.dataSoure _getDataAtIndexPath:indexPath];
    return [self _multilCellForTableView:tableView indexPath:indexPath cellData:cellData];
}


-(UITableViewCell*)_singleCellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(_singleCellClass)];
    if (!cell) {
        
        cell  =[[_singleCellClass alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass(_singleCellClass)];
    }
    return cell;
}

-(UITableViewCell*)_multilCellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indePath cellData:(id)cellData{
    
    if ([self.cellMaker respondsToSelector:@selector(ll_CellForTableView:indexPath:cellData:)]) {
        
        return [self.cellMaker ll_CellForTableView:tableView indexPath:indePath cellData:cellData];
    }
    
    return nil;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dataSoure getSectionCellsCount:section];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return [self.dataSoure getSectionCount];
}

@end



@implementation LLTableViewDelegateMake




@end



