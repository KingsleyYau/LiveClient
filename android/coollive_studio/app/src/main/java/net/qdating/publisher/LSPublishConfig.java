package net.qdating.publisher;

import net.qdating.LSConfig;

public class LSPublishConfig {
    /**
     * 视频宽度(摄像头参数)
     */
    public int videoCaptureWidth = 480;
    /**
     * 视频高度(摄像头参数)
     */
    public int videoCaptureHeight = 640;
    /**
     * 视频宽度(推流参数)
     * 大部分硬编码器要求是4的倍数, 有些要求其他, 但都是2的指数
     */
    public int videoWidth = 240;
    /**
     * 视频高度(推流参数)
     * 大部分硬编码器要求是4的倍数, 有些要求其他, 但都是2的指数
     */
    public int videoHeight = 240;
    /**
     * 码率(推流参数)
     */
    public int videoBitrate = 500 * 1000;
    /**
     * 视频帧率(推流参数)
     */
    public int videoFps = 12;
    /**
     * 视频关键帧间隔(推流参数)
     */
    public int videoKeyFrameInterval = videoFps;
    /**
     * 音频PCM采样率
     */
    public int audioSampleRate = 44100;
    /**
     * 音频PCM声道
     */
    public int audioChannelPerFrame = 1;
    /**
     * 音频PCM精度
     */
    public int audioBitPerSample = 16;
    /**
     * 设置推流参数
     * @param videoConfigType
     * @return 成功失败
     */
    public boolean updateVideoConfig(LSConfig.VideoConfigType videoConfigType, int fps, int keyFrameInterval, int videoBitrate) {
        boolean bFlag = true;
        switch (videoConfigType) {
            case VideoConfigType120x160:{
                videoCaptureWidth = 480;
                videoCaptureHeight = 640;
                videoWidth = 120;
                videoHeight = 160;
            }break;
            case VideoConfigType240x240:{
                videoCaptureWidth = 480;
                videoCaptureHeight = 640;
                videoWidth = 240;
                videoHeight = 240;
            }break;
            default:{
                bFlag = false;
            }break;
        }
        return bFlag;
    }
}
