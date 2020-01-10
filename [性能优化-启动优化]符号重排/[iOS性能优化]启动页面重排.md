## 页面重排的优化

### 1. 理论背景

系统在加载Mach-o文件里，并非直接分配物理内存，而是标记物理内存大小的段为该进程所有。等到具体使用时才进行真正的内存分配。
而在应用启动过程中，那些被使用到的`launch code`并



使用`Instruments - Virtual Memory Trace`来追踪应用的`page fault`情况

![pic1](./instruments-system trace-File page)

由`trace`结果可知，应用在冷启阶段触发`File Backed Page in`次数达945次。

### 2. 如何获取真正的order file


插桩法：
1. 有源码的情况下，可以在各个方法中插入打印函数。观察进程启动阶段的方法打印即可。
@LLVM的编译插桩

2. 无源码的情况，可以修改各个.a中的.o文件。插入打印函数。

3. 原生工具链支持[LLVM-SanitizerCoverage](https://clang.llvm.org/docs/SanitizerCoverage.html)

运行时hook:

1. hook objc_msgSend 在Objective-C runtime层插桩。

缺点是只能打印Objective-C的启动阶段方法调用。




https://research.fb.com/wp-content/uploads/2017/01/cgo2017-hfsort-final1.pdf