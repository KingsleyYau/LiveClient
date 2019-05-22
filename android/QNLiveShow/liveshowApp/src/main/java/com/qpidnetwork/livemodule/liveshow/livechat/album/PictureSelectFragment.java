package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.animation.Animator;
import android.app.Activity;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.DecelerateInterpolator;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.GridView;
import android.widget.ImageView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragment;
import com.qpidnetwork.livemodule.liveshow.livechat.LiveChatTalkActivity;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumDataHolderManager;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumHelper;
import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;

import java.util.List;

/**
 * 图片选择
 */
public class PictureSelectFragment extends BaseFragment {

    private GridView gvAlbum;
    private ImageView ivScale;

    private LiveChatAlbumGridAdapter mAdapter;

    private int mLastPosition = -1;
    private LiveChatAlbumItemView mLastItemView;

    private final static int DURATION_TIME = 300;
    private DecelerateInterpolator decelerateInterpolator = new DecelerateInterpolator();

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container,
                             Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_picture_select_live, null);
        initViews(view);
        return view;
    }

    private void initViews(View view) {
        gvAlbum = (GridView) view.findViewById(R.id.gvAlbum);
        ivScale = (ImageView) view.findViewById(R.id.ivScale);
        ivScale.setOnClickListener(this);
    }


    @Override
    public void onDestroy() {
        super.onDestroy();

        // 2018/12/20 Hardy 清除本地相册数据的持有
        AlbumDataHolderManager.getInstance().clear();
    }

    @Override
    public void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);

        AlbumHelper helper = new AlbumHelper(getActivity());

        // 2018/12/20 Hardy
        List<ImageBean> mDataList = helper.getAlbumImageList();
        // 2019/5/10 Hardy
        mDataList = helper.sortNotPngImagePath(mDataList);

        AlbumDataHolderManager.getInstance().setDataList(mDataList);

        mAdapter = new LiveChatAlbumGridAdapter(getActivity(), mDataList);
        gvAlbum.setAdapter(mAdapter);
        gvAlbum.setOnItemClickListener(new OnItemClickListener() {

            @Override
            public void onItemClick(AdapterView<?> parent, View view,
                                    int position, long id) {
//                Activity activity = getActivity();
//                if (activity != null) {
//                    if (activity instanceof ChatActivity) {
//                        ((ChatActivity) activity).sendPrivatePhoto(mAdapter.getItem(position).imagePath);
//                    } else if (activity instanceof CamShareActivity) {
//                        ((CamShareActivity) activity).sendPrivatePhoto(mAdapter.getItem(position).imagePath);
//                    }
//                }


                // 2018/12/17 Hardy
                Log.i("info", "-----> onItemClick -----------------start: " + position);

                // 若点击有部分范围超出界面的图片，列表自动滚动定位至完全显示该最略图
                gvAlbum.setSelection(position);

                String lastImagePath = "";
                ImageBean lastItem = null;
                if (isValidLastPosition()) {
                    lastItem = mAdapter.getItem(mLastPosition);
                    lastImagePath = lastItem.imagePath;
                }
                ImageBean curItem = mAdapter.getItem(position);
                LiveChatAlbumItemView curItemView = (LiveChatAlbumItemView) view;

                // 1 如果点击同一个 item，状态反选
                // 有可能  curItemView 复用并实例化了一个新的 View
                if (mLastItemView != null && lastImagePath.equals(curItem.imagePath)) {

                    boolean isLastSelect = curItem.isSelect;  // 以当前选中的 item 数据为准
                    curItem.isSelect = !isLastSelect;

                    // 新的实例
                    if (curItemView != mLastItemView) {
                        // mLastItemView 已经在别的 item 复用赋值更新为最新状态，故这里不更新
                        curItemView.showImageOperaButton(curItem.isSelect);
                        // 更新上个 item 的状态值
                        if (lastItem != null) {
                            lastItem.isSelect = curItem.isSelect;
                        }
                        // 重新记录
                        mLastItemView = curItemView;
                    } else {
                        // 没回收，更新 view
                        mLastItemView.showImageOperaButton(curItem.isSelect);
                    }

                    showGo2ImageAlbumButton(!curItem.isSelect);

                    return;
                }

                // 2 将上一个选中的 item 状态恢复初始状态
                resetLastItemView();

                // 3 改变当前点击的 item 状态
                curItemView.showImageOperaButton(true);
                curItem.isSelect = true;

                // 4 记录当前选中
                mLastPosition = position;
                mLastItemView = curItemView;

                // 5 隐藏打开相册按钮
                showGo2ImageAlbumButton(false);

                Log.i("info", "-----> onItemClick -----------------end: " + position);

                // Hardy 不使用全数据刷新，只是根据单个 item 或复用的 item ，恢复初始状态
                // 刷新
//                mAdapter.notifyDataSetChanged();
            }
        });

        mAdapter.setOnImageOperaListener(new LiveChatAlbumItemView.OnImageOperaListener() {
            @Override
            public void onView(String imagePath, int position) {
                AlbumPhotoPreviewActivity.startAct(mContext, position, LiveChatTalkActivity.CHAT_SELECT_PHOTO_VIEW_BIG);
                //2018/12/17 外层调用，隐藏操作按钮
            }

            @Override
            public void onSend(String imagePath, int position) {
                ImageBean item = mAdapter.getItem(position);
                if (item != null) {
                    // 检查
                    String filePath = AlbumUtil.adjustImageDegree(item.imagePath, item.imageFileName);

                    // 发送
                    Activity activity = getActivity();
                    if (activity != null) {
                        ((LiveChatTalkActivity) activity).sendPrivatePhotoNoTips(filePath);
                    }else {
                        ((LiveChatTalkActivity) mContext).sendPrivatePhotoNoTips(filePath);
                    }

                    // 2018/12/17 隐藏操作按钮
                    hideCurItemOperaBtn();
                }
            }
        });
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.ivScale) {
            PictureSelectActivity.startAct(mContext, PictureSelectActivity.SELECT_PICTURE_TYPE_CHAT, LiveChatTalkActivity.CHAT_SELECT_PHOTO);
        }
    }

    /**
     * 2019/04/29 Hardy
     * 将上一个点击 item 的 view 恢复状态
     */
    private void resetLastItemView() {
        if (isValidLastPosition() && mLastItemView != null) {
            mLastItemView.showImageOperaButton(false);

            // 新的实例
            LiveChatAlbumItemView lastView = (LiveChatAlbumItemView) gvAlbum.getChildAt(mLastPosition);
            if (lastView != null && lastView != mLastItemView) {
                lastView.showImageOperaButton(false);
            }

            ImageBean item = mAdapter.getItem(mLastPosition);
            item.isSelect = false;
        }
    }

    public void hideCurItemOperaBtn() {
        resetLastItemView();

        showGo2ImageAlbumButton(true);
    }

    /**
     * 判断上一次的点击 item 的 pos 是否有效
     *
     * @return
     */
    private boolean isValidLastPosition() {
        return mLastPosition >= 0;
    }

    /**
     * 点击照片时，左下按钮（相机、相册）隐藏，出现选中样式
     *
     * @param isShow
     */
    private void showGo2ImageAlbumButton(boolean isShow) {
        if (isShow) {
            if (ivScale.getVisibility() == View.VISIBLE) {
                return;
            }

            // 放大
            ivScale.animate()
                    .setDuration(DURATION_TIME)
                    .scaleX(1)
                    .scaleY(1)
                    .setInterpolator(decelerateInterpolator)
                    .setListener(new Animator.AnimatorListener() {
                        @Override
                        public void onAnimationStart(Animator animation) {
                            ivScale.setVisibility(View.VISIBLE);
                        }

                        @Override
                        public void onAnimationEnd(Animator animation) {
                        }

                        @Override
                        public void onAnimationCancel(Animator animation) {

                        }

                        @Override
                        public void onAnimationRepeat(Animator animation) {

                        }
                    }).start();
        } else {
            if (ivScale.getVisibility() == View.GONE) {
                return;
            }

            // 缩小
            ivScale.animate()
                    .setDuration(DURATION_TIME)
                    .scaleX(0)
                    .scaleY(0)
                    .setInterpolator(decelerateInterpolator)
                    .setListener(new Animator.AnimatorListener() {
                        @Override
                        public void onAnimationStart(Animator animation) {

                        }

                        @Override
                        public void onAnimationEnd(Animator animation) {
                            ivScale.setVisibility(View.GONE);
                        }

                        @Override
                        public void onAnimationCancel(Animator animation) {

                        }

                        @Override
                        public void onAnimationRepeat(Animator animation) {

                        }
                    }).start();
        }
    }
}
