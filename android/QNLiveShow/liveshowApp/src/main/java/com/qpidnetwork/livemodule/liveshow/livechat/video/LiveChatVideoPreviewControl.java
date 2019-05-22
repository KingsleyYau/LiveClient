package com.qpidnetwork.livemodule.liveshow.livechat.video;

import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.SeekBar;

import com.qpidnetwork.livemodule.R;
import com.xiao.nicevideoplayer.NiceVideoPlayer;
import com.xiao.nicevideoplayer.NiceVideoPlayerController;
import com.xiao.nicevideoplayer.TxVideoPlayerController;

/**
 * Created by Hardy on 2019/5/10.
 * LiveChat 视频播放的控制器
 */
public class LiveChatVideoPreviewControl extends NiceVideoPlayerController implements View.OnClickListener, SeekBar.OnSeekBarChangeListener {

    private static final String TAG = TxVideoPlayerController.class.getSimpleName();

    private Context mContext;

    private SeekBar mSeek;
    private ImageView mRestartPause;

    private boolean isOpenNoVideoFilePathCheck;
    private OnPlayOperaListener mOnPlayOperaListener;

    public void setOnPlayOperaListener(OnPlayOperaListener mOnPlayOperaListener) {
        this.mOnPlayOperaListener = mOnPlayOperaListener;
    }

    public interface OnPlayOperaListener {

        void onVideoPreparing();

        /**
         * 视频播放开始
         */
        void onVideoStart();

        /**
         * 视频播放暂停
         */
        void onVideoPause();

        /**
         * 视频播放结束
         */
        void onVideoCompleted();

        /**
         * 视频内容区域点击事件
         */
        void onVideoContentClick();

        /**
         * 针对本地视频文件时，是否没有文件,是否拦截播放按钮的点击事件
         * 默认外层设置进来，是存在的，不拦截
         *
         * @return
         */
        boolean isVideoFileExists();
    }


    public LiveChatVideoPreviewControl(Context context) {
        super(context);
        mContext = context;
        init();
    }

    private void init() {
        this.setOnClickListener(this);
    }

    public void setOperaView(SeekBar mSeek, ImageView mRestartPause) {
        this.mSeek = mSeek;
        this.mRestartPause = mRestartPause;

        this.mRestartPause.setOnClickListener(this);
        this.mSeek.setOnSeekBarChangeListener(this);
    }

    /**
     * 自动触发播放视频
     */
    public void start() {
        mRestartPause.performClick();
    }

    /**
     * 针对本地视频文件时，是否没有文件,是否拦截播放按钮的点击事件
     * 默认外层设置进来，是存在的，不拦截
     *
     * @return
     */
    public void setOpenNoVideoFilePathCheck(boolean openNoVideoFilePathCheck) {
        isOpenNoVideoFilePathCheck = openNoVideoFilePathCheck;
    }

    /**
     * 尽量不要在onClick中直接处理控件的隐藏、显示及各种UI逻辑。
     * UI相关的逻辑都尽量到{@link #onPlayStateChanged}和{@link #onPlayModeChanged}中处理.
     */
    @Override
    public void onClick(View v) {
        if (v == this) {
            // 2019/5/10 回调外层，点击视频区域
            if (mOnPlayOperaListener != null) {
                mOnPlayOperaListener.onVideoContentClick();
            }
        } else if (v == mRestartPause) {
            if (isOpenNoVideoFilePathCheck &&
                    mOnPlayOperaListener != null &&
                    !mOnPlayOperaListener.isVideoFileExists()) {
                return;
            }

            if (mNiceVideoPlayer.isPlaying() || mNiceVideoPlayer.isBufferingPlaying()) {
                mNiceVideoPlayer.pause();
            } else if (mNiceVideoPlayer.isPaused() || mNiceVideoPlayer.isBufferingPaused() || mNiceVideoPlayer.isCompleted()) {
                mNiceVideoPlayer.restart();
            } else if (mNiceVideoPlayer.isError()) {
                Log.i(TAG, "---------------mNiceVideoPlayer--------------error");
                mNiceVideoPlayer.restart();
            } else {
                Log.i(TAG, "---------------mNiceVideoPlayer--------------start");
                mNiceVideoPlayer.start();
            }
        }
    }

