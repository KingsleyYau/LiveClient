package com.qpidnetwork.livemodule.liveshow.home;

import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetVoucherAvailableInfoCallback;
import com.qpidnetwork.livemodule.httprequest.item.BindAnchorItem;
import com.qpidnetwork.livemodule.httprequest.item.VoucherItem;
import com.qpidnetwork.livemodule.httprequest.item.VouchorAvailableInfoItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Created by Hunter Mun on 2018/1/24.
 *
 * 参考流程图svn/docs/客户端接口调用流程图/显示free标记流程图.png
 */

public class HotListVoucherHelper {

    private final String TAG = HotListVoucherHelper.class.getSimpleName();
    private VouchorAvailableInfoItem vouchorAvailableInfoItem;
    private boolean requesting = false;

    /**
     * 检测是否有试聊券
     * @param anchorId
     * @param publicLive
     * @return
     */
    public boolean checkVoucherFree(String anchorId, boolean publicLive){
        Log.d(TAG,"checkVoucherFree-anchorId:"+anchorId+" publicLive:"+publicLive);
        boolean isFree = false;
        if(publicLive){
            isFree = checkPublicFree(anchorId);
        }else {
            isFree = checkPrivateFree(anchorId);
        }
        Log.d(TAG,"checkVoucherFree-isFree:"+isFree);
        return isFree;
    }

    /**
     * 检测是否公开直播试聊券
     * @param anchorId
     * @return
     */
    private boolean checkPublicFree(String anchorId){
        Log.d(TAG,"checkPublicFree-anchorId:"+anchorId);
        boolean isFree = false;
        //检测是否有仅公开试聊券,使用所有人
        isFree = checkOnlyPublic();
        //检测是否有和用户绑定的公开直播间试聊券
        if(!isFree){
            isFree = checkBindOnlyPublic(anchorId);
        }
        //检测是否新关系且有新关系公开直播试聊券可用
        if(!isFree){
            if(checkNewRelation(anchorId)){
                isFree = checkNewRelationOnlyPublic();
            }
        }
        Log.d(TAG,"checkPublicFree-isFree:"+isFree);
        return isFree;
    }

    /**
     * 检测是否私密直播试聊券
     * @param anchorId
     * @return
     */
    private boolean checkPrivateFree(String anchorId){
        Log.d(TAG,"checkPrivateFree-anchorId:"+anchorId);
        boolean isFree = false;
        //检测是否有仅私密试聊券,使用所有人
        isFree = checkOnlyPrivate();
        //检测是否有和用户绑定的私密直播间试聊券
        if(!isFree){
            isFree = checkBindOnlyPrivate(anchorId);
        }
        //检测是否新关系且有新关系私密直播间试聊券可用
        if(!isFree){
            if(checkNewRelation(anchorId)){
                isFree = checkNewRelationOnlyPrivate();
            }
        }
        Log.d(TAG,"checkPrivateFree-isFree:"+isFree);
        return isFree;
    }

    /**
     * 检测是否有仅公开试聊券
     * @return
     */
    private boolean checkOnlyPublic(){
        boolean isFree = false;
        if(null != vouchorAvailableInfoItem){
            int currTime = (int)(System.currentTimeMillis()/1000);
            Log.d(TAG,"checkOnlyPublic-onlypublicExpTime:"+vouchorAvailableInfoItem.onlypublicExpTime);
            Log.d(TAG,"checkOnlyPublic-currTime:"+currTime);
            isFree = currTime<vouchorAvailableInfoItem.onlypublicExpTime;
            Log.d(TAG,"checkOnlyPublic-isFree:"+isFree);
        }
        return isFree;
    }

    /**
     * 检测是否有仅私密试聊券
     * @return
     */
    private boolean checkOnlyPrivate(){
        boolean isFree = false;
        int currTime = (int)(System.currentTimeMillis()/1000);
        Log.d(TAG,"checkOnlyPrivate-currTime:"+currTime);
        if(null != vouchorAvailableInfoItem){
            Log.d(TAG,"checkOnlyPrivate-onlyprivateExpTime:"+vouchorAvailableInfoItem.onlyprivateExpTime);
            isFree = currTime<vouchorAvailableInfoItem.onlyprivateExpTime;
        }
        Log.d(TAG,"checkOnlyPrivate-isFree:"+isFree);
        return isFree;
    }

    /**
     * 检测用户是否有绑定公开直播间试聊券
     * @param anchorId
     * @return
     */
    private boolean checkBindOnlyPublic(String anchorId){
        boolean isFree = false;
        int currTime = (int)(System.currentTimeMillis()/1000);
        Log.d(TAG,"checkBindOnlyPublic-anchorId:"+anchorId+" currTime:"+currTime);
        if(null != vouchorAvailableInfoItem && null != vouchorAvailableInfoItem.svrList){
            for(BindAnchorItem bindAnchorItem : vouchorAvailableInfoItem.svrList){
                //绑定的主播列表包含了anchorId对应的主播，且直播间试聊券类型为非仅私密,且试聊券未过期
                if(bindAnchorItem.anchorId.equals(anchorId) &&
                        (bindAnchorItem.useRoomType == VoucherItem.VoucherUseSchemeType.Any ||
                                bindAnchorItem.useRoomType == VoucherItem.VoucherUseSchemeType.Public)
                        && currTime<bindAnchorItem.expTime){
                    isFree = true;
                    break;
                }
            }
        }
        Log.d(TAG,"checkBindOnlyPublic-isFree:"+isFree);
        return isFree;
    }

