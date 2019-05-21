package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;
import android.widget.CompoundButton;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2019/3/13.
 * Hangout 礼物弹窗的主播选择操作 Layout
 */
public class HangoutGiftAnchorLayout extends LinearLayout implements View.OnClickListener, CompoundButton.OnCheckedChangeListener {

    private TextView mTvName;
    private Switch mSwitch;
    private GradientTextView mTvCheckAll;
    private HangoutGiftAnchorView mAnchorMain;
    private HangoutGiftAnchorView mAnchor2;
    private HangoutGiftAnchorView mAnchor3;

    private HangoutAnchorInfoItem mAnchorItemMain;
    private HangoutAnchorInfoItem mAnchorItem2;
    private HangoutAnchorInfoItem mAnchorItem3;

    private StringBuilder mSendValSb;

    public HangoutGiftAnchorLayout(Context context) {
        this(context, null);
    }

    public HangoutGiftAnchorLayout(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public HangoutGiftAnchorLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        mSendValSb = new StringBuilder();
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();

        mTvName = findViewById(R.id.layout_ho_gift_anchor_tv_name);
        mTvCheckAll = findViewById(R.id.layout_ho_gift_anchor_tv_check_all);
        mSwitch = findViewById(R.id.layout_ho_gift_anchor_switch);
        mAnchorMain = findViewById(R.id.layout_ho_gift_anchor_icon_main);
        mAnchor2 = findViewById(R.id.layout_ho_gift_anchor_icon2);
        mAnchor3 = findViewById(R.id.layout_ho_gift_anchor_icon3);

        mTvCheckAll.setOnClickListener(this);
        mAnchorMain.setOnClickListener(this);
        mAnchor2.setOnClickListener(this);
        mAnchor3.setOnClickListener(this);

        mSwitch.setOnCheckedChangeListener(this);

        mAnchorMain.setAnchorIsMain(true);
        mAnchor2.setAnchorIsMain(false);
        mAnchor3.setAnchorIsMain(false);

        mAnchorMain.show(false);
        mAnchor2.show(false);
        mAnchor3.show(false);
    }

    /**
     * 增加主播
     *
     * @param isAnchorMain 是否为第一个邀请主播
     * @param mAnchorItem  主播信息
     */
    public void addAnchor(boolean isAnchorMain, HangoutAnchorInfoItem mAnchorItem) {
        if (mAnchorItem == null || hasCurAnchorInfo(mAnchorItem.anchorId)) {
            return;
        }

        if (isAnchorMain) {
            if (!mAnchorMain.isAnchorShow()) {
                mAnchorItemMain = mAnchorItem;

                mAnchorMain.show(true);
                mAnchorMain.setSelect(true, false); // 默认选中
                mAnchorMain.setAnchorUrl(mAnchorItem.photoUrl);
            }
        } else if (!mAnchor2.isAnchorShow()) {
            mAnchorItem2 = mAnchorItem;

            mAnchor2.show(true);
            mAnchor2.setSelect(true, false); // 默认选中
            mAnchor2.setAnchorUrl(mAnchorItem.photoUrl);
        } else if (!mAnchor3.isAnchorShow()) {
            mAnchorItem3 = mAnchorItem;

            mAnchor3.show(true);
            mAnchor3.setSelect(true, false); // 默认选中
            mAnchor3.setAnchorUrl(mAnchorItem.photoUrl);
        }

        changeSendAnchorName();
    }

    /**
     * 隐藏主播
     *
     * @param anchorId 主播 id
     */
    public void hideAnchor(String anchorId) {
        if (TextUtils.isEmpty(anchorId)) {
            return;
        }

        if (mAnchorItemMain != null && anchorId.equals(mAnchorItemMain.anchorId)) {
            mAnchorMain.show(false);
            mAnchorItemMain = null;
        }
        if (mAnchorItem2 != null && anchorId.equals(mAnchorItem2.anchorId)) {
            mAnchor2.show(false);
            mAnchorItem2 = null;
        }
        if (mAnchorItem3 != null && anchorId.equals(mAnchorItem3.anchorId)) {
            mAnchor3.show(false);
            mAnchorItem3 = null;
        }

        changeSendAnchorName();
    }

    /**
     * 是否选择私密发送
     *
     * @return
     */
    public boolean isSendSecretly() {
        return mSwitch.isChecked();
    }

