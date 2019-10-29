Catalog
=================

   * [流媒体推拉流模块](#流媒体推拉流模块)
   		* [功能](#功能)
      * [第三方开源](#第三方开源)
      * [Demo](#Demo)
      * [Demo 安装包](#Demo-安装包)
      * [Demo 使用方法](#Demo-使用方法)
      * [Demo iOS Project](#Demo-iOS-Project)
      * [Demo iOS Snapshot](#Demo-iOS-Snapshot)
      * [Demo Android Project](#Demo-Android-Project)
      * [Demo Android Snapshot](#Demo-Android-Snapshot)
      
      
# 流媒体推拉流模块
## 功能
- 支持iOS/Android
- 支持RTMP传输协议
- 支持h264视频编解码(软硬编解码自适应, 也可以指定)
- 支持aac音频编解码(软编解码)
- 支持自定义滤镜,自带简单美颜和抖音效果等滤镜
- 支持人面识别和自定义挂件(未完成)
- 支持linux下RTMP拉流客户端(可以用于压力测试)


## 第三方开源
[FFmpeg](https://ffmpeg.org/)</br>
[FFmpeg Wiki](https://en.wikipedia.org/wiki/FFmpeg)</br>
[x264](https://www.videolan.org/developers/x264.html)</br>
[x264 Wiki](https://en.wikipedia.org/wiki/X264)</br>
[fdk-aac](https://github.com/mstorsjo/fdk-aac)</br>
[fdk-aac Wiki](https://en.wikipedia.org/wiki/Fraunhofer_FDK_AAC)</br>
[srs](https://github.com/ossrs/srs)</br>
[srs.librtmp](https://github.com/ossrs/srs-librtmp)</br>
[OpenGL_ES Wiki](https://en.wikipedia.org/wiki/OpenGL_ES)</br>
[Dlib](http://dlib.net/)</br>


## Demo
### 安装包
[Android-apk](https://github.com/KingsleyYau/LiveClient/blob/master/docs/coollive.apk)


### Demo 使用方法
* 播放地址为输入框的地址增加序号, 如输入框为rtmp://172.25.32.17:19351/live/max
* 则实际播放地址为rtmp://172.25.32.17:19351/live/max0, rtmp://172.25.32.17:19351/live/max1, rtmp://172.25.32.17:19351/live/max2


### Filter Effect
-------------
<img width="100" height="100" src="https://github.com/KingsleyYau/LiveClient/blob/master/res/effect/0.png?raw=true"/><img width="100" height="100" src="https://github.com/KingsleyYau/LiveClient/blob/master/res/effect/1.png?raw=true"/><img width="100" height="100" src="https://github.com/KingsleyYau/LiveClient/blob/master/res/effect/2.png?raw=true"/>
<img width="100" height="100" src="https://github.com/KingsleyYau/LiveClient/blob/master/res/effect/3.png?raw=true"/><img width="100" height="100" src="https://github.com/KingsleyYau/LiveClient/blob/master/res/effect/5.png?raw=true"/><img width="100" height="100" src="https://github.com/KingsleyYau/LiveClient/blob/master/res/effect/6.png?raw=true"/>
<img width="100" height="100" src="https://github.com/KingsleyYau/LiveClient/blob/master/res/effect/7.png?raw=true"/>
### Demo iOS Project
https://github.com/KingsleyYau/LiveClient/tree/master/iOS/Modules/RtmpClient/RtmpClientTest


### Demo iOS Snapshot
-------------
![](https://github.com/KingsleyYau/LiveClient/blob/master/res/IMG_iOS_1.PNG?raw=true)


### Demo Android Project
https://github.com/KingsleyYau/LiveClient/tree/master/android/coollive_studio


### Demo Android Snapshot
-------------
![](https://github.com/KingsleyYau/LiveClient/blob/master/res/IMG_Android_1.png?raw=true)

