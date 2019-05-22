package com.qpidnetwork.livemodule.liveshow.livechat;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.livechat.LCMessageItem;
import com.qpidnetwork.livemodule.livechat.LiveChatManager;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 2019/5/7 Hardy
 * <p>
 * LiveChat 的私密照和视频详情预览 Activity
 */
public class LiveChatPhotoAndVideoPreviewActivity extends BaseFragmentActivity implements ViewPager.OnPageChangeListener {

    private static final String LIVECHAT_PRIVATEPHOTO = "livechat_data_list";

    private ViewPager mViewPager;
    private MyAdapter mAdapter;

    private List<LCMessageItem> mMessageList = new ArrayList<>();
    private int mSwitchPos;
    private String mAnchorId;

    /**
     * 启动该 Act
     *
     * @param context
     * @param bean
     */
    public static void startAct(Context context, PrivatePhotoPriviewBean bean) {
        Intent intent = new Intent(context, LiveChatPhotoAndVideoPreviewActivity.class);
        intent.putExtra(LIVECHAT_PRIVATEPHOTO, bean);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_livechat_photo_and_video_preview);

        parseBundleData();
        initView();
        initData();
    }

    private void parseBundleData() {
        Bundle bundle = getIntent().getExtras();
        if (bundle != null && bundle.containsKey(LIVECHAT_PRIVATEPHOTO)) {
            PrivatePhotoPriviewBean bean = (PrivatePhotoPriviewBean) bundle.getSerializable(LIVECHAT_PRIVATEPHOTO);
            if (bean != null) {
                if (ListUtils.isList(bean.msgList)) {
                    for (PrivatePhotoPriviewBean.IdBean idBean : bean.msgList) {
                        // 在底层查找出对应的消息 item
                        LCMessageItem messageItem = LiveChatManager.getInstance().GetMessageWithMsgId(idBean.userId, idBean.msgId);
                        if (messageItem != null) {
                            mMessageList.add(messageItem);
                        }
                    }
                }

                mSwitchPos = bean.currPosition;
                mAnchorId = bean.anchorId;
            }
        } else {
            mSwitchPos = 0;
        }
    }

    private void initView() {
        ImageView mIvBack = findViewById(R.id.act_livechat_photo_and_video_preview_iv_back);
        mIvBack.setOnClickListener(this);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            FrameLayout.LayoutParams params = (FrameLayout.LayoutParams) mIvBack.getLayoutParams();
            params.topMargin += DisplayUtil.getStatusBarHeight(mContext);
            mIvBack.setLayoutParams(params);
        }

        mViewPager = findViewById(R.id.act_livechat_photo_and_video_preview_viewpager);
        mViewPager.addOnPageChangeListener(this);

        // 设置 adapter
        mAdapter = new MyAdapter(getSupportFragmentManager(), mMessageList, mAnchorId);
        mViewPager.setAdapter(mAdapter);

        // 跳转到指定的 position
        mViewPager.setCurrentItem(mSwitchPos);
    }

    private void initData() {


    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();

        if (id == R.id.act_livechat_photo_and_video_preview_iv_back) {
            finish();
        }
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {

    }

    @Override
    public void onPageSelected(int position) {

    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }


    /**
     * Adapter
     */
    private class MyAdapter extends FragmentStatePagerAdapter {

        private String anchorId;
        private List<LCMessageItem> msgList;
        private HashMap<Integer, WeakReference<LiveChatBasePreviewFragment>> mPageReference;

        public MyAdapter(FragmentManager fm, List<LCMessageItem> msgList, String mAnchorId) {
            super(fm);
            this.msgList = msgList;
            this.anchorId = mAnchorId;
            mPageReference = new HashMap<>();
        }

        public LiveChatBasePreviewFragment getFragment(int position) {
            LiveChatBasePreviewFragment fragment = null;
            if (mPageReference.containsKey(position)) {
                fragment = mPageReference.get(position).get();
            }
            return fragment;
        }

        @Override
        public Fragment getItem(int position) {
            LiveChatBasePreviewFragment fragment = getFragment(position);

            LCMessageItem item = msgList.get(position);

            if (fragment == null) {
                if (item.msgType == LCMessageItem.MessageType.Photo) {
                    // 2019/5/7 生成照片的 Fragment
                    fragment = new LiveChatPhotoPreviewFragment();
                } else {
                    // 2019/5/7 生成视频的 Fragment
                    fragment = new LiveChatVideoPreviewFragment();
                }

                // add to map
                mPageReference.put(position, new WeakReference<>(fragment));
            }

            fragment.setAnchorId(anchorId);
            fragment.setMessageItem(item);

            return fragment;
        }

        @Override
        public int getCount() {
            return msgList != null ? msgList.size() : 0;
        }
    }

}
