package com.qpidnetwork.livemodule.liveshow.liveroom;

import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.view.View;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.utils.Log;

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
     * @param context
     * @return
     */
    public int getRootViewTopColor(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
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

        return context.getResources().getColor(colorResId);
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
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawableResId = R.drawable.ic_live_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawableResId = R.drawable.ic_live_paypublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawableResId = R.drawable.ic_live_normalprivate;
        }else {
            drawableResId = R.drawable.ic_live_advanceprv;
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
     * 直播间-头部背景
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomHeaderViewBgDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#8144a0"));
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#5d0e86"));
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_headbg_normalprivate);
        }else {
            drawable = context.getResources().getDrawable(R.drawable.ic_live_headbg_advanceprivate);
        }
        return drawable;
    }

    /**
     * 直播间-头部view层-底部分割线-高度
     * @param liveRoomType
     * @return
     */
    public int getRoomHeadViewButtomLineHeight(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        int heightResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_bottomlineheight_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.headerview_bottomlineheight_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            heightResId = R.dimen.headerview_bottomlineheight_normalprivate;
        }else {
            heightResId = R.dimen.headerview_bottomlineheight_advanceprivate;
        }

        return (int)context.getResources().getDimension(heightResId);
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
                    R.drawable.bg_liveroom_creditstips_b03a0953);
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
            drawable = context.getResources().getDrawable(R.drawable.ic_live_privatelive_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_privatelive_paypublic);
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

    /**
     * 直播间-主题背景
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomThemeDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#f8f8f8"));
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#530d78"));
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_roomtheme_normalpri);
        }else {
            drawable = context.getResources().getDrawable(R.drawable.ic_live_roomtheme_advancepri);
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
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_gift_paypublic);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_buttom_gift_normalprv);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.ic_liveroom_buttom_gift_advanceprv);
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
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            heightResId = R.dimen.live_buttomgift_leftmargin_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            heightResId = R.dimen.live_buttomgift_leftmargin_paypublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            heightResId = R.dimen.live_buttomgift_leftmargin_normalprv;
        }else {
            heightResId = R.dimen.live_buttomgift_leftmargin_advanceprv;
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
        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_recomgift_float_normalprv);
        }else if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_recomgift_float_advanceprv);
        }
        return drawable;
    }

    /**
     * 直播间底部-推荐礼物按钮-leftmargin
     * @param liveRoomType
     * @return
     */
    public int getRoomRecommGiftBtnLeftMargin(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            return (int)context.getResources().getDimension(R.dimen.live_buttomrecommgift_leftmargin_normalprv);
        }else if(IMRoomInItem.IMLiveRoomType.AdvancedPrivateRoom == liveRoomType) {
            return (int)context.getResources().getDimension(R.dimen.live_buttomrecommgift_leftmargin_advanceprv);
        }
        return 0;
    }

    /**直播间底部-Say something控件样式
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomInputBtnDrawable(Context context,IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_input_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_input_paypublic);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_input_normalprivate);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.ic_live_buttom_input_advanceprivate);
        }

        return drawable;
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
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_giftanim_freepublic);
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_giftanim_paypublic);
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_giftanim_normalprivate);
        }else{
            drawable = context.getResources().getDrawable(R.drawable.bg_liveroom_giftanim_advanceprivate);
        }
        return drawable;
    }

    /**
     * 直播间-聊天列表-用户进入直播间消息-文字样式
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListMedalRoomInMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_roomin_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_roomin_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_roomin_normalprv;
        }else{
            strResId = R.string.liveroom_message_template_roomin_advanceprv;
        }
        return strResId;
    }

    public int getRoomMsgListNoMedalRoomInMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_roomin_freepublic_nomedal;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_roomin_paidpublic_nomedal;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_roomin_normalprv_nomedal;
        }else{
            strResId = R.string.liveroom_message_template_roomin_advanceprv_nomedal;
        }
        return strResId;
    }

    /**
     * 直播间-聊天列表-文本/弹幕消息-文字样式
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListMedalTxtMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_normal_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_normal_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_normal_normalprv;
        }else{
            strResId = R.string.liveroom_message_template_normal_advanceprv;
        }
        return strResId;
    }

    public int getRoomMsgListNoMedalTxtMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_normal_freepublic_nomedal;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_normal_paidpublic_nomedal;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_normal_normalprv_nomedal;
        }else{
            strResId = R.string.liveroom_message_template_normal_advanceprv_nomedal;
        }
        return strResId;
    }

    /**
     * 直播间-聊天列表-礼物消息-文字样式
     * @param liveRoomType
     * @return
     */
    public int getRoomMsgListMedalGiftMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_gift_freepublic;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_gift_paidpublic;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_gift_normalprv;
        }else{
            strResId = R.string.liveroom_message_template_gift_advanceprv;
        }
        return strResId;
    }

    public int getRoomMsgListNoMedalGiftMsgStrResId(IMRoomInItem.IMLiveRoomType liveRoomType){
        int strResId = 0;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_gift_freepublic_nomedal;
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_gift_paidpublic_nomedal;
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            strResId = R.string.liveroom_message_template_gift_normalprv_nomedal;
        }else{
            strResId = R.string.liveroom_message_template_gift_advanceprv_nomedal;
        }
        return strResId;
    }

    /**
     * 直播间-弹幕浮层-背景色
     * @param liveRoomType
     * @return
     */
    public Drawable getRoomBarrageBgDrawable(IMRoomInItem.IMLiveRoomType liveRoomType){
        Drawable drawable = null;
        if(IMRoomInItem.IMLiveRoomType.FreePublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#deffffff"));
        }else if(IMRoomInItem.IMLiveRoomType.PaidPublicRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#de530d78"));
        }else if(IMRoomInItem.IMLiveRoomType.NormalPrivateRoom == liveRoomType){
            drawable = new ColorDrawable(Color.parseColor("#de293fac"));
        }else{
            drawable = new ColorDrawable(Color.parseColor("#de644c3b"));
        }

        return drawable;
    }
}
