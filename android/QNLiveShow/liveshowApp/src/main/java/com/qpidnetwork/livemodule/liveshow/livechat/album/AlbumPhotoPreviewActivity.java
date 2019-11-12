package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.content.ContextCompat;
import android.support.v4.view.ViewPager;
import android.view.View;
import android.widget.ImageButton;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.qnbridgemodule.view.ViewPagerFixed;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumDataHolderManager;
import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;
import com.qpidnetwork.qnbridgemodule.view.camera.observer.SystemPhotoChangeListener;
import com.qpidnetwork.qnbridgemodule.view.camera.observer.SystemPhotoChangeManager;

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * 2018/12/14 Hardy
 * Chat 聊天，在相册里，查看本地大图
 */
public class AlbumPhotoPreviewActivity extends BaseFragmentActivity implements ViewPager.OnPageChangeListener,
        SystemPhotoChangeListener {

    public static final String LOCAL_FILE_PATH = "localFilePath";
    private static final String LOCAL_FILE_PATH_POSITION = "localFilePathPosition";

    // 选择展示图片的位置 position
    private int mCurPosition;

    private ImageButton mBtnClose;
    private TextView mBtnSend;
    private ViewPagerFixed mViewPager;
    private NormalPhotoAdapter mAdapter;

    private boolean mInitPage = true;


    public static void startAct(Context context, int localFilePathPosition, int requestCode) {
        Intent intent = new Intent(context, AlbumPhotoPreviewActivity.class);
        intent.putExtra(LOCAL_FILE_PATH_POSITION, localFilePathPosition);
        ((Activity) context).startActivityForResult(intent, requestCode);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_album_photo_preview_live);

        // 统计设置为page activity
        SetPageActivity(true);

        int bgColor = ContextCompat.getColor(this, R.color.live_chat_album_image_big);
        this.getWindow().setBackgroundDrawable(new ColorDrawable(bgColor));

        initView();

        registerSysImageChange();

        initData();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        unRegisterSysImageChange();
    }

    private void registerSysImageChange() {
        SystemPhotoChangeManager.getInstance(mContext).registerListener(this);
    }

    private void unRegisterSysImageChange() {
        SystemPhotoChangeManager.getInstance(mContext).unregisterListener(this);
    }

    @Override
    public void onSystemPhotoChange(List<ImageBean> list) {
        // 收到图片更新，关闭当前页面
        finish();
    }

    private void initView() {
        if (getIntent() != null) {
            mCurPosition = getIntent().getIntExtra(LOCAL_FILE_PATH_POSITION, 0);
        }

        mBtnClose = findViewById(R.id.buttonCancel);
        mBtnSend = findViewById(R.id.btnSend);
        mBtnClose.setOnClickListener(this);
        mBtnSend.setOnClickListener(this);

        // 分页控件
        mAdapter = new NormalPhotoAdapter(this, AlbumDataHolderManager.getInstance().getDataList());
        mViewPager = findViewById(R.id.viewPager);
        mViewPager.addOnPageChangeListener(this);
        mViewPager.setOffscreenPageLimit(1);
        mViewPager.setAdapter(mAdapter);

        if (mCurPosition < mAdapter.getCount()) {
            mViewPager.setCurrentItem(mCurPosition);
        }
    }

    private void initData() {

    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.buttonCancel) {
            finish();
        } else if (id == R.id.btnSend) {
            int curItem = mViewPager.getCurrentItem();

            String mLocalFilePath = "";
            ImageBean itemBean = mAdapter.getDataBean(curItem);
            if (itemBean != null) {
                mLocalFilePath = itemBean.imagePath;

                // 2019/5/14 Hardy  检查原图是否被旋转
                mLocalFilePath = AlbumUtil.adjustImageDegree(mLocalFilePath, itemBean.imageFileName);
            }


            Intent intent = new Intent();
            intent.putExtra(LOCAL_FILE_PATH, mLocalFilePath);
            setResult(Activity.RESULT_OK, intent);
            finish();
        }
    }


    @Override
    protected void onPause() {
        super.onPause();

        if (mViewPager != null) {
            //解决传入详情为null是，mViewPager未初始化导致空指针异常
            int pageId = mViewPager.getCurrentItem();
            if (pageId >= 0) {
                BaseFragment baseFragment = GetBaseFragment(pageId);
                if (null != baseFragment) {
                    baseFragment.onFragmentPause(pageId);
                }
            }
        }
    }

    @Override
    public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
        // 若page未初始化
        if (mInitPage) {
            // 回调Fragment被选中
            if (FragmentSelected(position)) {
                // page初始化完成
                mInitPage = false;
            }
        }
    }

    @Override
    public void onPageSelected(int arg0) {
        // 2018/12/20 Hardy
        // 由于该 reset 方法计算并刷新 view，会导致切换页面时卡顿，
        // 并且现在不需要跟随手指缩放，故这里注释不做处理

        /* 页面切换，reset之前的ImageView放大设置 */
//        Fragment fragment = null;
//        if (mAdapter != null) {
//            if (mAdapter.getFragment(arg0 - 1) != null) {
//                fragment = mAdapter.getFragment(arg0 - 1);
//                if (fragment instanceof AlbumPhotoPreviewFragment) {
//                    ((AlbumPhotoPreviewFragment) fragment).reset();
//                }
//            }
//            if (mAdapter.getFragment(arg0 + 1) != null) {
//                fragment = mAdapter.getFragment(arg0 + 1);
//                if (fragment instanceof AlbumPhotoPreviewFragment) {
//                    ((AlbumPhotoPreviewFragment) fragment).reset();
//                }
//            }
//        }

        // 回调Fragment被选中
        if (FragmentSelected(arg0)) {
            // page初始化完成
            mInitPage = false;
        }
    }

    @Override
    public void onPageScrollStateChanged(int state) {

    }


    private BaseFragment GetBaseFragment(int page) {
        BaseFragment baseFragment = null;
        if (null != mAdapter && mAdapter.getCount() > 0) {
            if (mAdapter.getFragment(page) != null) {
                Fragment fragment = mAdapter.getFragment(page);
                if (fragment instanceof BaseFragment) {
                    baseFragment = (BaseFragment) fragment;
                }
            }
        }
        return baseFragment;
    }

    private boolean FragmentSelected(int page) {
        boolean result = false;
        BaseFragment baseFragment = GetBaseFragment(page);
        if (null != baseFragment) {
            baseFragment.onFragmentSelected(page);
            result = true;
        }
        return result;
    }

    /**
     * adapter
     */
    private class NormalPhotoAdapter extends FragmentPagerAdapter {

        private List<ImageBean> mDataList;
        private HashMap<Integer, WeakReference<Fragment>> mPageReference;

        public NormalPhotoAdapter(FragmentActivity activity, List<ImageBean> mDataList) {
            super(activity.getSupportFragmentManager());

            this.mDataList = new ArrayList<>();
            this.mDataList.addAll(mDataList);

            mPageReference = new HashMap<>();
        }

        public Fragment getFragment(int position) {
            Fragment fragment = null;
            if (mPageReference.containsKey(position)) {
                fragment = mPageReference.get(position).get();
            }
            return fragment;
        }

        @Override
        public int getCount() {
            return mDataList != null ? mDataList.size() : 0;
        }

        @Override
        public Fragment getItem(int position) {
            Fragment fragment = null;

            if (mPageReference.containsKey(position)) {
                fragment = mPageReference.get(position).get();
            }

            if (fragment == null) {
                fragment = AlbumPhotoPreviewFragment.getInstance(mDataList.get(position).imagePath);

                mPageReference.put(position, new WeakReference<Fragment>(fragment));
            }

            return fragment;
        }

        public ImageBean getDataBean(int pos) {
            if (pos < mDataList.size()) {
                return mDataList.get(pos);
            }

            return null;
        }

    }


}
