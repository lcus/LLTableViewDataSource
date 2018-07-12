//
//  MyFishHooker.m
//  LearnSD
//
//  Created by lcus on 2018/7/10.
//  Copyright © 2018年 lcus. All rights reserved.
//

#import "LLBlokerHooker.h"
@import ObjectiveC.runtime;
@import ObjectiveC.message;

typedef NS_OPTIONS(NSUInteger, LLBlockFlages) {
    LLBlockFlages_HAS_COPY_DISPOSE = 1 << 25,
    LLBlockFlages_HAS_SIGNATURE = 1 << 30,
};

struct LLBlock_des_1{
    uintptr_t reserved;
    uintptr_t size;
};

struct LLBlock_des_2{
    void(*copy)(void *dst,const void *src);
    void(*dispose)(const void*);
};
struct LLBlock_des_3{
    const char *singnature;
    const char *layout;
};

typedef struct _LLBlock{
    void *isa;
    volatile int32_t flags;
    int32_t reserved;
    void(*invoke)(void *,...);
    struct LLBlock_des_1 *descriptor;
    
}*LLBlock;


static struct LLBlock_des_2 * getBlock_des_2(LLBlock block){
   
    if (!(block->flags&LLBlockFlages_HAS_COPY_DISPOSE))return NULL;
    
    uint8_t *desc = (uint8_t*)block->descriptor;
    
    desc += sizeof(struct LLBlock_des_1);
    
    return(struct LLBlock_des_2 *) desc;
}
static struct LLBlock_des_3 *getBlock_des_3(LLBlock block){
    
    if (!(block->flags & LLBlockFlages_HAS_SIGNATURE)) return NULL;
    
    uint8_t *desc =(uint8_t*)block->descriptor;
    
    desc += sizeof(struct LLBlock_des_1);
    
    if (block->flags&LLBlockFlages_HAS_COPY_DISPOSE) {
        
        desc+=sizeof(struct LLBlock_des_2);
        
    }
    return (struct LLBlock_des_3*)desc;
}


@implementation LLBlokerHooker


+(void)ll_hockBlock:(id)block{
    
    hook_block(block);
}

+(void)ll_changeBlock:(id)block target:(id)target{
    
    LLBlock block1 = (__bridge LLBlock)block;
    LLBlock block2 = (__bridge LLBlock)target;
    block1->invoke = block2->invoke;
}


static void hook_block(id obj){
    
    hookNSBlockMethod();
    
    LLBlock block = (__bridge LLBlock)obj;
    
    if (!get_tempblock(block)) {
        
        deepblock_copy(block);
        
        struct LLBlock_des_3 *des3 = getBlock_des_3(block);
        
        block->invoke = (void *)get_MsgForward(des3->singnature);
        
    }
}

static void hookNSBlockMethod(){
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        Class  cls = NSClassFromString(@"NSBlock");

#define LL_HookMethod(selector, func) {Method method = class_getInstanceMethod([NSObject class], selector); \
BOOL success = class_addMethod(cls, selector, (IMP)func, method_getTypeEncoding(method)); \
if (!success) { class_replaceMethod(cls, selector, (IMP)func, method_getTypeEncoding(method));}}
        
        LL_HookMethod(@selector(methodSignatureForSelector:), ll_methodSignatureForSelector);
        LL_HookMethod(@selector(forwardInvocation:),ll_forwardInvocation);

    });
}


NSMethodSignature * ll_methodSignatureForSelector(id self,SEL _cmd,SEL sel){
    
    struct LLBlock_des_3 *des3 = getBlock_des_3((__bridge void*)self);
    
    return [NSMethodSignature signatureWithObjCTypes:des3->singnature];
}
static void ll_forwardInvocation(id self, SEL _cmd, NSInvocation *invocation){
    
    LLBlock block  = (__bridge void*)invocation.target;
    
    id tempBlock = get_tempblock(block);
    if (![tempBlock isKindOfClass:NSClassFromString(@"NSBlock")]) {
        
        struct _LLBlock tb;
        
        [(NSValue*)tempBlock getValue:&tb];
        
        tempBlock =(__bridge id)&tb;

    }
    
    NSArray *array =invocation_getArguments(invocation, 1);
   
    NSLog(@"parmer %@",array);
    
    invocation.target = tempBlock;
    [invocation invoke];
    
}




static IMP get_MsgForward(const char *methodTypes) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    if (methodTypes[0] == '{') {
        NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methodTypes];
        if ([methodSignature.debugDescription rangeOfString:@"is special struct return? YES"].location != NSNotFound) {
            msgForwardIMP = (IMP)_objc_msgForward_stret;
        }
    }
#endif
    return msgForwardIMP;
}

