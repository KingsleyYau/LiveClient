package com.qpidnetwork.anchor.utils;

import android.content.Context;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Vibrator;

import java.io.IOException;

/**
 * 消息提示音和振动管理类
 * @author Jagger 2019-9-17
 */
public class BeepAndVibrateUtil {
    private Context mContext;
    private MediaPlayer mMediaPlayer;
    private Uri uri;

    public BeepAndVibrateUtil(Context context){
        mContext = context;
        //手机设置的默认提示音
        uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
    }

    /**
     * 播放提示音
     */
    public void playBeep(){
        boolean shouldPlayBeep = true;

        //用户是否选择了无声的模式
        AudioManager audioService = (AudioManager) mContext
                .getSystemService(Context.AUDIO_SERVICE);
        if (audioService.getRingerMode() != AudioManager.RINGER_MODE_NORMAL) {
            shouldPlayBeep = false;
        }

        if(shouldPlayBeep){
            if (mMediaPlayer != null) {
                mMediaPlayer.stop();
            }

            mMediaPlayer = new MediaPlayer();
            //设入播放器中
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            try {
                mMediaPlayer.setDataSource(mContext, uri);
                mMediaPlayer.prepare();
            } catch (IOException ioe) {
                mMediaPlayer = null;
            }
            if (mMediaPlayer != null) {
                mMediaPlayer.start();
            }
        }
    }

    /**
     * 震动
     */
    public void playVibrate(){
        Vibrator vibrator = (Vibrator)mContext.getSystemService(Context.VIBRATOR_SERVICE);
        //第一个参数，指代一个震动的频率数组。每两个为一组，每组的第一个为等待时间，第二个为震动时间。
        //        比如  [2000,500,100,400],会先等待2000毫秒，震动500，再等待100，震动400
        //第二个参数，repeat指代从 第几个索引（第一个数组参数） 的位置开始循环震动。-1表示不循环
        //会一直保持循环，我们需要用 vibrator.cancel()主动终止
        vibrator.vibrate(new long[]{0,500},-1);
    }
}
