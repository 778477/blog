# 客户端Gitlab CI实践

![CI/CD workflow](https://docs.gitlab.com/ee/ci/introduction/img/gitlab_workflow_example_extended_v12_3.png)

从上图看到。在dev-ops之间，我们的开发交付形成了一个正向迭代的螺旋。按照这个workflow进行，有利于我们长期的工程质量

`gitlab CI`自身文档比较齐全，基本按照文档进行环境配置即可。

## 0x0 install

本机安装[gitlab-runner](https://docs.gitlab.com/runner/)

```
sudo curl --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-darwin-amd64

sudo chmod +x /usr/local/bin/gitlab-runner
```

## 0x1 register

> Before registering a runner, you need to first:

> Install it on a server separate than where GitLab is installed

> Obtain a token:

> For a shared runner, have an administrator go to the GitLab Admin Area and click Overview Runners

> For a group runner, go to Settings > CI/CD and expand the Runners section

> For a project-specific runner, go to Settings > CI/CD and expand the Runners section

这里我们针对项目配置的是`project-specific runner`，考虑到构建环境依赖的一些其他配置(ruby版本、Xcode版本等)。所以简单先以本机作为`runner`


按照文档中所说的，在项目的gitlab -> setting -> CI/CD -> expand runner。


即可看到

```
Set up a specific Runner manually
Install GitLab Runner
Specify the following URL during the Runner setup: https://git.corp.kuaishou.com/ 
Use the following registration token during setup: xxthisxxisxxyourxxtoken 
Start the Runner!
```

在命令行中运行`gitlab-runner register`

1. Please enter the gitlab-ci coordinator URL (e.g. https://gitlab.com/): 填入`Set up a specific Runner manually`中给出的URL
2. Please enter the gitlab-ci token for this runner: 填入`Set up a specific Runner manually`给出的registration token
3. Please enter the gitlab-ci description for this runner: 给runner设置一些描述
4. Please enter the gitlab-ci tags for this runner (comma separated): 给runner设置标签，这里的标签很有用处。下面会依赖到这个标签(tag)。最好设置得唯一且好记
5. Please enter the executor: shell, virtualbox, docker-ssh+machine, kubernetes, docker, docker-ssh, ssh, docker+machine, custom, parallels: 选择runner的执行器，这里我们选择shell，后面配置的.yml中的script都是shell编写的

看到命令行提示：

```
Runner registered successfully. Feel free to start it, but if it's running already the config should be automatically reloaded! 
```

刷新一下gitlab的setting->CI/CD。 在`Specific Runners`下即可看到我们刚刚注册的服务器了。

## 0x02 config

下面进行我们的正题，`gitlab-ci`提供了`.gitlab-ci.yml`的配置文件用来描述具体`CI`的执行逻辑。

关于`.gitlab-ci.yml`的一些配置项和语法，可以参见[官方文档](https://docs.gitlab.com/ee/ci/yaml/README.html)

这里介绍几个简单的概念：

* [stage](https://docs.gitlab.com/ee/ci/yaml/README.html#stage) 定义一组job，顺序执行。默认有`test`。我们可以根据自己需求定义。
* [tags](https://docs.gitlab.com/ee/ci/yaml/README.html#tags) 这里的tag就可以用来指定我们刚刚注册的`specific runner`。做来确保CI任务执行在我们指定的服务器上
* [cache](https://docs.gitlab.com/ee/ci/yaml/README.html#cache) pipeline中每个一个job的执行都是隔离的。也就是执行job的时候，当前目录文件都是重新clone的，为了加速。我们可以定义job的cache，指定某些文件目录不被清理。比如在install&build阶段指定cache Pods目录，下一步job就可以不用操作pod install了。

定义.gitlab-ci.yml中的stages

目前，我给项目设置了两个stages： build和test。后面会计划新增lint和analyzer。

 * build 就是正常的编译构建，可以检查出提交是否带有编译期问题

 * lint 可以理解为是严格版的编译构建，会检查一些特定编写rule的规则，来防止程序恶化

 * analyzer 也是一种lint，静态分析防止程序恶化

 * test 就是运行工程的单元测试,检查运行时的问题，并产出代码覆盖率报告

 ```yaml
 stages:
  - build
  - test

build_project:
  stage : build
  tags :
    - gmy
  before_script : 
    - pushd Example && bundle install && bundle exec pod install && popd
  script : xcodebuild clean build -workspace Example/Azeroth.xcworkspace -scheme Azeroth-Example 
  cache : 
    paths :
      - Example/Pods/*
      - Example/Azeroth.xcworkspace/*

test_project:
  stage : test
  tags :
    - gmy
  script : xcodebuild test -workspace Example/Azeroth.xcworkspace -scheme Azeroth-Example -destination 'platform=iOS Simulator,id=28EC8848-EC7E-4AB2-B797-2AEB9426F00A' -enableCodeCoverage YES
  allow_failure : true
 ```
 

## 0x09 other

一些小tips

1. 在项目的`pipeline`中有关于`gitlab-ci.yml`的`CI lint`。在对语法和字段拿捏不准的时候，可以通过lint工具来检验，而不用通过提交修改触发CI来运行校验。

2. 可以在commit message中加 [ci skip](https://docs.gitlab.com/ee/ci/yaml/README.html#skip-pipeline)来指定这次提交不出发CI