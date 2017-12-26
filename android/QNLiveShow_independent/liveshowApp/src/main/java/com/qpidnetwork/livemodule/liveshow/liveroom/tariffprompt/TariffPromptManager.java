package com.qpidnetwork.livemodule.liveshow.liveroom.tariffprompt;

import android.content.Context;
import android.graphics.Color;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.datacache.preference.LocalPreferenceManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.Log;

import java.util.HashMap;

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

    private Context mContext;

    public TariffPromptManager(Context context){
        this.mContext = context;
    }

    //--------------------------成员属性、方法----------------------------------------------------------
    private final String TAG = TariffPromptManager.class.getSimpleName();
    private static HashMap<String,String> roomTypeTariffInfos = new HashMap<>();

    public TariffPrompt localTariffPrompt;
    public IMRoomInItem currIMRoomInItem;
    private LocalPreferenceManager localPreferenceManager;

    public TariffPromptManager init(IMRoomInItem imRoomInItem){
        localPreferenceManager = new LocalPreferenceManager(mContext);
        localTariffPrompt = (TariffPrompt) localPreferenceManager.getObject(imRoomInItem.roomType.toString());
        roomTypeTariffInfos =(HashMap<String, String>) localPreferenceManager.getObject("roomTypeTariffInfos");
        if(null == localTariffPrompt){
            localTariffPrompt = new TariffPrompt(true);
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
                tariffPrompt = mContext.getResources()
                        .getString(R.string.liveroom_tariff_prompt_free_public);
                break;
            case PaidPublicRoom:
                tariffPrompt = mContext.getResources()
                        .getString(R.string.liveroom_tariff_prompt_pre_public,
                            String.valueOf(currIMRoomInItem.roomPrice));
                break;
            case NormalPrivateRoom:
                tariffPrompt = mContext.getResources()
                        .getString(R.string.liveroom_tariff_prompt_silver_private,
                            String.valueOf(currIMRoomInItem.roomPrice));
                break;
            case AdvancedPrivateRoom:
                tariffPrompt = mContext.getResources()
                        .getString(R.string.liveroom_tariff_prompt_golden_private,
                            String.valueOf(currIMRoomInItem.roomPrice));
                break;
        }
        boolean hasTariffChanged = true;
        String roomPrice = String.valueOf(currIMRoomInItem.roomPrice);
        if(null == roomTypeTariffInfos){
            roomTypeTariffInfos = new HashMap<>();
        }
        if(roomTypeTariffInfos.containsKey(currIMRoomInItem.roomType.toString())
                && roomTypeTariffInfos.get(currIMRoomInItem.roomType.toString()).equals(roomPrice)){
            hasTariffChanged = false;
        }else{
            roomTypeTariffInfos.put(currIMRoomInItem.roomType.toString(),roomPrice);
        }
        isNeedUserConfirm = hasTariffChanged|| localTariffPrompt.isFirstTimeIn;
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
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(mContext,9f)),
                        0, startIndex, Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(mContext,10f)),
                        startIndex, startIndex+regex.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(mContext,9f)),
                        startIndex+regex.length(), tariffprompt.length(), Spanned.SPAN_INCLUSIVE_EXCLUSIVE);
            }else{
                spannableString.setSpan(new AbsoluteSizeSpan(DisplayUtil.dip2px(mContext,9f)),
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
            localPreferenceManager.save(currIMRoomInItem.roomType.toString(),localTariffPrompt);
            localPreferenceManager.save("roomTypeTariffInfos",roomTypeTariffInfos);
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
