package com.qpidnetwork.anchor.liveshow.liveroom.audience;

import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.Button;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.canadapter.CanAdapter;
import com.qpidnetwork.anchor.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.anchor.framework.widget.circleimageview.CircleImageView;
import com.qpidnetwork.anchor.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.anchor.liveshow.liveroom.HangOutLiveRoomActivity;

/**
 * Description:HangOut直播间@列表适配器
 * <p>
 * Created by Harry on 2017/6/28.
 */

public class ChatterSelectorAdapter extends CanAdapter<AudienceInfoItem> {

    private Button btn_chatterNickName;
    private CircleImageView civ_chatterPhoto;

    private HangOutLiveRoomActivity mActivity;

    public ChatterSelectorAdapter(HangOutLiveRoomActivity mActivity, int itemLayoutId) {
        super(mActivity, itemLayoutId);
        this.mActivity = mActivity;
    }

    private Drawable getItemBgDrawable(int position, AudienceInfoItem bean){
        Drawable drawable = null;
        boolean isCurrSelected = null != mActivity && null != mActivity.lastSelectedAudienceInfoItem
                && bean.userId.equals(mActivity.lastSelectedAudienceInfoItem.userId);
        if(0 == position){
            drawable = mActivity.getResources().getDrawable(
                    isCurrSelected ? R.drawable.bg_hangout_item_userchooser_top_selected :
                            R.drawable.bg_hangout_item_userchooser_top);
        }else if(position == getList().size()-1){
            drawable = mActivity.getResources().getDrawable(
                    isCurrSelected ? R.drawable.bg_hangout_item_userchooser_buttom_selected :
                            R.drawable.bg_hangout_item_userchooser_buttom);
        }else{
            drawable = mActivity.getResources().getDrawable(
                    isCurrSelected ? R.drawable.bg_hangout_item_userchooser_mid_selected :
                            R.drawable.bg_hangout_item_userchooser_mid);
        }
        return drawable;
    }


    @Override
    protected void setView(final CanHolderHelper helper, final int position, AudienceInfoItem bean) {
         btn_chatterNickName  = helper.getView(R.id.btn_chatterNickName);
        btn_chatterNickName.setBackgroundDrawable(getItemBgDrawable(position,bean));
        btn_chatterNickName.setText(bean.nickName);
        civ_chatterPhoto = helper.getView(R.id.civ_chatterPhoto);
        civ_chatterPhoto.setVisibility(View.GONE);

//        if(!TextUtils.isEmpty(bean.photoUrl)){
//            if(null == civ_chatterPhoto.getTag() || !civ_chatterPhoto.getTag().equals(bean.photoUrl)){
//                Picasso.with(mContext.getApplicationContext())
//                        .load(bean.photoUrl).noFade()
//                        .placeholder(R.drawable.ic_default_photo_man)
//                        .error(R.drawable.ic_default_photo_man)
//                        .memoryPolicy(MemoryPolicy.NO_CACHE)
//                        .into(civ_chatterPhoto);
//                civ_chatterPhoto.setTag(bean.photoUrl);
//            }
//        }
    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(R.id.btn_chatterNickName);
        helper.setItemChildClickListener(R.id.civ_chatterPhoto);
    }
}
