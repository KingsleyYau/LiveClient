package com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt;

import android.graphics.Color;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
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

    public TariffPromptManager init(IMRoomInItem imRoomInItem){
        localPreferenceManager = new LocalPreferenceManager(LiveApplication.getContext());
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
            listener.onGetRoomTariffInfo(getTariffPromptStyle(tariffPrompt,String.valueOf(currIMRoomInItem.roomPrice)),isNeedUserConfirm);
        }
    }

    private SpannableString getTariffPromptStyle(String tariffprompt,String regex){
        SpannableString spannableString = null;
        if(!TextUtils.isEmpty(tariffprompt)){
            spannableString = new SpannableString(tariffprompt);
            int startIndex = tariffprompt.indexOf(regex);
            if(!TextUtils.isEmpty(regex) && startIndex>=0 && startIndex<tariffprompt.length()){
                spannableString.setSpan(new ForegroundColorSpan(Color.parseColor("#ffd205")),
                        startIndex, startIndex+regex.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(LiveApplication.getContext(),9f)),
                        0, startIndex, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(LiveApplication.getContext(),10f)),
                        startIndex, startIndex+regex.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(LiveApplication.getContext(),9f)),
                        startIndex+regex.length(), tariffprompt.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            }else{
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(LiveApplication.getContext(),9f)),
                        0, tariffprompt.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            }
        }
        return spannableString;
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
        void onGetRoomTariffInfo(SpannableString tariffPromptSpan, boolean isNeedUserConfirm);
    }
}
