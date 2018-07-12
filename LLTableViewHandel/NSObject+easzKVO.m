//
//  NSObject+easzKVO.m
//  LearnSD
//
//  Created by lcus on 2018/5/10.
//  Copyright © 2018年 lcus. All rights reserved.
//

#import "NSObject+easzKVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface ez_kvoInfo : NSObject
@property(nonatomic,weak) id observer;
@property(nonatomic,strong) NSString * keypath;
@property(nonatomic,assign) NSKeyValueObservingOptions options;
@property(nonatomic,copy)   ez_changeBlock block;
@property(nonatomic,assign) void* context;
@property(nonatomic,weak) id target;

-(instancetype)initWithObserver:(id)observer keyPath:(NSString*)keyPath options:(NSKeyValueObservingOptions)options blcok:(ez_changeBlock)block context:(void *)context;


@end
@implementation ez_kvoInfo

-(instancetype)initWithObserver:(id)observer keyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options blcok:(ez_changeBlock)block context:(void *)context{
    
    
    self = [super init];
    if (self) {
    
        self.observer = observer;
        self.keypath = keyPath;
        self.options = options;
        self.block=[block copy];
        self.context =context;
    }
    return self;
}

-(void)startObserver{
    
    [self.observer addObserver:self forKeyPath:self.keypath options:self.options context:self.context];
    
    
}
-(void)stropOBserver {
    
    
    [self.observer removeObserver:self forKeyPath:self.keypath];
    
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    
    if (self.block) {
        
        self.block(keyPath, object, change);
        
    }
}

-(BOOL)isEqual:(id)object{
    
    if (object == nil) {
        
        return NO;
    }
    if (self == object) {
        
        return YES;
    }
    
    if (![object isKindOfClass:[self class]]) {
        
        return YES;
    }
    return [_keypath isEqualToString:((ez_kvoInfo*)object).keypath];
    
}


@end




static void *ezObserversBlockKey = &ezObserversBlockKey;

//NSProcessInfo processInfo] globallyUniqueString 唯一标识符
@implementation NSObject (easzKVO)



-(void)bgl_addObserverForKeyPath:(NSString *)keyPath changeBlock:(ez_changeBlock)changeBlock{
    
    
}

-(void)bgl_addObserverForKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context block:(ez_changeBlock)block{
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    Class classtoSwizzle = self.class;
    
    NSMutableSet *swizzleClass = [self.class ez_swizzleClasses];
    
    NSString *className = NSStringFromClass(classtoSwizzle);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (![swizzleClass containsObject:className]) {
        
        SEL deallocSelector =sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id,SEL) = NULL;
        
        id newDealloc = ^( __unsafe_unretained id objSelf){
            
            [objSelf ez_cancleAllObservers];
            
            if (originalDealloc ==NULL) {
                
                struct objc_super superInfo={
                    .receiver=objSelf,
                    .super_class = class_getSuperclass(classtoSwizzle),
                };
                
                void(*msgSend)(struct objc_super*,SEL) =(__typeof__(msgSend))objc_msgSendSuper;
                
                msgSend(&superInfo,deallocSelector);
            }else{
                
                originalDealloc(objSelf,deallocSelector);
            }
            
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classtoSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            
            Method deallocMethod = class_getInstanceMethod(classtoSwizzle, deallocSelector);
            
            originalDealloc = (void(*)(__unsafe_unretained id,SEL))method_getImplementation(deallocMethod);
            
            originalDealloc = (void(*)(__unsafe_unretained id,SEL))method_setImplementation(deallocMethod, newDeallocIMP);
            
        }
        
        [swizzleClass addObject:className];
    }
    
    dispatch_semaphore_signal(semaphore);
    
    
    ez_kvoInfo *info =[[ez_kvoInfo alloc]initWithObserver:self keyPath:keyPath options:options blcok:block context:context];
    
//    info.target = observer;
    
    
    NSMutableSet *set =[self storeSet];
    NSMutableDictionary *dict =[self storeDict];
    if (dict == nil) {
        
        dict =[NSMutableDictionary dictionary];
        [self setStoreDict:dict];
    }
    if (set==nil) {
        
        set =[NSMutableSet set];
        
        [self setStoreSet:set];
    }
    
    if (![set containsObject:info]) {
        [set addObject:info];
        [dict setObject:info forKey:[self stroeKey:keyPath]];
        [info startObserver];
    };
}


