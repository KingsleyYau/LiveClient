package com.qpidnetwork.livemodule.liveshow.liveroom.talent;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.OnGetGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.TalentInfoItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.qnbridgemodule.view.textView.JustifyTextView;

import java.util.ArrayList;
import java.util.List;

/**
 * 才艺列表
 */
public class TalentDetailFragment extends Fragment {
    private String TAG = "Jagger";

    //控件
    private List<TalentInfoItem> mDatas = new ArrayList<>();
    private ImageView iv_back;
    private JustifyTextView tv_des;
    private TextView tv_talentGift , tv_talentCredits, tv_detailTitle;
    private SimpleDraweeView img_anchorAvatar , img_gift;

    //数据
    private TalentInfoItem mTalent;
    private onDetailEventListener mOnDetailEventListener;

    public void setOnDetailEventListener(onDetailEventListener listener){
        mOnDetailEventListener = listener;
    }

    public interface onDetailEventListener {
        void onBackClicked();
    }

    /**
     * 带参数启动方式
     * @return
     */
    public static TalentDetailFragment newInstance(){
        TalentDetailFragment fragment = new TalentDetailFragment();
        Bundle bundle = new Bundle();
//        bundle.putSerializable( PARAM_ROOM_ID, roomId);
        fragment.setArguments(bundle);
        return fragment;
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        //取启动参数
        if (getArguments() != null) {
//            if (getArguments().containsKey(PARAM_ROOM_ID)) {
//                mRoomId = (String) getArguments().getSerializable(PARAM_ROOM_ID);
//            }
        }
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        View view = LayoutInflater.from(getActivity()).inflate(R.layout.view_live_popupwindow_talents_detail,container,false);

        iv_back = (ImageView) view.findViewById(R.id.iv_back);
        iv_back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                if(mOnDetailEventListener != null){
                    mOnDetailEventListener.onBackClicked();
                }
            }
        });

        tv_detailTitle = (TextView) view.findViewById(R.id.tv_detailTitle);
        img_anchorAvatar = (SimpleDraweeView) view.findViewById(R.id.img_anchorAvatar);
        img_gift = (SimpleDraweeView) view.findViewById(R.id.img_talentGift);
        tv_des = (JustifyTextView)view.findViewById(R.id.tv_des);
        tv_talentGift = (TextView)view.findViewById(R.id.tv_talentGift);
        tv_talentCredits = (TextView)view.findViewById(R.id.tv_talentCredits);

        return view;
    }

    /**
     * 设入 才艺数据
     * @param talent
     */
    public void setTalentInfoItem (TalentInfoItem talent){
        mTalent = talent;
        refreshUI();
    }

    /**
     * 设入 主播头像
     * @param anchorUlr
     */
    public void setAnchorURL (String anchorUlr){
        img_anchorAvatar.setImageURI(anchorUlr);
    }

    /**
     * 加载数据后 重画界面
     */
    private void refreshUI(){
        tv_detailTitle.setText(mTalent.talentName);
        tv_des.setText(mTalent.decription);
        tv_talentGift.setText(getString(R.string.live_talent_gift,mTalent.giftName));
        tv_talentCredits.setText(getString(R.string.live_talent_pay_for_gift,String.valueOf(mTalent.talentCredit)));
        //礼物
        if(TextUtils.isEmpty(mTalent.giftId)){
            img_gift.setVisibility(View.GONE);
            tv_talentGift.setVisibility(View.GONE);
        }else{
            img_gift.setVisibility(View.VISIBLE);
            tv_talentGift.setVisibility(View.VISIBLE);

            GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(mTalent.giftId);
            if(giftItem != null && !TextUtils.isEmpty(giftItem.smallImgUrl)){
                img_gift.setImageURI(giftItem.smallImgUrl);
            }else{
                NormalGiftManager.getInstance().getGiftDetail(mTalent.giftId, new OnGetGiftDetailCallback() {
                    @Override
                    public void onGetGiftDetail(boolean isSuccess, int errCode, String errMsg, GiftItem giftDetail) {
                        //暂不处理
                    }
                });
            }
        }
    }
}
