package com.qpidnetwork.liveshow.home.live;

import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.framework.canadapter.CanAdapter;
import com.qpidnetwork.framework.canadapter.CanHolderHelper;
import com.qpidnetwork.httprequest.item.CoverPhotoItem;
import com.qpidnetwork.liveshow.LiveApplication;
import com.qpidnetwork.liveshow.R;

import java.lang.ref.WeakReference;
import java.util.List;

import static com.qpidnetwork.utils.DisplayUtil.getResources;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/6/26.
 */

public class CoverPhotoAdapter extends CanAdapter {
    private WeakReference<CoverManagerActivity> mActivity;

    public CoverPhotoAdapter(CoverManagerActivity activity, int itemLayoutId, List mList) {
        super(LiveApplication.getContext(), itemLayoutId, mList);
        mActivity = new WeakReference<CoverManagerActivity>(activity);
    }

    @Override
    protected void setView(CanHolderHelper helper, int position, Object bean) {
        CoverPhotoItem item = (CoverPhotoItem)bean;
        ImageView iv_coverPhoto = helper.getView(R.id.iv_coverPhoto);
        if(item.photoStatus == CoverPhotoItem.PhotoStatus.Unknown){
            iv_coverPhoto.setVisibility(View.GONE);
            helper.getView(R.id.iv_addCoverPhoto).setVisibility(View.VISIBLE);

        }else{
            iv_coverPhoto.setVisibility(View.VISIBLE);
            mActivity.get().loadCoverPhotoWithCornerRadiu(item.photoUrl,iv_coverPhoto,item.isInUse ? R.color.cover_state_use : android.R.color.transparent,
                    Float.valueOf(getResources().getDimension(R.dimen.coverphoto_corner_radiu)).intValue(),
                    Float.valueOf(getResources().getDimension(item.isInUse ?
                            R.dimen.coverphoto_selected_stroke_width : R.dimen.coverphoto_unselected_stroke_width)).intValue());
            helper.getView(R.id.iv_addCoverPhoto).setVisibility(View.GONE);
        }
        helper.getView(R.id.tv_coverAuditeStatus).setVisibility(item.photoStatus == CoverPhotoItem.PhotoStatus.Pending ? View.VISIBLE : View.GONE);
        ImageView iv_delectCoverPhoto = helper.getImageView(R.id.iv_delectCoverPhoto);
        iv_delectCoverPhoto.setVisibility((item.photoStatus == CoverPhotoItem.PhotoStatus.Approval && !item.isInUse) ? View.VISIBLE : View.GONE);
        iv_delectCoverPhoto.setTag(item.photoId);
        TextView tv_coverUseStatus = helper.getTextView(R.id.tv_coverUseStatus);
        if(item.photoStatus == CoverPhotoItem.PhotoStatus.Approval){
            tv_coverUseStatus.setVisibility(View.VISIBLE);
            tv_coverUseStatus.setBackgroundDrawable(getResources().getDrawable(item.isInUse ? R.drawable.bg_covermanager_using : R.drawable.bg_covermanager_use));
            tv_coverUseStatus.setText(getResources().getString(item.isInUse ? R.string.txt_using : R.string.txt_use));
            tv_coverUseStatus.setTextColor(getResources().getColor(item.isInUse ? android.R.color.white : R.color.cover_state_use));
            tv_coverUseStatus.setTag(item.photoId);
        }else{
            tv_coverUseStatus.setVisibility(View.GONE);
        }
    }

    @Override
    protected void setItemListener(CanHolderHelper helper) {
        helper.setItemChildClickListener(R.id.tv_coverUseStatus);
        helper.setItemChildClickListener(R.id.iv_delectCoverPhoto);
        helper.setItemChildClickListener(R.id.iv_addCoverPhoto);
    }
}
