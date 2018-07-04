# 目录

 * [Why](http://git.corp.kuaishou.com/kwik-app/Kwai-Univerasl-Framework#why)
 * How
    * [Install](http://git.corp.kuaishou.com/kwik-app/Kwai-Univerasl-Framework#install)
    * [Create](http://git.corp.kuaishou.com/kwik-app/Kwai-Univerasl-Framework#create)




## Why

2018.7.3 基于 `kwik-ios master`分支 全量编译构建共耗时`Total   430.9955s`

其中大头的时间开销主要集成在 源码文件编译环节：

```
   12.1702s   ▸ Processing Info.plist
   9.5760s   ▸ Linking Kwik
   4.7315s   ▸ Copying GPUImageLowPassFilter.h
   4.2080s   ▸ Compiling KSYRecordViewController.mm
   4.1847s   ▸ Compiling KSRechargeBtnCell.xib
   4.1515s   ▸ Copying GPUImageKuwaharaFilter.h
   3.7737s   ▸ Compiling KSCDNSelector.mm
   3.7553s   ▸ Check Dependencies
   3.7308s   ▸ Building library libBlocksKit.a
   3.7115s   ▸ Compiling KSYRecordViewController.mm
   3.6835s   ▸ Compiling KSUIDCSelector.mm
   3.3441s   ▸ Copying GPUImageGrayscaleFilter.h
   3.3254s   ▸ Copying GPUImageHistogramGenerator.h
   3.2247s   ▸ Copying GPUImageMosaicFilter.h
   3.1561s   ▸ Compiling KSUIDCSelector.mm
   3.1407s   ▸ Copying GPUImageLevelsFilter.h
   3.0847s   ▸ Copying GPUImageSkinToneFilter.h
   3.0794s   ▸ Copying GPUImageBilateralFilter.h
   3.0770s   ▸ Copying GPUImageLuminosity.h
   3.0588s   ▸ Copying GPUImageLightenBlendFilter.h
   2.9790s   ▸ Compiling KSCameraView.mm
   2.9601s   ▸ Copying GPUImageHighlightShadowTintFilter.h
   2.9202s   ▸ Check Dependencies
   2.9017s   ▸ Compiling KwikHomeCollectionVC.m
   2.7587s   ▸ Copying GPUImageSphereRefractionFilter.h
   2.7400s   ▸ Compiling LaunchScreen.storyboard
   2.6930s   ▸ Compiling FMEffectParser.cpp
   2.6681s   ▸ Copying GPUImageLanczosResamplingFilter.h
   2.6286s   ▸ Compiling FMTriggerManager.cpp
   2.6084s   ▸ Copying GPUImageColorBurnBlendFilter.h
   2.5814s   ▸ Copying GPUImageHarrisCornerDetectionFilter.h
   2.5081s   ▸ Copying GPUImageMotionBlurFilter.h
   2.5058s   ▸ Compiling FMEffectHandler.cpp
   2.4810s   ▸ Copying GPUImageOpacityFilter.h
   2.4434s   ▸ Copying GPUImageLinearBurnBlendFilter.h
   2.4251s   ▸ Copying GPUImageGlassSphereFilter.h
   2.4028s   ▸ Copying GPUImageHSBFilter.h
   2.3765s   ▸ Copying GPUImageHueBlendFilter.h
   2.3699s   ▸ Copying GPUImageMissEtikateFilter.h
   2.2884s   ▸ Compiling KwiKProfileViewController.m
   2.2077s   ▸ Copying GPUImageMonochromeFilter.h
   2.2019s   ▸ Compiling KSCDNSelector.mm
   2.1968s   ▸ Compiling KSYRecordAdjustView.mm
   2.1942s   ▸ Compiling KSCameraView.mm
   2.0880s   ▸ Compiling FMVPBeautifyV2Filter.mm
   2.0779s   ▸ Cleaning Pods/BlocksKit [Release]
   2.0360s   ▸ Compiling FMFaceDeformFilter2.mm
   2.0013s   ▸ Copying GPUImageHighPassFilter.h
   1.9974s   ▸ Compiling FMNeonEffect.cpp
   1.9787s   ▸ Copying GPUImageHistogramFilter.h
   1.9561s   ▸ Compiling track_video_decode_service.cc
   1.9470s   ▸ Copying GPUImageSubtractBlendFilter.h
   1.8699s   ▸ Copying GPUImageContrastFilter.h
```

Static Library

> files are linked at build time. code is copied into the executable. Code in the library that isn't referenced by your program is removed. A program with only static libraries doesn't have any dependencies during runtime.

而如果是 staticlib(framework)的话，在构建阶段只有链接工作。所以相对会节约不少构建时间。


## Install 


`git clone git@git.corp.kuaishou.com:guomiaoyou/Kwai-Univerasl-Framework.git`

进入`Kwai-Univerasl-Framework`目录下执行 `install.sh`

```
chmod 777 install.sh && ./install.sh
```

![install](http://git.corp.kuaishou.com/guomiaoyou/Kwai-Univerasl-Framework/raw/master/Shoot/install.png)


按照提示，重新启动你的Xcode。


## Create

重启Xcode之后，选择 `Create a new Xcode Project`，在iOS Templates菜单中会发现有 `Kwai Cocoa Touch Univerasl` 这个工程模板。

![Template](http://git.corp.kuaishou.com/kwik-app/Kwai-Univerasl-Framework/raw/master/Shoot/template.png)


基于该模板工程开始搭建你的模块吧。选择 `Univerasl Framework Target` 将会构建出全架构的`framework`

![DEMO](http://git.corp.kuaishou.com/guomiaoyou/Kwai-Univerasl-Framework/raw/master/Shoot/lipo.png)

如图所示，`Demo.framework` 最终的构建产物分别包含了真机 `armv7,armv7s,arm64` CPU架构 和 模拟器`i386,X86_64`CPU架构