    //================= 播放进度条的控制回调  =====================================
    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {

    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {
        if (mNiceVideoPlayer.isBufferingPaused() || mNiceVideoPlayer.isPaused()) {
            mNiceVideoPlayer.restart();
        }
        long position = (long) (mNiceVideoPlayer.getDuration() * seekBar.getProgress() / 100f);
        mNiceVideoPlayer.seekTo(position);
    }

    //================= 播放器的控制  ==================================
    @Override
    protected void onPlayStateChanged(int playState) {
        switch (playState) {
            case NiceVideoPlayer.STATE_IDLE:
                break;

            case NiceVideoPlayer.STATE_PREPARING:
//                mLoading.setVisibility(View.VISIBLE);
//                mLoadText.setText("正在准备...");
//                mError.setVisibility(View.GONE);
//                mCompleted.setVisibility(View.GONE);
//                mCenterStart.setVisibility(View.GONE);
                if (mOnPlayOperaListener != null) {
                    mOnPlayOperaListener.onVideoPreparing();
                }
                break;

            case NiceVideoPlayer.STATE_PREPARED:
                startUpdateProgressTimer();
                break;

            case NiceVideoPlayer.STATE_PLAYING:
//                mLoading.setVisibility(View.GONE);
                mRestartPause.setImageResource(R.drawable.ic_livechat_video_stop_white_small);
//                startDismissTopBottomTimer();

                if (mOnPlayOperaListener != null) {
                    mOnPlayOperaListener.onVideoStart();
                }
                break;

            case NiceVideoPlayer.STATE_PAUSED:
//                mLoading.setVisibility(View.GONE);
                mRestartPause.setImageResource(R.drawable.ic_livechat_video_play_white_small);
//                cancelDismissTopBottomTimer();

                if (mOnPlayOperaListener != null) {
                    mOnPlayOperaListener.onVideoPause();
                }
                break;

            case NiceVideoPlayer.STATE_BUFFERING_PLAYING:
//                mLoading.setVisibility(View.VISIBLE);
                mRestartPause.setImageResource(R.drawable.ic_livechat_video_stop_white_small);
//                mLoadText.setText("正在缓冲...");
//                startDismissTopBottomTimer();

                if (mOnPlayOperaListener != null) {
                    mOnPlayOperaListener.onVideoStart();
                }
                break;

            case NiceVideoPlayer.STATE_BUFFERING_PAUSED:
//                mLoading.setVisibility(View.VISIBLE);
                mRestartPause.setImageResource(R.drawable.ic_livechat_video_play_white_small);
//                mLoadText.setText("正在缓冲...");
//                cancelDismissTopBottomTimer();

                if (mOnPlayOperaListener != null) {
                    mOnPlayOperaListener.onVideoPause();
                }
                break;

            case NiceVideoPlayer.STATE_ERROR:
                cancelUpdateProgressTimer();
//                mTop.setVisibility(View.VISIBLE);
//                mError.setVisibility(View.VISIBLE);
                break;

            case NiceVideoPlayer.STATE_COMPLETED:
                cancelUpdateProgressTimer();
//                long duration = mNiceVideoPlayer.getDuration();
//                mCompleted.setVisibility(View.VISIBLE);

                // 2019/5/10 Hardy
                mRestartPause.setImageResource(R.drawable.ic_player_start);
                mSeek.setProgress(0);
                mSeek.setSecondaryProgress(0);

                if (mOnPlayOperaListener != null) {
                    mOnPlayOperaListener.onVideoCompleted();
                }
                break;
        }
    }

    @Override
    protected void onPlayModeChanged(int i) {

    }

    @Override
    protected void reset() {
        cancelUpdateProgressTimer();
        mSeek.setProgress(0);
        mSeek.setSecondaryProgress(0);

        mRestartPause.setImageResource(R.drawable.ic_livechat_video_play_white_small);
    }

    @Override
    protected void updateProgress() {
        long position = mNiceVideoPlayer.getCurrentPosition();
        long duration = mNiceVideoPlayer.getDuration();
//        int bufferPercentage = mNiceVideoPlayer.getBufferPercentage();
//        mSeek.setSecondaryProgress(bufferPercentage);
        int progress = (int) (100f * position / duration);
        mSeek.setProgress(progress);
    }

    @Override
    protected void showChangePosition(long duration, int newPositionProgress) {
        mSeek.setProgress(newPositionProgress);
    }

    @Override
    protected void hideChangePosition() {

    }

    @Override
    protected void showChangeVolume(int i) {

    }

    @Override
    protected void hideChangeVolume() {

    }

    @Override
    protected void showChangeBrightness(int i) {

    }

    @Override
    protected void hideChangeBrightness() {

    }
}
