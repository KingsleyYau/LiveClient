package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;

/**
 * Description:房间主题管理类
 * <p>
 * Created by Harry on 2017/9/7.
 */

public class RoomThemeManager {


    /**
     * 获取直播间顶部状态栏(通知栏)背景色
     * @param liveRoomType
     * @return
     */
    public static int getRootViewTopColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int colorResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            colorResId = R.color.liveroom_top_barcolor_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            colorResId = R.color.liveroom_top_barcolor_paidpublicRoom;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            colorResId = R.color.liveroom_top_barcolor_normalprivate;
        }else {
            colorResId = R.color.liveroom_top_barcolor_advancedprivate;
        }

        return LiveApplication.getContext().getResources().getColor(colorResId);
    }

    /**
     * 返回直播间左上角直播间类型提示Drawable
     * @param liveRoomType
     * @return
     */
    public static Drawable getRoomFlagDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        int drawableResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawableResId = R.drawable.ic_live_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawableResId = R.drawable.ic_live_paypublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawableResId = R.drawable.ic_live_freepublic;
        }else {
            drawableResId = R.drawable.ic_live_freepublic;
        }

        return LiveApplication.getContext().getResources().getDrawable(drawableResId);
    }

    /**
     * 返回直播间头部背景
     * @param liveRoomType
     * @return
     */
    public static Drawable getRoomHeaderViewBgDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#8144a0"));
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#5d0e86"));
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_headbg_normalprivate);
        }else {
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_headbg_advanceprivate);
        }
        return drawable;
    }

    /**
     * 房间头 view层的底部分割线高度
     * @param liveRoomType
     * @return
     */
    public static int getRoomHeadViewButtomLineHeight(IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_buttomlineheight_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_buttomlineheight_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            heightResId = R.dimen.headerview_buttomlineheight_normalprivate;
        }else {
            heightResId = R.dimen.headerview_buttomlineheight_advanceprivate;
        }

        return (int)LiveApplication.getContext().getResources().getDimension(heightResId);
    }

    /**
     * 获取直播间资费提示背景
     * @return
     */
    public static Drawable getRoomCreditsBgDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(
                    R.drawable.bg_liveroom_creditstips_b03a0953);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(
                    R.drawable.bg_liveroom_creditstips_b0293fac);
        }else if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(
                    R.drawable.bg_liveroom_creditstips_db644c3b);
        }
        return drawable;
    }

    /**
     * 返回直播间发起立即私密直播按钮的drawable
     * @param liveRoomType
     * @return
     */
    public static Drawable getRoomPriLiveNowBtnDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_privatelive_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_privatelive_paypublic);
        }

        return drawable;
    }

    /**
     * 返回直播间背景
     * @param liveRoomType
     * @return
     */
    public static Drawable getRoomThemeDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#f8f8f8"));
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#530d78"));
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_roomtheme_normalpri);
        }else {
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_roomtheme_advancepri);
        }
        return drawable;
    }

    /**
     * 返回公开直播间底部礼物按钮drawable
     * @param liveRoomType
     * @return
     */
    public static Drawable getPublicRoomGiftBtnDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_buttom_gift_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_buttom_gift_paypublic);
        }

        return drawable;
    }

    /**
     * 返回公开直播间底部消息输入按钮drawable
     * @param liveRoomType
     * @return
     */
    public static Drawable getPublicRoomInputBtnDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_buttom_input_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = LiveApplication.getContext().getResources().getDrawable(R.drawable.ic_live_buttom_input_paypublic);
        }

        return drawable;
    }

}