static void deepblock_copy(LLBlock block){
    
    
    struct LLBlock_des_2 *des2 = getBlock_des_2(block);
    if (des2) {
        
        LLBlock newBlock = malloc(block->descriptor->size);
        if (!newBlock) return;
        memmove(newBlock, block, block->descriptor->size);
        des2->copy(newBlock,block);
        set_mallocBlock(block, newBlock);
        hook_blockDispose(block);
        
    }else{
        
        struct _LLBlock blockLayout;
        blockLayout.isa = block->isa;
        blockLayout.flags= block->flags;
        blockLayout.invoke =block->invoke;
        blockLayout.reserved =block->reserved;
        blockLayout.descriptor = block->descriptor;
        set_globleBlock(block, blockLayout);
    }
    
}


static void hook_blockDispose(LLBlock block){
    
    if (block->flags&LLBlockFlages_HAS_COPY_DISPOSE) {
        
        struct LLBlock_des_2 *des2 = getBlock_des_2(block);
        if (des2->dispose != ll_block_disposeFunc) {
            
            long long disposeAdders =(long long)des2->dispose;
            
            set_disposeFuncAddress((__bridge id)(block), disposeAdders);
            
            des2->dispose = ll_block_disposeFunc;
        }
    }
}

void ll_block_disposeFunc(const void *block_layout){
    
    LLBlock block = (LLBlock)block_layout;
    
    id tempBlock = get_tempblock(block);
    free((__bridge void *)(tempBlock));
    
    long long disposeAdders = get_disposeFuncAddress((__bridge id)(block_layout));
    
    void (*disposeFunc)(const void *) = (void(*)(const void *))disposeAdders;
    
    if (disposeFunc) {
        
        disposeFunc(block_layout);
    }
}


static id get_tempblock(LLBlock block){
    
    return objc_getAssociatedObject((__bridge id)block, @"set_tempBlock");
    
}
static long long  get_disposeFuncAddress(id block){
    
    return [objc_getAssociatedObject(block, @"Block_DisposeFunc") longLongValue];
    
}
static void set_disposeFuncAddress(id block, long long disposeFuncAdders) {
    objc_setAssociatedObject(block, "Block_DisposeFunc", @(disposeFuncAdders), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


static void set_mallocBlock(LLBlock block,LLBlock tempBlock){
    
    objc_setAssociatedObject((__bridge id)(block), @"set_tempBlock", (__bridge id)tempBlock, OBJC_ASSOCIATION_ASSIGN);
    
}
static void set_globleBlock(LLBlock block,struct _LLBlock tempBlock){
    
    NSValue *blockValue = [NSValue value:&tempBlock withObjCType:@encode(struct _LLBlock)];
    objc_setAssociatedObject((__bridge id)block, @"set_tempBlock", blockValue, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
static NSArray *invocation_getArguments(NSInvocation *invocation, NSInteger beginIndex) {
    
    NSMutableArray *args = [NSMutableArray new];
    for (NSInteger i = beginIndex; i < [invocation.methodSignature numberOfArguments]; i ++) {
        const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:i];
        id argBox;
        
#define LL_GetArgumentValueInBox(coding, type) case coding : {\
type arg;\
[invocation getArgument:&arg atIndex:i];\
argBox = @(arg);\
} break;
        
        switch (argType[0]) {
                LL_GetArgumentValueInBox('c', char)
                LL_GetArgumentValueInBox('i', int)
                LL_GetArgumentValueInBox('s', short)
                LL_GetArgumentValueInBox('l', long)
                LL_GetArgumentValueInBox('q', long long)
                LL_GetArgumentValueInBox('^', long long)
                LL_GetArgumentValueInBox('C', unsigned char)
                LL_GetArgumentValueInBox('I', unsigned int)
                LL_GetArgumentValueInBox('S', unsigned short)
                LL_GetArgumentValueInBox('L', unsigned long)
                LL_GetArgumentValueInBox('Q', unsigned long long)
                LL_GetArgumentValueInBox('f', float)
                LL_GetArgumentValueInBox('d', double)
                LL_GetArgumentValueInBox('B', BOOL)
            case '@': {
                id arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = arg;
            } break;
            case '*': {
                __autoreleasing id arg;
                [invocation getArgument:&arg atIndex:i];
                __weak id weakArg = arg;
                argBox = ^(){return weakArg;};
            } break;
            case '#': {
                Class arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = NSStringFromClass(arg);
            } break;
            case ':': {
                SEL arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = NSStringFromSelector(arg);
            } break;
            case '{': {
                NSUInteger valueSize = 0;
                NSGetSizeAndAlignment(argType, &valueSize, NULL);
                unsigned char arg[valueSize];
                [invocation getArgument:&arg atIndex:i];
                argBox = [NSValue value:arg withObjCType:argType];
            } break;
            default: {
                void *arg;
                [invocation getArgument:&arg atIndex:i];
                argBox = (__bridge id)arg;
            }
        }
        if (argBox) {
            [args addObject:argBox];
        }
    }
    
    return args;
}







@end