    /**
     * 获取选择发送的主播 id
     * 外层控制循环发多次
     *
     * @return
     */
    public List<String> getSend2AnchorId() {
        List<String> list = null;

        if (hasSelectAnchor()) {
            list = new ArrayList<>();

            if (mAnchorMain.isAnchorShow() && mAnchorMain.isSelect() && mAnchorItemMain != null) {
                list.add(mAnchorItemMain.anchorId);
            }
            if (mAnchor2.isAnchorShow() && mAnchor2.isSelect() && mAnchorItem2 != null) {
                list.add(mAnchorItem2.anchorId);
            }
            if (mAnchor3.isAnchorShow() && mAnchor3.isSelect() && mAnchorItem3 != null) {
                list.add(mAnchorItem3.anchorId);
            }
        }

        return list;
    }

    /**
     * 直播间是否有主播?
     *
     * @return
     */
    public boolean hasAnchorBroadcasters() {
        if (mAnchorMain.isAnchorShow() || mAnchor2.isAnchorShow() || mAnchor3.isAnchorShow()) {
            return true;
        }

        return false;
    }

    /**
     * 是否有选中的主播
     *
     * @return
     */
    public boolean hasSelectAnchor() {
        if ((mAnchorMain.isAnchorShow() && mAnchorMain.isSelect()) ||
                (mAnchor2.isAnchorShow() && mAnchor2.isSelect()) ||
                (mAnchor3.isAnchorShow() && mAnchor3.isSelect())) {

            return true;
        }

        return false;
    }

    /**
     * 主播列表中，是否已经含有该指定 id 的主播信息
     *
     * @param anchorId
     * @return
     */
    private boolean hasCurAnchorInfo(String anchorId) {
        if (TextUtils.isEmpty(anchorId)) {
            return false;
        }

        if (mAnchorItemMain != null && anchorId.equals(mAnchorItemMain.anchorId)) {
            return true;
        }
        if (mAnchorItem2 != null && anchorId.equals(mAnchorItem2.anchorId)) {
            return true;
        }
        if (mAnchorItem3 != null && anchorId.equals(mAnchorItem3.anchorId)) {
            return true;
        }

        return false;
    }

    /**
     * 改变 send to xxx 文本
     */
    private void changeSendAnchorName() {
        if (!hasSelectAnchor()) {
            setSendAnchorNameText("...");
            return;
        }

        // 先清原来
        mSendValSb.delete(0, mSendValSb.length());

        if (mAnchorMain.isSelect() && mAnchorItemMain != null) {
            mSendValSb.append(mAnchorItemMain.nickName);
            mSendValSb.append(",");
        }
        if (mAnchor2.isSelect() && mAnchorItem2 != null) {
            mSendValSb.append(mAnchorItem2.nickName);
            mSendValSb.append(",");
        }
        if (mAnchor3.isSelect() && mAnchorItem3 != null) {
            mSendValSb.append(mAnchorItem3.nickName);
            mSendValSb.append(",");
        }
        if (mSendValSb.length() > 0) {
            mSendValSb.deleteCharAt(mSendValSb.length() - 1);
        }

        setSendAnchorNameText(mSendValSb.toString());
    }

    /**
     * 格式化 send to xxx 文本
     *
     * @param val
     */
    private void setSendAnchorNameText(String val) {
        mTvName.setText(getContext().getString(R.string.hangout_send_to, val));
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.layout_ho_gift_anchor_tv_check_all) {
            // 全选
            if (mAnchorMain.isAnchorShow()) {
                mAnchorMain.setSelect(true, true);
            }
            if (mAnchor2.isAnchorShow()) {
                mAnchor2.setSelect(true, true);
            }
            if (mAnchor3.isAnchorShow()) {
                mAnchor3.setSelect(true, true);
            }
        } else if (id == R.id.layout_ho_gift_anchor_icon_main) {
            // 点击第一个主播

            boolean isSelect = mAnchorMain.isSelect();
            mAnchorMain.setSelect(!isSelect, false);

        } else if (id == R.id.layout_ho_gift_anchor_icon2) {
            // 点击第二个主播

            boolean isSelect = mAnchor2.isSelect();
            mAnchor2.setSelect(!isSelect, false);

        } else if (id == R.id.layout_ho_gift_anchor_icon3) {
            // 点击第三个主播

            boolean isSelect = mAnchor3.isSelect();
            mAnchor3.setSelect(!isSelect, false);

        }

        // 2019/3/13 更新 send to 主播名字
        changeSendAnchorName();
    }

    @Override
    public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
        // nothing to do
    }
}
