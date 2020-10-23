## 不为人知的direct


**直接上结论： 使用`__attribute__((objc_dirct))`修饰方法或者属性后，中台各个模块包大小大概有10%-15%不等的正向收益**


> before 和 after，都基于当前模块的master分支编译构建出的静态库产物

|module name|before|after|package size diff|
|:-:|:-:|:-:|:-:|
|libKSMWAzeroth.a|213.61KB|186.56KB|-12%|
|libObiwan.a|92.10 KB|81.59KB|-11%|



### How 

2019年来自`Pierre Habouzit`对`llvm`项目的一次[提交](https://github.com/llvm/llvm-project/commit/d4e1ba3fa9dfec2613bdcc7db0b58dea490c56b1)。


该提交支持了三种`direct`关键词修饰使用：

1. __attribute__((objc_direct)) is an attribute on methods declaration, 

2. __attribute__((objc_direct_members)) on implementation, categories or
extensions.

3. A `direct` property specifier is added (@Property(direct) type name)
 
> These attributes / specifiers cause the method to have no associated
Objective-C metadata (for the property or the method itself), and the
calling convention to be a direct C function call.



针对code size的变化：
> (1) Codegen size:

> In addition to `self`, `_cmd` is passed to objc_msgSend to be able to lookup your IMP. A selector is loaded from a GOT-like slot, called a selref, which in arm64 generates assembly akin to:

```Assembly
    adrp x1, mySelector@PAGE
    ldr  x1, [x1, mySelector@PAGEOFF]
```
> This is 8 bytes that you pay at every call site. The number of calls to objc_msgSend is large enough that these 8 useless bytes add up. For example, in CloudKit, these 2 instructions represent 10.7% of __text. This is fairly typical of Objective-C heavy code.


### 注意点

1. 由于`direct dispatch` 和 `dynamic dispatch`的区别，修饰之后的OC方法比较难被`method swizzling`。如果在运行时有被需要方法转发或者替换的场景，请谨慎使用该修饰词。


2. 这个修饰并不能提高运行效率，作者指出优化本意是在于code size。OC本身的msg_send得益于缓存优化设计，运行效率上不见得有所提高






参见：关于原作者针对`direct`的一些表述
https://twitter.com/pedantcoder/status/1197269246289444864