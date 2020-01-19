# 构建一个动态库

> Mach-O Type (MACH_O_TYPE)
This setting determines the format of the produced binary and how it can be linked when building other binaries. For information on binary types, see Building Mach-O Files in Mach-O Programming Topics.

* Executable: Executables and standalone binaries and cannot be linked. mh_execute

* Dynamic Library: Dynamic libraries are linked at build time and loaded automatically when needed. mh_dylib

* Bundle: Bundle libraries are loaded explicitly at run time. mh_bundle

* Static Library: Static libraries are linked at build time and loaded at execution time. staticlib

* Relocatable Object File: Object files are single-module files that are linked at build time. mh_object



## __TEXT Segment: Read Only

|Section|Description|
|:--:|:--:|
|__text|The compiled machine code for the executable|
|__const|The general constant data for the executable|
|__cstring|Literal string constants (quoted strings in source code)|
|__picsymbol_stub|Position-independent code stub routines used by the dynamic linker (dyld).|

## __DATA Segment: Read/Write

|Section|Description|
|:--:|:--:|
|__data|Initialized global variables (for example int a = 1; or static int a = 1;).|
|__const|Constant data needing relocation (for example, char * const p = "foo";).|
|__bss|Uninitialized static variables (for example, static int a;).|
|__common|Uninitialized external globals (for example, int a; outside function blocks).|
|__dyld|A placeholder section, used by the dynamic linker.|
|__la_symbol_ptr|“Lazy” symbol pointers. Symbol pointers for each undefined function called by the executable.|
|__nl_symbol_ptr|“Non lazy” symbol pointers. Symbol pointers for each undefined data symbol referenced by the executable.|



[Apple - MachOOverview](https://developer.apple.com/library/archive/documentation/Performance/Conceptual/CodeFootprint/Articles/MachOOverview.html)

## Embedded & load Bundle

### 编译链接进入安装包
在目标`App General`页中`Frameworks,Librariser,and Embedded Content`添加你所构建出的`Framework`。即表示你将会在链接阶段来将该`framework`链接打包进宿主`App`内。


### 作为资源包拷贝进入安装包

也可以在`Build Phases`页中`Copy Bundle Resources`添加你所构建出的`Framework`。会在最后构建阶段将这个资源拷贝到安装包中。在`Framework`中的符号需要手动进行`load`操作。

下面代码演示了从动态库中反射加载了一个动态库里的`AAViewController`页面。

```ObjC
    static dispatch_once_t onceToken;
    static BOOL DYLIB_LOADED_RESULT = NO;
    dispatch_once(&onceToken, ^{
        NSString *dylibPath = [[NSBundle mainBundle] pathForResource:@"libAA" ofType:@"framework"];
        NSBundle *bundle = [NSBundle bundleWithPath:dylibPath];
        
        if (![bundle isLoaded]) {
            NSError *error;
            DYLIB_LOADED_RESULT = [bundle loadAndReturnError:&error];
            NSLog(@"load bundle result: %@ and error:%@",
                  @(DYLIB_LOADED_RESULT),
                  error.localizedDescription);
        }
    });
    
    if (!DYLIB_LOADED_RESULT) {
        return ;
    }
    
    Class clazz = NSClassFromString(@"AAViewController");
    if (!clazz) {
        return ;
    }
    UIViewController *aa = [[clazz alloc] init];
    [self.navigationController pushViewController:aa animated:YES];
```


两者差异：

方式1. 在编译阶段完成符号导入，可以在依赖处进行`import`模块和使用对应`public headers`下的所有头文件

方式2. 在运行时阶段手动完成`load`，时机可自主控制。所有符号没有显式的声明。需要依赖运行时反射来调用。也可以在外层提供一个封装桥接文件`libApiBridge.h`来封装反射，对外提供`Native`接口。