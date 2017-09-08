package com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt;

import android.app.Activity;
import android.text.TextUtils;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.utils.Log;

/**
 * Description:资费提示管理器
 * <p>
 *  1.四种直播间需要四种不同的文案
 *  2.首次进入直播间以及直播间资费发生变更，需要显示got it按钮，点击got it按钮本地缓存房间类型及资费
 *  3.点击got it按钮就隐藏，否则就一直显示，隐藏后下次点击图片显示时自动3秒倒计时消失
 *  4.资费可变
 *
 *
 * Created by Harry on 2017/9/6.
 */

public class TariffPromptManager {

    //---------------------------单例模式-------------------------------------------------------------

    private static TariffPromptManager instance = null;

    public static TariffPromptManager getInstance(){
        if(null == instance){
            instance = new TariffPromptManager();
        }
        return instance;
    }


    private TariffPromptManager(){

    }

    //--------------------------成员属性、方法----------------------------------------------------------
    private final String TAG = TariffPromptManager.class.getSimpleName();

    public TariffPrompt localTariffPrompt;
    public IMRoomInItem currIMRoomInItem;
    private LocalPreferenceManager localPreferenceManager;

    public TariffPromptManager init(Activity activity, IMRoomInItem imRoomInItem){
        localPreferenceManager = new LocalPreferenceManager(activity.getApplicationContext());
        localTariffPrompt = (TariffPrompt) localPreferenceManager.getObject(imRoomInItem.roomType.toString());
        if(null == localTariffPrompt){
            localTariffPrompt = new TariffPrompt(true,null);
        }
        currIMRoomInItem = imRoomInItem;
        return this;
    }

    public void getRoomTariffInfo(OnGetRoomTariffInfoListener listener){
        if(null == localTariffPrompt || null == currIMRoomInItem){
            return;
        }
        String tariffPrompt = null;
        boolean isNeedUserConfirm = true;

        switch (currIMRoomInItem.roomType){
            case FreePublicRoom:
                tariffPrompt = LiveApplication.getContext().getResources()
                        .getString(R.string.liveroom_tariff_prompt_free_public);

                break;
            case PaidPublicRoom:
                tariffPrompt = LiveApplication.getContext().getResources()
                        .getString(R.string.liveroom_tariff_prompt_pre_public,
                            String.valueOf(currIMRoomInItem.roomPrice));
                break;
            case NormalPrivateRoom:
                tariffPrompt = LiveApplication.getContext().getResources()
                        .getString(R.string.liveroom_tariff_prompt_silver_private,
                            String.valueOf(currIMRoomInItem.roomPrice));
                break;
            case AdvancedPrivateRoom:
                tariffPrompt = LiveApplication.getContext().getResources()
                        .getString(R.string.liveroom_tariff_prompt_golden_private,
                            String.valueOf(currIMRoomInItem.roomPrice));
                break;
        }
        isNeedUserConfirm = (!TextUtils.isEmpty(localTariffPrompt.tariff)
                && !localTariffPrompt.tariff.equals(String.valueOf(currIMRoomInItem.roomPrice)))
                    || localTariffPrompt.isFirstTimeIn;
        Log.d(TAG,"getRoomTariffInfo-isNeedUserConfirm:"+isNeedUserConfirm+" roomType:"+currIMRoomInItem.roomType.toString());
        if(null != listener){
            listener.onGetRoomTariffInfo(tariffPrompt,isNeedUserConfirm,String.valueOf(currIMRoomInItem.roomPrice));
        }
    }

    public void update(){
        if(null == localTariffPrompt || currIMRoomInItem == null){
            return;
        }
        try {
            localTariffPrompt.isFirstTimeIn = false;
            localTariffPrompt.tariff = String.valueOf(currIMRoomInItem.roomPrice);
            localPreferenceManager.save(currIMRoomInItem.roomType.toString(),localTariffPrompt);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public void clear(){
        localTariffPrompt = null;
        currIMRoomInItem = null;
        localPreferenceManager = null;
    }

    public interface OnGetRoomTariffInfoListener{
        void onGetRoomTariffInfo(String tariffPrompt, boolean isNeedUserConfirm, String regex);
    }
}
