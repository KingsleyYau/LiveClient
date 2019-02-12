package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.Timer;
import java.util.TimerTask;

/**
 * Description:礼物列表连送按钮倒计时定时器管理类
 * <p>
 * Created by Harry on 2017/6/28.
 */

public class GiftRepeatSendTimerManager {
    private final String TAG = GiftRepeatSendTimerManager.class.getSimpleName();
    private OnTimerTaskExecuteListener onTimerTaskExecuteListener;
    private long periodTime = 0l;
    private int startCount = 0;
    private Timer repeatSendTimer = null;
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
    public GiftRepeatSendTimerManager(){

    }

    /**
     *设置任务执行监听器
     @param onTimerTaskExecuteListener
     */
    public void setOnTimerTaskExecuteListener(OnTimerTaskExecuteListener onTimerTaskExecuteListener){
        this.onTimerTaskExecuteListener = onTimerTaskExecuteListener;
    }

    /**
     * 启动定时器
     * @param startCount 起始计数
     * @param period     定时器间隔
     */
    public void start(int startCount, long period){
        Log.d(TAG,"start");
        stop();
        this.startCount = startCount;
        this.periodTime = period;
        startInternal();
    }

    /**
     * 内部启动定时器
     */
    public void startInternal(){
        if(startCount > 0){
            TimerTask repeatSentTimerTask = new TimerTask() {
                @Override
                public void run() {
                    if(executeStatus != ExecuteStatus.End){
                        if(0 == startCount){
                            stop();
                            if(null != onTimerTaskExecuteListener){
                                onTimerTaskExecuteListener.onTaskEnd();
                            }
                            Log.d(TAG,"onTaskEnd-startCount:" + startCount);
                        }else {
                            if(null != onTimerTaskExecuteListener){
                                onTimerTaskExecuteListener.onTaskExecute(startCount);
                            }
                            Log.d(TAG,"onTaskExecute-startCount:" + startCount);
                            startCount -=1;
                        }
                    }
                }
            };
            repeatSendTimer = new Timer();
            repeatSendTimer.schedule(repeatSentTimerTask , 0, periodTime);
            executeStatus = ExecuteStatus.Executing;
        }
    }

    /**
     * 定时器是否运行中
     * @return
     */
    public boolean isRunning(){
        return executeStatus != ExecuteStatus.End;
    }

    /**
     * 关闭定时器
     */
    public void stop(){
        Log.d(TAG,"stop");
        executeStatus = ExecuteStatus.End;
        //回收资源
        if(null != repeatSendTimer ){
            //停止定时器
            repeatSendTimer.cancel();
        }
    }
}
