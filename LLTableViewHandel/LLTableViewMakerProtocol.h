//
//  LLTableViewDataSource.h
//  LLTableViewHandel
//
//  Created by lcus on 2018/7/11.
//  Copyright © 2018年 lcus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LLTableViewDataSource <NSObject>

-(UITableViewCell*)ll_CellForTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indePath cellData:(id)cellData;

@end

@protocol LLTableViewDelegate <NSObject>



@end;
