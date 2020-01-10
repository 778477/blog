//
//  CLRCallCollecter.m
//
//  Created by miaoyou.gmy on 2020/1/9.
//

#import "CLRCallCollecter.h"
#import <dlfcn.h>
#import <libkern/OSAtomicQueue.h>
#import <pthread.h>


static OSQueueHead sQueueHead = OS_ATOMIC_QUEUE_INIT;
static BOOL sStopCollecting = NO;

typedef struct {
    void *pointer;
    void *next;
} PointerNode;

void __sanitizer_cov_trace_pc_guard_init(uint32_t *start, uint32_t *stop) {
    if(start == stop || (*start)) return ;
    NSLog(@"__sanitizer_cov_trace_pc_guard_init");
    // setup [start, stop] val = 1
    // 设置守护区间的地址为1. 标识该地址区间已被标记。避免重入
    for (uint32_t *x = start; x < stop; ++x) {
        *x = 1;
    }
}
// If initialization has not occurred yet (meaning that guard is uninitialized), that means that initial functions like +load are being run. These functions will only be run once anyways, so we should always allow them to be recorded and ignore guard
// +load方法等(pre main)阶段发生的方法调用会早于guard_init进行
void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    
    if (sStopCollecting) {
        return;
    }
    /**
     Built-in Function: void * __builtin_return_address (unsigned int level)
     This function returns the return address of the current function, or of one of its callers. The level argument is number of frames to scan up the call stack. A value of 0 yields the return address of the current function, a value of 1 yields the return address of the caller of the current function, and so forth. When inlining the expected behavior is that the function returns the address of the function that is returned to. To work around this behavior use the noinline function attribute.

     The level argument must be a constant integer.

     On some machines it may be impossible to determine the return address of any function other than the current one; in such cases, or when the top of the stack has been reached, this function returns 0 or a random value. In addition, __builtin_frame_address may be used to determine if the top of the stack has been reached.

     Additional post-processing of the returned value may be needed, see __builtin_extract_return_addr.
     */
    void *pointer = __builtin_return_address(0); // 返回当前线程调用堆栈的第一栈帧地址
    PointerNode *node = malloc(sizeof(PointerNode));
    *node = (PointerNode){pointer, NULL};
    OSAtomicEnqueue(&sQueueHead, node, offsetof(PointerNode, next));
}

extern NSArray <NSString *> *CLRCollectCalls(void) {
    
    sStopCollecting = YES;
    __sync_synchronize();
    // Hopefully, any other threads for which sStopCollecting was NO when they entered and are still preempted will get to preempt
    // during this sleep and finish up
    sleep(1);
    NSMutableSet<NSString *> *unqSet = [NSMutableSet set];
    NSMutableArray <NSString *> *functions = [NSMutableArray array];
    NSString* curFuncationName = [NSString stringWithUTF8String:__FUNCTION__];
    while (YES) {
        PointerNode *node = OSAtomicDequeue(&sQueueHead, offsetof(PointerNode, next));
        if (node == NULL) {
            break;
        }
        Dl_info info = {0};
        dladdr(node->pointer, &info);
        NSString *name = @(info.dli_sname);
        
        if([name isEqualToString:curFuncationName]) continue;
        if([unqSet containsObject:name]) continue;
        [unqSet addObject:name];
        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
        NSString *symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
        [functions addObject:symbolName];
    }
    return [[functions reverseObjectEnumerator] allObjects];
}

extern void CLRAppOrderFile(void(^completion)(NSString* orderFilePath)) {
    sStopCollecting = YES;
    __sync_synchronize();
    sleep(1);
   NSString* curFuncationName = [NSString stringWithUTF8String:__FUNCTION__];
   
    __auto_type generateOrderBlock = ^{
        NSMutableSet<NSString *> *unqSet = [NSMutableSet setWithObject:curFuncationName];
        NSMutableArray <NSString *> *functions = [NSMutableArray array];
        while (YES) {
            PointerNode *front = OSAtomicDequeue(&sQueueHead, offsetof(PointerNode, next));
            if(!front) {
                break;
            }
            Dl_info info = {0};
            dladdr(front->pointer, &info);
            NSString *name = @(info.dli_sname);
            if([unqSet containsObject:name]) {
                continue;
            }
            BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
            NSString *symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
            [unqSet addObject:name];
            [functions addObject:symbolName];
        }
        
        NSString *orderFileContent = [functions.reverseObjectEnumerator.allObjects componentsJoinedByString:@"\n"];
        NSLog(@"[orderFile]: %@",orderFileContent);
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"app.order"];
        [orderFileContent writeToFile:filePath
                           atomically:YES
                             encoding:NSUTF8StringEncoding
                                error:nil];
        if(completion){
            completion(filePath);
        }
    };
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), generateOrderBlock);
}

