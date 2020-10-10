[clang-analyzer release notes](https://clang-analyzer.llvm.org/release_notes.html)

[最新的下载链接](https://clang-analyzer.llvm.org/downloads/checker-279.tar.bz2)


```Bash
#!/bin/bash
#author=guomiaoyou

function install_clang_analyzer() {
    curl https://clang-analyzer.llvm.org/downloads/checker-279.tar.bz2 > ~/checker-279.tar.bz2   

    pushd ~
    tar -jxvf checker-279.tar.bz2
    rm -rf  checker-279.tar.bz2 
    echo "export PATH=$HOME/checker-279/bin:$PATH" >> .bash_profile && source .bash_profile
    popd
}


which scan-build

if [ $? -eq 1 ]; then
    echo "start download clang-analyzer and install"
    install_clang_analyzer
fi

echo "🍺🍺🍺 clang-analyzer checker-279 is install success!"
```

编写完脚本，上传到CDN之后。就可以进行使用安装。

bash -c "$(curl -fsSL https://xxx.cdn/clang-analyzer-installer.sh)"


在工程目录下进行静态分析扫描：

```Bash
scan-build --view -analyze-headers --use-analyzer Xcode xcodebuild clean build -workspace Example.xcworkspace -scheme Example -configuration Debug -sdk iphoneos
```

```
** BUILD SUCCEEDED ** [202.939 sec]

scan-build: Removing directory '/Users/miaoyou.gmy/work/Example/analyzer_result/2020-03-13-032527-16797-1' because it contains no reports.
scan-build: No bugs found.
```

`--view` 选项是指在扫描完成后，立即展示分析结果
`--use-analyzer` 选项是指定分析器，我们使用`Xcode`进行项目的分析构建

在项目目录下，可以使用下面命令对工程的`schemes`、`targets`等配置项进行打印
```Bash
xcodebuild -list -json
```

```json
{
  "project" : {
    "configurations" : [
      "Debug",
      "Release"
    ],
    "name" : "Example",
    "schemes" : [
      "Example"
    ],
    "targets" : [
      "Example",
      "ExampleTests"
    ]
  }
}
```