-(void)ez_addObserver:(id)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context block:(ez_changeBlock)block{
    
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    Class classtoSwizzle = self.class;
    
    NSMutableSet *swizzleClass = [self.class ez_swizzleClasses];
    
    NSString *className = NSStringFromClass(classtoSwizzle);
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    if (![swizzleClass containsObject:className]) {
        
        SEL deallocSelector =sel_registerName("dealloc");
        
        __block void (*originalDealloc)(__unsafe_unretained id,SEL) = NULL;
        
        id newDealloc = ^( __unsafe_unretained id objSelf){
            
            [objSelf ez_cancleAllObservers];
            
            if (originalDealloc ==NULL) {
                
                struct objc_super superInfo={
                    .receiver=objSelf,
                    .super_class = class_getSuperclass(classtoSwizzle),
                };
                
                void(*msgSend)(struct objc_super*,SEL) =(__typeof__(msgSend))objc_msgSendSuper;
                
                msgSend(&superInfo,deallocSelector);
            }else{
                
                originalDealloc(objSelf,deallocSelector);
            }
            
        };
        
        IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
        
        if (!class_addMethod(classtoSwizzle, deallocSelector, newDeallocIMP, "v@:")) {
            
            Method deallocMethod = class_getInstanceMethod(classtoSwizzle, deallocSelector);
            
            originalDealloc = (void(*)(__unsafe_unretained id,SEL))method_getImplementation(deallocMethod);
            
            originalDealloc = (void(*)(__unsafe_unretained id,SEL))method_setImplementation(deallocMethod, newDeallocIMP);
            
        }
        
        [swizzleClass addObject:className];
    }
    
    dispatch_semaphore_signal(semaphore);
    
    
    ez_kvoInfo *info =[[ez_kvoInfo alloc]initWithObserver:self keyPath:keyPath options:options blcok:block context:context];

    info.target = observer;
    
    
    NSMutableSet *set =[self storeSet];
    NSMutableDictionary *dict =[self storeDict];
    if (dict == nil) {
        
        dict =[NSMutableDictionary dictionary];
        [self setStoreDict:dict];
    }
    if (set==nil) {
        
        set =[NSMutableSet set];
        
        [self setStoreSet:set];
    }
    
    if (![set containsObject:info]) {
        [set addObject:info];
        [dict setObject:info forKey:[self stroeKey:keyPath]];
        [info startObserver];
    };
}

-(void)ez_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    
    ez_kvoInfo *info =[[self storeDict]objectForKey:[self stroeKey:keyPath]];
    [info stropOBserver];
    
    [[self storeSet]removeObject:info];
    [[self storeDict]removeObjectForKey:[self stroeKey:keyPath]];
}

-(NSString*)stroeKey:(NSString*)keyPath{
    
    return [NSString stringWithFormat:@"%@%@",NSStringFromClass([self class]),keyPath];
}





-(void)ez_cancleAllObservers{
    
    NSLog(@"释放所有观察者");
    for (ez_kvoInfo *info in [self storeSet]) {
        [info stropOBserver];
    }
    [self setStoreDict:nil];
    [self setStoreSet:nil];
}



-(NSMutableDictionary*)storeDict{

    return objc_getAssociatedObject(self, @selector(setStoreDict:));
}

-(void)setStoreDict:(NSMutableDictionary*)dict{
    
    objc_setAssociatedObject(self, _cmd, dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(NSMutableSet*)storeSet{

    return objc_getAssociatedObject(self, @selector(setStoreSet:));
}


-(void)setStoreSet:(NSMutableSet*)set{
    
    
    objc_setAssociatedObject(self, _cmd, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}




+(NSMutableSet*)ez_swizzleClasses{
    
    static NSMutableSet *swizzledClassess = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        swizzledClassess =[[NSMutableSet alloc]init];
    });
    
    return swizzledClassess;
}


@end
