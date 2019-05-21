package net.qdating.player;

import android.opengl.GLSurfaceView;

import net.qdating.LSConfig;
import net.qdating.filter.LSImageFilter;

/**
 * 渲染绑定器
 * 绑定SurfaceView和Renderer
 *
 * @author max
 */
public class LSPlayerRendererBinder {
    /**
     * 预览界面
     */
    protected GLSurfaceView playerSurfaceView = null;
    /**
     * 预览硬解渲染器
     */
    protected LSVideoHardPlayerRenderer playerHardRenderer = null;
    /**
     * 预览软解渲染器
     */
    protected LSVideoPlayerRenderer playerRenderer = null;
    /**
     * 是否使用硬解码
     */
    protected boolean useHardDecoder = false;

    /**
     * 创建渲染绑定器
     * @param surfaceView   界面
     * @param fillMode      渲染模式
     */
    public LSPlayerRendererBinder(GLSurfaceView surfaceView, LSConfig.FillMode fillMode) {
        init(surfaceView, fillMode, LSConfig.decodeMode);
    }

    public LSPlayerRendererBinder(GLSurfaceView surfaceView, LSConfig.FillMode fillMode, LSConfig.DecodeMode decodeMode) {
        init(surfaceView, fillMode, decodeMode);
    }

    private void init(GLSurfaceView surfaceView, LSConfig.FillMode fillMode, LSConfig.DecodeMode decodeMode) {
        if( decodeMode == LSConfig.DecodeMode.DecodeModeAuto ) {
            if( LSVideoHardDecoder.supportHardDecoder() ) {
                // 判断可以使用硬解码
                useHardDecoder = true;
            }
        } else if( decodeMode == LSConfig.DecodeMode.DecodeModeHard ) {
            // 强制使用硬解码
            useHardDecoder = true;
        }

        GLSurfaceView.Renderer renderer = null;
        if( useHardDecoder ) {
            // 初始化视频硬渲染器
            this.playerHardRenderer = new LSVideoHardPlayerRenderer(fillMode);
            this.playerHardRenderer.init();
            renderer = playerHardRenderer;
        } else {
            // 初始化视频播放器
            this.playerRenderer = new LSVideoPlayerRenderer(fillMode);
            this.playerRenderer.init();
            renderer = playerRenderer;
        }

        // 设置GL预览界面, 按照顺序调用, 否则crash
        this.playerSurfaceView = surfaceView;
        this.playerSurfaceView.setEGLContextClientVersion(2);
        this.playerSurfaceView.setRenderer(renderer);
        this.playerSurfaceView.setRenderMode(GLSurfaceView.RENDERMODE_WHEN_DIRTY);
        this.playerSurfaceView.setPreserveEGLContextOnPause(true);
    }

    /**
     * 设置自定义滤镜
     * @param customFilter 自定义滤镜
     */
    public void setCustomFilter(LSImageFilter customFilter) {
        if( useHardDecoder ) {
            if (playerHardRenderer != null) {
                playerHardRenderer.setCustomFilter(customFilter);
            }
        } else {
            if( playerRenderer != null ) {
                playerRenderer.setCustomFilter(customFilter);
            }
        }
    }

    /**
     * 获取自定义滤镜
     * @return 自定义滤镜
     */
    public LSImageFilter getCustomFilter() {
        LSImageFilter filter = null;
        if( useHardDecoder ) {
            if (playerHardRenderer != null) {
                filter = playerHardRenderer.getCustomFilter();
            }
        } else {
            if( playerRenderer != null ) {
                filter = playerRenderer.getCustomFilter();
            }
        }
        return filter;
    }
}
