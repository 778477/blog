//
//  CLRCallCollecter.h
//  灵感来自
//  https://medium.com/@michael.eisel/improving-app-performance-with-order-files-c7fff549907f
//  Created by miaoyou.gmy on 2020/1/9.
//

/**
 1. 设置 build_settings
        OTHER_CFLAGS ||= '-fsanitize-coverage=func,trace-pc-guard'
        CLANG_ADDRESS_SANITIZER_CONTAINER_OVERFLOW = 'YES'
 2. ☑️勾选对应Scheme下的 Diagnostics - Address Sanitizer
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Returns all the calls that have been made, in the order that they were made. If a call is made more than once, it just records the first instance.
// Each time this function is called, it returns only the calls that have been made since the last time it was called
extern NSArray <NSString *> *CLRCollectCalls(void);

extern void CLRAppOrderFile(void(^completion)(NSString* orderFilePath));

NS_ASSUME_NONNULL_END
