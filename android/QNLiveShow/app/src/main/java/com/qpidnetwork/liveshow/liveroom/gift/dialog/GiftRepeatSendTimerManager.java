package com.qpidnetwork.liveshow.liveroom.gift.dialog;

import com.qpidnetwork.utils.Log;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Description:礼物列表连送按钮倒计时定时器管理类
 * <p>
 * Created by Harry on 2017/6/28.
 */

public class GiftRepeatSendTimerManager {
    private final String TAG = GiftRepeatSendTimerManager.class.getSimpleName();
    private static GiftRepeatSendTimerManager instance = null;
    private OnTimerTaskExecuteListener onTimerTaskExecuteListener;
    private long delayTime = 0l;
    private long periodTime = 0l;
    private int startCount = 0;
    private Timer repeatSendTimer = null;
    private TimerTask repeatSentTimerTask = null;
    private ExecuteStatus executeStatus = ExecuteStatus.Default;

    /**
     * 执行状态
     */
    public enum ExecuteStatus{
        Default,
        Executing,
        End
    }

    /**
     * 私有构造函数
     */
    private GiftRepeatSendTimerManager(){}

    /**
     *设置任务执行监听器
     @param onTimerTaskExecuteListener
     */
    public void setOnTimerTaskExecuteListener(OnTimerTaskExecuteListener onTimerTaskExecuteListener){
        this.onTimerTaskExecuteListener = onTimerTaskExecuteListener;
    }

    /**
     * 获取GiftRepeatSendTimerManager实例
     * @return
     */
    public static GiftRepeatSendTimerManager getInstance(){
        if(null == instance){
            instance = new GiftRepeatSendTimerManager();
        }

        return instance;
    }

    /**
     * 启动定时器
     * @param startCount 起始计数
     * @param totalTime 总任务时长
     */
    public void start(int startCount,long totalTime){
        stop();
        Log.d(TAG,"start");
        if(ExecuteStatus.End == instance.executeStatus){
            this.periodTime = totalTime/startCount;
            this.startCount = startCount;
        }

        resume();
    }

    /**
     * 恢复未执行完的定时器任务
     */
    public void resume(){
        if(null != instance && startCount>=0){
            if(null == repeatSendTimer && null == repeatSentTimerTask){
                repeatSendTimer = new Timer();
                repeatSentTimerTask = new TimerTask() {
                    @Override
                    public void run() {
                        instance.startCount = instance.startCount>=0 ? instance.startCount : 0;

                        if(0 == instance.startCount){
                            if(null != onTimerTaskExecuteListener){
                                onTimerTaskExecuteListener.onTaskEnd();
                            }
                            Log.d(TAG,"onTaskEnd-startCount:"+instance.startCount);
                            stop();
                        }else {
                            if(null != onTimerTaskExecuteListener){
                                onTimerTaskExecuteListener.onTaskExecute(instance.startCount);
                            }
                            Log.d(TAG,"onTaskExecute-startCount:"+instance.startCount);
                            instance.startCount -=1;
                        }
                    }
                };
            }

            repeatSendTimer.schedule(repeatSentTimerTask,delayTime,periodTime);
            instance.executeStatus = ExecuteStatus.Executing;
        }
        Log.d(TAG,"resume");
    }

    /**
     * 关闭定时器
     */
    public void stop(){
        if(null != repeatSendTimer && null != repeatSendTimer){
            repeatSentTimerTask.cancel();
            repeatSendTimer.cancel();
            repeatSendTimer = null;
            repeatSentTimerTask = null;
        }
        instance.executeStatus = ExecuteStatus.End;
        Log.d(TAG,"stop");
    }
}
