//
//  NSObject+easzKVO.h
//  LearnSD
//
//  Created by lcus on 2018/5/10.
//  Copyright © 2018年 lcus. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^ez_changeBlock)(NSString*keypth,id object,NSDictionary<NSKeyValueChangeKey,id> * change);

@interface NSObject (easzKVO)

-(void)ez_addObserver:(id)observer forKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context block:(ez_changeBlock)block;

-(void)bgl_addObserverForKeyPath:(NSString*)keyPath changeBlock:(ez_changeBlock)changeBlock;

-(void)bgl_addObserverForKeyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options context:(void*)context block:(ez_changeBlock)block;





@end
