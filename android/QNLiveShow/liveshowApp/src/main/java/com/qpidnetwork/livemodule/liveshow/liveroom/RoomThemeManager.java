package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * Description:房间主题管理类
 * <p>
 * Created by Harry on 2017/9/7.
 */

public class RoomThemeManager {

    private String TAG = RoomThemeManager.class.getSimpleName();

    /**
     * 直播间-顶部状态栏(通知栏)背景色
     * @param liveRoomType
     * @return
     */
    public int getRootViewTopColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int statusBarColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            statusBarColor = Color.parseColor("#3FFFFFFF");
//        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
//            statusBarColor = R.color.liveroom_top_barcolor_paidpublicRoom;
//        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
//            statusBarColor = R.color.liveroom_top_barcolor_normalprivate;
        }else {
            statusBarColor = Color.parseColor("#252525");
        }

        return statusBarColor;
    }

    /**
     * 直播间关闭按钮图标
     * @return
     */
    public Drawable getCloseRoomImgResId(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable closeRoomDrawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            closeRoomDrawable = context.getResources().getDrawable(R.drawable.ic_live_close_public_room);
        }else {
            closeRoomDrawable = context.getResources().getDrawable(R.drawable.ic_live_close_private_room);
        }
        return closeRoomDrawable;
    }

    /**
     * 直播间-房间类型标识图标-高度
     * @param liveRoomType
     * @return
     */
    public int getRoomFlagHeight(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_height_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_height_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_height_normalprivate;
        }else {
            heightResId = R.dimen.headerview_roomflag_height_advanceprivate;
        }

        return (int)context.getResources().getDimension(heightResId);
    }

    /**
     * 直播间-左上角-直播间类型图标
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomFlagDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int drawableResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawableResId = R.drawable.ic_live_public_flag;
        }else{
            drawableResId = R.drawable.ic_live_private_flag;
        }

        return context.getResources().getDrawable(drawableResId);
    }

    /**
     * 直播间-左上角-直播间类型图标-TopMargin
     * @param liveRoomType
     * @return
     */
    public int getRoomFlagTopMargin(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_margintop_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_margintop_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_margintop_normalprivate;
        }else {
            heightResId = R.dimen.headerview_roomflag_margintop_advanceprivate;
        }

        return (int)context.getResources().getDimension(heightResId);
    }

    /**
     * 直播间-左上角-直播间类型图标-BottomMargin
     * @param liveRoomType
     * @return
     */
    public int getRoomFlagBottomMargin(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_marginbottom_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_marginbottom_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            heightResId = R.dimen.headerview_roomflag_marginbottom_normalprivate;
        }else {
            heightResId = R.dimen.headerview_roomflag_marginbottom_advanceprivate;
        }

        return (int)context.getResources().getDimension(heightResId);
    }

    /**
     * 直播间-头部主播信息块-背景
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomHeaderHostInfoViewBg(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                ||IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_live_header_host_public);
        }else {
            drawable = context.getResources().getDrawable(R.drawable.bg_live_header_host_private);
        }
        return drawable;
    }

    /**
     * 获取直播间头部-主播信息块-直播间类型提示文案资源ID
     * @param liveRoomType
     * @return
     */
    public int getRoomHeaderRoomFlagStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;
        if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
                || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
            //公开直播间
          strResId = R.string.live_room_public_flag;
        }else{
            strResId = R.string.live_room_private_flag;
        }
        return strResId;
    }

    /**
     * 获取直播间头部-主播信息块-返点提示颜色
     * @param liveRoomType
     * @return
     */
    public int getRoomHeaderRebateTipsTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int txtColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                ||IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            txtColor = Color.parseColor("#383838");
        }else {
            txtColor = Color.WHITE;
        }
        return txtColor;
    }

    /**
     * 直播间-头部view层-分割线-背景色
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomHeadDeviderLineDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable deviderLineDrawable = null;
        if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            deviderLineDrawable = new ColorDrawable(Color.parseColor("#e5e5e5"));
        }else{
            deviderLineDrawable = new ColorDrawable(Color.parseColor("#2b2b2b"));
        }

        return deviderLineDrawable;
    }

    /**
     * 直播间-头部view层-高度
     * @param liveRoomType
     * @return
     */
    public int getRoomHeadViewHeight(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_height_public;
        }else {
            heightResId = R.dimen.headerview_height_private;
        }

        return (int)context.getResources().getDimension(heightResId);
    }

    /**
     * 直播间-资费提示-背景
     * @return
     */
    public Drawable getRoomCreditsBgDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(
                    R.drawable.bg_liveroom_creditstips_70434343);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(
                    R.drawable.bg_liveroom_creditstips_b0293fac);
        }else if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(
                    R.drawable.bg_liveroom_creditstips_db644c3b);
        }else{
            drawable = null;
        }
        return drawable;
    }

    /**
     * 直播间-立即私密直播按钮-样式
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomPriLiveNowBtnDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_privatelive_public);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_privatelive_public);
        }

        return drawable;
    }

    public int getRoomPrvLiveNowBtnVisibility(IMRoomInItem.IMLiveRoomType liveRoomType){
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            return View.VISIBLE;
        }else{
            return View.GONE;
        }
    }

    public int getRoomCarViewBgDrawableResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int bgResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            bgResId = R.drawable.bg_entrance_car_master_public;
        }else{
            bgResId = R.drawable.bg_entrance_car_master_private;
        }
        return bgResId;
    }

    public int getRoomCarViewTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int txtColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            txtColor = Color.parseColor("#FFFFD205");
        }else{
            txtColor = Color.WHITE;
        }
        return txtColor;
    }

    /**
     * 直播间-主题背景
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomThemeDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#ECEDF1"));
        }else {
            drawable = new ColorDrawable(Color.parseColor("#2b2b2b"));
        }
        return drawable;
    }

    /**
     * 私密直播间 用户头像背景图
     * @param liveRoomType
     * @return
     */
    public Drawable getPrivateRoomUserIconBg(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_normalprv_usericon_bg);
        }else if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_advanceprv_usericon_bg);
        }else{
            drawable = null;
        }

        return drawable;
    }


    /**
     * 私密直播间-亲密度等级-图标
     * @param loveLevel
     * @return
     */
    public Drawable getPrivateRoomLoveLevelDrawable(Context context,int loveLevel){
        Log.d(TAG,"getPrivateRoomLoveLevelDrawable-loveLevel:"+loveLevel);
        Drawable drawable = null;
        try {
            int drawableResId = context.getResources().
                    getIdentifier("ic_liveroom_header_intimacy_" + loveLevel, "drawable", context.getPackageName());
            drawable = context.getResources().getDrawable(drawableResId);
        }catch (Exception e){
            e.printStackTrace();
        }
        return drawable;
    }

    /**
     * 私密直播间-主播头像-背景
     * @param liveRoomType
     * @return
     */
    public Drawable getPrivateRoomHostIconBg(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_normalprv_hosticon_bg);
        }else if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_advanceprv_hosticon_bg1);
        }else{
            drawable = null;
        }

        return drawable;
    }
    /**
     * 私密直播间-主播头像-背景
     * @param liveRoomType
     * @return
     */
    public Drawable getPrivateRoomFollowBtnDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_follow_normalprv);
        }else if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_follow_advanceprv);
        }else{
            drawable = null;
        }

        return drawable;
    }



    /**
     * 直播间-底部礼物按钮样式
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomGiftBtnDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_public);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_private);
        }
        return drawable;
    }

    /**
     * 直播间底部-礼物按钮-leftmargin
     * @param liveRoomType
     * @return
     */
    public int getRoomGiftBtnLeftMargin(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.live_buttomgift_leftmargin_public;

        }else {
            heightResId = R.dimen.live_buttomgift_leftmargin_private;
        }

        return (int)context.getResources().getDimension(heightResId);
    }

    /**
     * 直播间底部-礼物按钮-rightmargin
     * @param liveRoomType
     * @return
     */
    public int getRoomGiftBtnRightMargin(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.live_buttomgift_rightmargin_public;
        }else {
            heightResId = R.dimen.live_buttomgift_rightmargin_private;
        }

        return (int)context.getResources().getDimension(heightResId);
    }

    /**
     * 直播间底部-礼物按钮-rightmargin
     * @param liveRoomType
     * @return
     */
    public int getRoomGiftBtnButtomMargin(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.live_buttomgift_buttommargin_public;
        }else {
            heightResId = R.dimen.live_buttomgift_buttommargin_private;
        }

        return (int)context.getResources().getDimension(heightResId);
    }


    /**
     * 直播间-底部推荐礼物按钮样式
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomRecommGiftFloatDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_recomgift_float_private);
        }
        return drawable;
    }

    /**
     * 直播间底部-推荐礼物按钮-leftmargin
     * @param liveRoomType
     * @return
     */
    public int getRoomRecommGiftBtnRightMargin(Context context, IMRoomInItem.IMLiveRoomType liveRoomType){
        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType) {
            return (int) context.getResources().getDimension(R.dimen.live_buttomrecommgift_rightmargin_private);
        }
        return 0;
    }

    /**
     * 直播间-消息列表-TopMargin
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListTopMargin(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){

        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            return (int)context.getResources().getDimension(R.dimen.live_msglist_topmargin_private);
        }

        return 0;
    }

    /**直播间-消息列表-顶部渐进色
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListTopGradualColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int color = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            color = Color.WHITE;
        }else{
            color = Color.parseColor("#2b2b2b");
        }
        return color;
    }

    /**直播间底部-Say something控件样式
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomInputBtnDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_live_buttom_input_public);

        }else{
            drawable = context.getResources().getDrawable(R.drawable.bg_live_buttom_input_private);
        }

        return drawable;
    }

    public int getRoomInputTipsTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int txtColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            txtColor = Color.WHITE;
        }else{
            txtColor = Color.parseColor("#AAFFFFFF");
        }
        return txtColor;
    }

    /**直播间-软键盘弹起-输入控件整体背景样式
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomInputBgDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_input_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_input_paypublic);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_input_normalprivate);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_input_advanceprv);
        }

        return drawable;
    }

    /**直播间-软键盘弹起-输入框背景
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomETBgDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_edittext_advancepriv);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_edittext_normalprivate);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_edittext_public);
        }

        return drawable;
    }

    /**直播间-软键盘弹起-弹幕开关按钮样式
     * @param liveRoomType
     * @param isBarrage
     * @return
     */
    public Drawable getRoomMsgTypeSwitchDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType,boolean isBarrage){
        Drawable drawable = null;
        if(!isBarrage){
            drawable = context.getResources().getDrawable(R.drawable.ic_popup_off);
        }else if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_popup_on_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_popup_on_paypublic);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_popup_on_normalprivate);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.ic_popup_on_advanceprivate);
        }

        return drawable;
    }

    /**直播间-软键盘弹起-输入框提示文字颜色
     * @param liveRoomType
     * @param isBarrage
     * @return
     */
    public int getRoomETHintTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType,boolean isBarrage){
        int color = 0;
        if(!isBarrage){
            color = Color.parseColor("#b5b5b5");
        }else if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            color = Color.parseColor("#b296df");
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            color = Color.parseColor("#baac3f");
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            color = Color.parseColor("#c39eff");
        }else{
            color = Color.parseColor("#9b7930");
        }
        return color;
    }

    /**直播间-软键盘弹起-输入框输入文字颜色
     * @param liveRoomType
     * @return
     */
    public int getRoomETTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int color = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            color = Color.BLACK;
        }else{
            color = Color.WHITE;
        }
        return color;
    }

    /**直播间-软键盘弹起-表情列表开关按钮样式
     * @param liveRoomType
     * @return
     */
    public int getRoomInputEmojiSwitchVisiable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            return View.GONE;
        }
        return View.VISIBLE;
    }

    /**直播间-软键盘弹起-消息发送按钮样式
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomSendMsgBtnDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_sendmsg_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_sendmsg_paypublic);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_sendmsg_normalprivate);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_sendmsg_advanceprivate);
        }
        return drawable;
    }

    /**直播间-连送礼物动画背景
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomRepeatGiftAnimBgDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.HangoutRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_multiclick_stroke_shape);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_giftanim_private);
        }
        return drawable;
    }

    /**
     * 系统公告:带连接或者不带连接普通文本文字颜色
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListSysNoticeNormalTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int txtColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            txtColor = Color.parseColor("#297AF3");
        }else{
            txtColor = Color.parseColor("#FF6D00");
        }
        return txtColor;
    }

    /**
     * 系统公告-警告文本文字颜色
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListSysNoticeWarningTxtColor(IMRoomInItem.IMLiveRoomType liveRoomType){
        int txtColor = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            txtColor = Color.parseColor("#FF4D4D");
        }else{
            txtColor = Color.parseColor("#FF4D4D");
        }
        return txtColor;
    }

    /**
     * 直播间消息列表-礼物消息类型对应的资源id
     * @param liveRoomType
     * @param isAnchor
     * @param isMySelf
     * @return
     */
    public int getRoomMsgListGiftMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType,boolean isAnchor,boolean isMySelf){
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
                //公开直播间
                if(isMySelf){
                    strResId = R.string.livemsg_temp_gift_public_self;
                }else if(isAnchor){
                    strResId = R.string.livemsg_temp_gift_public_anchor;
                }else{
                    strResId = R.string.livemsg_temp_gift_public;
                }
            }else{
                //私密直播间
                if(isMySelf){
                    strResId = R.string.livemsg_temp_gift_private_self;
                }else if(isAnchor){
                    strResId = R.string.livemsg_temp_gift_private_anchor;
                }
            }
        }
        return strResId;
    }
    public int getRoomMsgListGiftMsgStrResIdByHangout(IMRoomInItem.IMLiveRoomType liveRoomType, boolean isAnchor,
                                                      GiftItem giftItem, boolean isSecretly, boolean hasRecvNickName) {
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                //HangOut直播间
                if(null != giftItem){
                    if(giftItem.giftType == GiftItem.GiftType.Celebrate){
                        strResId = isAnchor ? R.string.livemsg_temp_gift_hangout_celeb_anchor : R.string.livemsg_temp_gift_hangout_celeb_man;
                    }else if(giftItem.giftType == GiftItem.GiftType.Bar){
                        if(isAnchor){
                            strResId = R.string.livemsg_temp_gift_hangout_bar_anchor;
                        }else{
                            strResId = isSecretly ? R.string.livemsg_temp_gift_hangout_bar_man_secretly : R.string.livemsg_temp_gift_hangout_bar_man;
                        }

                    }else{
                        if(isAnchor){
                            strResId = R.string.livemsg_temp_gift_hangout_giftstore_anchor;
                        }else{
                            strResId = isSecretly ? R.string.livemsg_temp_gift_hangout_giftstore_man_secretly : R.string.livemsg_temp_gift_hangout_giftstore_man;
                        }
                    }
                }else {
                    if(hasRecvNickName){//本地礼物详情不存在，toUid不为空，按照普通礼物消息类型展示
                        if(isAnchor){
                            strResId = R.string.livemsg_temp_gift_hangout_giftstore_anchor;
                        }else{
                            strResId = isSecretly ? R.string.livemsg_temp_gift_hangout_giftstore_man_secretly : R.string.livemsg_temp_gift_hangout_giftstore_man;
                        }
                    }else{//本地礼物详情不存在，toUid为空，按照庆祝礼物消息类型展示
                        strResId = isAnchor ? R.string.livemsg_temp_gift_hangout_celeb_anchor : R.string.livemsg_temp_gift_hangout_celeb_man;
                    }
                }
            }
        }
        return strResId;
    }

    /**
     * 直播间消息列表-入场信息类型对应的资源id
     * @param liveRoomType
     * @param isMySelf
     * @return
     */
    public int getRoomMsgListRoomInMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType,boolean isMySelf){
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
                //公开直播间
                if(isMySelf){
                    strResId = R.string.livemsg_temp_roomin_public_self;
                }else{
                    strResId = R.string.livemsg_temp_roomin_public;
                }
            }else{
                //私密直播间
                strResId = R.string.livemsg_temp_roomin_private_self;
            }
        }
        return strResId;
    }
    public int getRoomMsgListRoomInMsgStrResIdByHangout(IMRoomInItem.IMLiveRoomType liveRoomType, boolean isMan){
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom){
                //HangOut直播间
                strResId = isMan ? R.string.livemsg_temp_roomin_hangout_man : R.string.livemsg_temp_roomin_hangout_anchor;
            }
        }
        return strResId;
    }

    /**
     * 直播间消息列表-普通文本消息/弹幕资源ID
     * @param liveRoomType
     * @param isAnchor
     * @param isMySelf
     * @return
     */
    public int getRoomMsgListNormalStrResId(IMRoomInItem.IMLiveRoomType liveRoomType, boolean isAnchor, boolean isMySelf){
        int strResId = 0;
        if(null != liveRoomType){
            if(liveRoomType == IMRoomInItem.IMLiveRoomType.PaidPublicRoom
                    || liveRoomType == IMRoomInItem.IMLiveRoomType.FreePublicRoom){
                if(isMySelf){
                    strResId = R.string.livemsg_temp_normal_public_self;
                }else if(isAnchor){
                    strResId = R.string.livemsg_temp_normal_public_anchor;
                }else{
                    //其他观众的消息，目前是看不到的
                }
            }else{
                if(isMySelf){
                    strResId = R.string.livemsg_temp_normal_private_self;
                }else if(isAnchor){
                    strResId = R.string.livemsg_temp_normal_private_anchor;
                }else{
                    //其他观众的消息，目前是看不到的
                }
            }
        }
        return strResId;
    }
    public int getRoomMsgListNormalStrResIdByHangout(IMRoomInItem.IMLiveRoomType liveRoomType, boolean isAnchor){
        int strResId = 0;
        if(null != liveRoomType) {
            if (liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom) {
                if (isAnchor) {
                    strResId = R.string.livemsg_temp_normal_hangout_anchor;
                } else {
                    strResId = R.string.livemsg_temp_normal_hangout_man;
                }
            }
        }
        return strResId;
    }

    public Drawable getRoomMsgListGiftItemBgDrawable(Context context, IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_public);
        }else{
            drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_private);
        }
        return drawable;
    }
    public Drawable getRoomMsgListGiftItemBgDrawableByHangout(Context context, IMRoomInItem.IMLiveRoomType liveRoomType, boolean isSecretly){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.HangoutRoom == liveRoomType){
            if(isSecretly){
                drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_hangout_secretly);
            }else{
                drawable=context.getResources().getDrawable(R.drawable.bg_live_msg_item_gift_hangout);
            }
        }
        return drawable;
    }

    /**
     * 直播间-弹幕浮层-背景色
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomBarrageBgDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType
                || IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#deffffff"));
        }else{
            drawable = new ColorDrawable(Color.parseColor("#E5252525"));
        }

        return drawable;
    }

    /**
     * 直播间消息列表-推荐主播消息资源ID
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListRecommendedStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;

        if(liveRoomType == IMRoomInItem.IMLiveRoomType.NormalPrivateRoom
                || liveRoomType == IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom){
            strResId = R.string.livemsg_temp_private_recommend;
        }else if(liveRoomType == IMRoomInItem.IMLiveRoomType.HangoutRoom) {
            strResId = R.string.livemsg_temp_hangout_recommend;
        }
        return strResId;
    }
}
