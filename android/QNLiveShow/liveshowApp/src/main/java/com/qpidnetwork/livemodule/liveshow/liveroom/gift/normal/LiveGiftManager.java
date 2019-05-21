package com.qpidnetwork.livemodule.liveshow.liveroom.gift.normal;

import com.qpidnetwork.livemodule.im.listener.IMMessageItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

import java.util.ArrayList;

/**
 * 保存所有礼物
 * 通知控件（LiveGiftView）更新礼物连击数 或 有新礼物(+)
 * 由控件（LiveGiftView）控制移除礼物(-)
 * Created by Jagger on 2017/6/8.
 */

public class LiveGiftManager {
    public int MAX_SHOW_GIFT_SUM = 2;

    private ArrayList<LiveGift> mGiftShowList = new ArrayList<>(); //正在显示的礼物
    private ArrayList<LiveGift> mGiftCacheList = new ArrayList<>(); //待显示的礼物
    private ArrayList<onGiftStateChangeListener> mOnGiftStateChangeListeners = new ArrayList<>(); //

    public LiveGiftManager(){

    }

    /**
     * 注册监听
     * @param listener
     */
    public void registerOnGiftStateChangeLinstener(onGiftStateChangeListener listener){
        mOnGiftStateChangeListeners.add(listener);
        Log.i("Jagger" , "registerOnGiftStateChangeLinstener:" + listener.getClass().getSimpleName());
    }

    /**
     * 反注册监听
     * @param listener
     */
    public void unregisterOnGiftStateChangeLinstener(onGiftStateChangeListener listener){
        mOnGiftStateChangeListeners.remove(listener);
    }

    /**
     * 清空监听
     */
    private void removeAllOnGiftStateChangeLinstener(){
        mOnGiftStateChangeListeners.clear();
    }

    /**
     * 来了一个新礼物/重复送了礼物
     * @param liveGift
     */
    public void addLiveGift(LiveGift liveGift){
        IMMessageItem imMessageItem = (IMMessageItem)liveGift.getObj();

        //显示的列表中是否有该礼物
        for (LiveGift itemShow: mGiftShowList ) {
            //有且该礼物可以连击,则加入连击数
            if(itemShow.getGiftId().equals(liveGift.getGiftId()) && imMessageItem.giftMsgContent.multi_click){
                itemShow.setNewRange(liveGift.getmNewClickRange());

                //回调
                for (onGiftStateChangeListener listener:
                        mOnGiftStateChangeListeners) {
                    listener.onUpdateGiftRange(itemShow , liveGift.getmNewClickRange());
                }

                return;
            }
        }

        //待显示的列表中是否有该礼物
        for (LiveGift itemShow: mGiftCacheList ) {
            //有且该礼物可以连击, 则加入连击数
            if(itemShow.getGiftId().equals(liveGift.getGiftId()) && imMessageItem.giftMsgContent.multi_click){
                itemShow.setNewRange(liveGift.getmNewClickRange());
                return;
            }
        }

        //如果显示中礼物过多，则加入待显示列表中
        if(mGiftShowList.size() >= MAX_SHOW_GIFT_SUM){
            mGiftCacheList.add(liveGift);
        }else {
            //加入显示列表中
            mGiftShowList.add(liveGift);

            //回调
            for (onGiftStateChangeListener listener:
                    mOnGiftStateChangeListeners) {
                listener.onAddNewGift(liveGift);
            }
        }
    }

    /**
     * 移除在显示列表中的一个礼物（这个送礼物动画结束了）
     * @param liveGift
     */
    public void removeLiveGift(LiveGift liveGift){
        for (LiveGift itemShow: mGiftShowList ) {
            //在显示列表中找到这个礼物
            if(itemShow.getGiftId().equals(liveGift.getGiftId())){
                mGiftShowList.remove(itemShow);
                break;
            }
        }

        //待显示列表中有礼物
        if(mGiftCacheList.size() > 0){
            //加入到显示列表中
            mGiftShowList.add(mGiftCacheList.get(0));
            //从待显示列表里的移除
            mGiftCacheList.remove(0);

            //回调
            for (onGiftStateChangeListener listener:
                    mOnGiftStateChangeListeners) {
                listener.onAddNewGift(mGiftShowList.get(mGiftShowList.size() - 1)); //新加入的 回调出去
            }
        }

    }

    /**
     * 清空礼物数据
     */
    public void clean(){
        mGiftCacheList.clear();
        mGiftShowList.clear();
    }

    /**
     * 销毁
     */
    public void destroy(){
        clean();
        removeAllOnGiftStateChangeLinstener();
    }

    /**
     * 礼物状态变化接口
     */
    public interface onGiftStateChangeListener {
        /**
         * 要更新一个礼物的连击数
         */
        void onUpdateGiftRange(LiveGift liveGift, LiveGift.ClickRange newClickRange);

        /**
         * 加入一个礼物
         */
        void onAddNewGift(LiveGift liveGift);
    }

}
