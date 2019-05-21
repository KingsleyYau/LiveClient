package com.qpidnetwork.livemodule.liveshow.liveroom.audience;

import android.graphics.drawable.Drawable;
import android.support.v4.content.ContextCompat;
import android.widget.Button;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.canadapter.CanAdapter;
import com.qpidnetwork.livemodule.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.livemodule.httprequest.item.AudienceInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.HangOutLiveRoomActivity;

/**
 * Description:HangOut直播间@列表适配器
 * <p>
 * Created by Harry on 2017/6/28.
 */

public class ChatterSelectorAdapter extends CanAdapter<AudienceInfoItem> {

    private Button btn_chatterNickName;
    private SimpleDraweeView civ_chatterPhoto;

    private HangOutLiveRoomActivity mActivity;

    private int colorSelect;
    private int colorNormal;

    public ChatterSelectorAdapter(HangOutLiveRoomActivity mActivity, int itemLayoutId) {
        super(mActivity, itemLayoutId);
        this.mActivity = mActivity;

        colorNormal = ContextCompat.getColor(mActivity, R.color.live_text_color_black);
        colorSelect = ContextCompat.getColor(mActivity, R.color.white);
    }

    private Drawable getItemBgDrawable(int position, AudienceInfoItem bean) {
        Drawable drawable = null;
//        boolean isCurrSelected = null != mActivity && null != mActivity.lastSelectedAudienceInfoItem
//                && bean.userId.equals(mActivity.lastSelectedAudienceInfoItem.userId);

        // 2019/3/22 Hardy
        boolean isCurrSelected = isCurSelected(bean);

        if (0 == position) {
            drawable = mActivity.getResources().getDrawable(
                    isCurrSelected ? R.drawable.bg_hangout_item_userchooser_top_selected :
                            R.drawable.bg_hangout_item_userchooser_top);
        } else if (position == getList().size() - 1) {
            drawable = mActivity.getResources().getDrawable(
                    isCurrSelected ? R.drawable.bg_hangout_item_userchooser_buttom_selected :
                            R.drawable.bg_hangout_item_userchooser_buttom);
        } else {
            drawable = mActivity.getResources().getDrawable(
                    isCurrSelected ? R.drawable.bg_hangout_item_userchooser_mid_selected :
                            R.drawable.bg_hangout_item_userchooser_mid);
        }
        return drawable;
    }

    private boolean isCurSelected(AudienceInfoItem bean) {
        boolean isCurrSelected = null != mActivity && null != mActivity.lastSelectedAudienceInfoItem
                && bean.userId.equals(mActivity.lastSelectedAudienceInfoItem.userId);
        return isCurrSelected;
    }

    @Override
    protected void setView(final CanHolderHelper helper, final int position, AudienceInfoItem bean) {
        btn_chatterNickName = helper.getView(R.id.btn_chatterNickName);
        btn_chatterNickName.setBackgroundDrawable(getItemBgDrawable(position, bean));
        btn_chatterNickName.setText(bean.nickName);

        // 2019/3/22 Hardy
        btn_chatterNickName.setTextColor(isCurSelected(bean) ? colorSelect : colorNormal);

//        civ_chatterPhoto = helper.getView(R.id.img_chatterPhoto);
//        civ_chatterPhoto.setVisibility(View.GONE);

//        if(!TextUtils.isEmpty(bean.photoUrl)) {
//            civ_chatterPhoto.setVisibility(View.VISIBLE);
//            //压缩、裁剪图片
//            int bgSize = mContext.getResources().getDimensionPixelSize(R.dimen.live_size_20dp);  //DisplayUtil.getScreenWidth(mContext);
//            Uri imageUri = Uri.parse(bean.photoUrl);
//            ImageRequest request = ImageRequestBuilder.newBuilderWithSource(imageUri)
//                    .setResizeOptions(new ResizeOptions(bgSize, bgSize))
//                    .build();
//            DraweeController controller = Fresco.newDraweeControllerBuilder()
//                    .setImageRequest(request)
//                    .setOldController(civ_chatterPhoto.getController())
//                    .setControllerListener(new BaseControllerListener<ImageInfo>())
//                    .build();
//            civ_chatterPhoto.setController(controller);
//            civ_chatterPhoto.setTag(bean.photoUrl);
//        }
    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(R.id.btn_chatterNickName);
        helper.setItemChildClickListener(R.id.img_chatterPhoto);
    }

    @Override
    public void addLastItem(AudienceInfoItem model) {
        // 2019/3/25 Hardy  去重
        if (model == null) {
            return;
        }

        boolean hasSameAnchor = false;
        synchronized (getList()) {
            for (AudienceInfoItem item : getList()) {
                if (item.userId.equals(model.userId)) {
                    hasSameAnchor = true;
                    break;
                }
            }
        }

        if (hasSameAnchor) {
            return;
        }

        super.addLastItem(model);
    }
}
