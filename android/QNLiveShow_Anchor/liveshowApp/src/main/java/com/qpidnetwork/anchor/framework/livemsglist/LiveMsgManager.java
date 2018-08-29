package com.qpidnetwork.anchor.framework.livemsglist;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Jagger on 2017/6/1.
 */

public class LiveMsgManager<T extends Object> {
    private int MAX_MSG_SUM = 30;                           //列表 、 缓存 各最大保存消息数据
    private int GET_FROM_CACHE_EVERYTIME = 10;              //每次从缓存中取多少条
    private List<T> mCacheDummyItems = new ArrayList<T>();  //缓存
    private int mUnreadSum = 0;                             //未读数

    /**
     * 列表 、 缓存 各最大保存消息数据
     * @param maxMsgSum
     */
    public void setMAX_MSG_SUM(int maxMsgSum){
        MAX_MSG_SUM = maxMsgSum;
    }

    /**
     * 加入新数据
     * @param dummyItems
     * @param item
     * @param isPlaying 列表是否正在播放文字（滑动到最底部 代表正在播放）
     * @return  是否有新数据加到列表中
     */
    public boolean addNewMsg(List<T> dummyItems , T item , boolean isPlaying){
        boolean result = true;
        //列表数据没爆时
        if(dummyItems.size() < MAX_MSG_SUM){
            //正常加入数据
            dummyItems.add(item);
            result = true;
            //不在播放时，未读数+1
            if(!isPlaying){
                mUnreadSum ++;
            }
        }else {
            //列表数据已满,当列表在底部时，正常插入删除、数据
            if(isPlaying){
                //删除最旧的数据
                dummyItems.remove(0);
                //插入新数据
                dummyItems.add(item);
                result = true;
            }else{
                //列表没滑动到最底,如果缓存也爆了
                if(mCacheDummyItems.size() >= MAX_MSG_SUM){
                    //删掉最旧的数据
                    mCacheDummyItems.remove(0);
                }
                //把新数据加到缓存
                mCacheDummyItems.add(item);
                mUnreadSum ++;
                result = false;
            }
        }
        return result;
    }

    /**
     * 在缓存中取数据
     * @param dummyItems
     * @return 缓存中是否有数据插入到列表中
     */
    public boolean getFromCache(List<T> dummyItems ){
        boolean result = false;
        //缓存数据很多了，
        //从缓存数据取出每次加入上限（GET_FROM_CACHE_EVERYTIME）条数 插入列表
//        if(mCacheDummyItems.size() > GET_FROM_CACHE_EVERYTIME){
//            for(int i = 0 ; i < GET_FROM_CACHE_EVERYTIME ; i++){
//                result = getOneFromCache(dummyItems );
//            }
//        }else if(mCacheDummyItems.size() > 0){  //缓存也不是很多时，把它们全插入列表
//            for(int i = 0 ; i < mCacheDummyItems.size() ; i++) {
//                dummyItems.remove(0);
//            }
//            dummyItems.addAll(mCacheDummyItems);
//            mCacheDummyItems.clear();
//            result = true;
//        }

        if(mCacheDummyItems.size() > 0) {
            for (int i = 0; i < mCacheDummyItems.size(); i++) {
                dummyItems.remove(0);
            }
            dummyItems.addAll(mCacheDummyItems);
            mCacheDummyItems.clear();
            result = true;
        }
        return result;
    }

    /**
     * 在缓存中 一条条数据插入列表中
     * @param dummyItems
     * @return
     */
    private boolean getOneFromCache(List<T> dummyItems ){
        boolean result = false;
            if(mCacheDummyItems.size() > 0){
                //删除最旧的数据
                dummyItems.remove(0);
                //插入缓存中最旧的数据
                dummyItems.add(mCacheDummyItems.get(0));
                //删除缓存中最旧的数据
                mCacheDummyItems.remove(0);
                result = true;
            }
        return result;
    }

    /**
     * 取未读消息数
     * @return
     */
    public int getUnreadSum(){
        return mUnreadSum;
    }

    /**
     * 已读过所有消息
     * （把未读数设置为0）
     */
    public void setReadAll(){
        mUnreadSum = 0 ;
    }

    /**
     * 取本地缓存最后一条数据
     * @return
     */
    public Object getLastCacheItem(){
        Object item = null;
        if(mCacheDummyItems != null && mCacheDummyItems.size() > 0){
            item = mCacheDummyItems.get(mCacheDummyItems.size() - 1);
        }
        return item;
    }

}