    /**
     * 检测用户是否有绑定私密直播间试聊券
     * @param anchorId
     * @return
     */
    private boolean checkBindOnlyPrivate(String anchorId){
        Log.d(TAG,"checkBindOnlyPrivate-anchorId:"+anchorId);
        boolean isFree = false;
        int currTime = (int)(System.currentTimeMillis()/1000);
        Log.d(TAG,"checkBindOnlyPrivate-anchorId:"+anchorId+" currTime:"+currTime);
        if(null != vouchorAvailableInfoItem && null != vouchorAvailableInfoItem.svrList){
            for(BindAnchorItem bindAnchorItem : vouchorAvailableInfoItem.svrList){
                //绑定的主播列表包含了anchorId对应的主播，且直播间试聊券类型为非仅公开,且试聊券未过期
                if(bindAnchorItem.anchorId.equals(anchorId) &&
                        (bindAnchorItem.useRoomType == VoucherItem.VoucherUseSchemeType.Any ||
                                bindAnchorItem.useRoomType == VoucherItem.VoucherUseSchemeType.Private)
                        && currTime<bindAnchorItem.expTime){
                    isFree = true;
                    break;
                }
            }
        }
        Log.d(TAG,"checkBindOnlyPrivate-isFree:"+isFree);
        return isFree;
    }

    /**
     * 检测是否有新关系公开试聊券
     * @return
     */
    private boolean checkNewRelationOnlyPublic(){
        int currTime = (int)(System.currentTimeMillis()/1000);
        Log.d(TAG,"checkNewRelationOnlyPublic-currTime:"+currTime);
        boolean isFree = false;
        if(null != vouchorAvailableInfoItem){
            Log.d(TAG,"checkNewRelationOnlyPublic-onlypublicNewExpTime:"
                    +vouchorAvailableInfoItem.onlypublicNewExpTime);
            isFree = currTime<vouchorAvailableInfoItem.onlypublicNewExpTime;
        }
        Log.d(TAG,"checkNewRelationOnlyPublic-isFree:"+isFree);
        return isFree;
    }

    /**
     * 检测是否有新关系私密试聊券
     * @return
     */
    private boolean checkNewRelationOnlyPrivate(){
        boolean isFree = false;
        int currTime = (int)(System.currentTimeMillis()/1000);
        Log.d(TAG,"checkNewRelationOnlyPrivate-currTime:"+currTime);
        if(null != vouchorAvailableInfoItem){
            Log.d(TAG,"checkNewRelationOnlyPrivate-onlyprivateNewExpTime:"+vouchorAvailableInfoItem.onlyprivateNewExpTime);
            isFree = currTime<vouchorAvailableInfoItem.onlyprivateNewExpTime;
            Log.d(TAG,"checkNewRelationOnlyPrivate-isFree:"+isFree);
        }
        return isFree;
    }

    /**
     * 检测是否新关系
     * @param anchorId
     * @return
     */
    private boolean checkNewRelation(String anchorId){
        Log.d(TAG,"checkNewRelation-anchorId:"+anchorId);
        boolean isNewRelation = true;
        if(null != vouchorAvailableInfoItem && null != vouchorAvailableInfoItem.watchedAnchor){
            for(String id : vouchorAvailableInfoItem.watchedAnchor){
                //新关系主播
                if(id.equals(anchorId)){
                    isNewRelation = false;
                    break;
                }
            }
        }
        Log.d(TAG,"checkNewRelation-isNewRelation:"+isNewRelation);
        return isNewRelation;
    }

    /**
     * 获取最新试用券可用信息数据
     * @param listener
     */
    public void updateVoucherAvailableInfo(final OnGetVoucherAvailableInfoListener listener){
        Log.d(TAG,"updateVoucherAvailableInfo-requesting:"+requesting);
        //非单例模式，每个fragment都可以有一个Helper实例，同时每个实例根据requesting控制瞬时请求数量始终为1
        if(requesting){
            Log.d(TAG,"updateVoucherAvailableInfo-请求中，等待结果返回");
            return;
        }
        requesting = true;
        LiveRequestOperator.getInstance().GetVoucherAvailableInfo(new OnGetVoucherAvailableInfoCallback() {
            @Override
            public void onGetVoucherAvailableInfo(boolean isSuccess, int errCode,
                                                  String errMsg, VouchorAvailableInfoItem infoItem) {
                Log.d(TAG,"updateVoucherAvailableInfo-onGetVoucherInfo isSuccess:"+isSuccess
                        +" errCode"+errCode+" errMsg:"+errMsg+" infoItem:"+infoItem);
                requesting = false;
                //请求成功就更新到缓存，请求失败就清理缓存
                vouchorAvailableInfoItem = isSuccess ? infoItem : null;
                if(null != listener){
                    listener.onVoucherInfoUpdated(isSuccess);
                }
            }
        });
    }

    public interface OnGetVoucherAvailableInfoListener{
        void onVoucherInfoUpdated(boolean isSuccess);
    }
}
