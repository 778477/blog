# Objective-C Code Format

[clang format](http://clang.llvm.org/docs/ClangFormat.html)

```Shell
brew install clang-format
```

导出内置的`format style`文件

```Shell
clang-format -style=llvm -dump-config > .clang-format
```

配置文件为`YAML`格式。具体可以查看各个`options`的配置项说明[style options](http://clang.llvm.org/docs/ClangFormatStyleOptions.html)


## Language

|language|possible values|in configuration|
|:-:|:-:|:-:|
|-|LK_None|None|
|C,C++|LK_Cpp|Cpp|
|C#|LK_CSharp|CSharp|
|Java|LK_Java|Java|
|JavaScript|LK_JavaScript|JavaScript|
|Objective-C,Objective-C++|LK_ObjC|ObjC|
|Protocol Buffers|LK_Proto|Proto|


## 业界方案

(git precommit hook + clang-format)https://github.com/square/spacecommander
