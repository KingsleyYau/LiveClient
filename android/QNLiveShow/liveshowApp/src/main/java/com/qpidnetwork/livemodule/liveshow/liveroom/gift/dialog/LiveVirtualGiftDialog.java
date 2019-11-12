package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.support.v4.view.PagerAdapter;
import android.support.v4.view.ViewPager;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.ImageView;

import com.flyco.tablayout.SlidingTabLayout;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.GiftTypeItem;
import com.qpidnetwork.livemodule.httprequest.item.PackageGiftItem;
import com.qpidnetwork.livemodule.im.listener.IMRoomInItem;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.GiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.RoomVirtualGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.fragment.LiveVirtualGiftBaseLayout;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.fragment.LiveVirtualGiftFreeLayout;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.fragment.LiveVirtualGiftNormalLayout;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.view.dialog.BaseCommonDialog;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.util.UIUtils;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Hardy on 2019/9/2.
 * <p>
 * 私密直播间改版的新版虚拟礼物弹窗
 * <p>
 * 其中部分逻辑，参考:
 *
 * @see LiveGiftDialog
 */
public class LiveVirtualGiftDialog extends BaseCommonDialog implements View.OnClickListener {

    private static final int ERROR_TAB_POS = -1;

    private SlidingTabLayout mTabView;
    private ViewPager mViewPager;
    private MyNewPageAdapter mPagerAdapter;

    // data
    private RoomGiftManager mRoomGiftManager;   //礼物数据管理类
    private IMRoomInItem mIMRoomInItem;         //存放房间信息
    private LiveGiftDialogHelper mLiveGiftDialogHelper;
    private RoomVirtualGiftManager mRoomVirtualGiftManager;

    //外部交互事件监听器
    private LiveGiftDialogEventListener mLiveGiftDialogEventListener;

    // last
    private long lastGiftSendTime = 0L;
    private String lastSendGiftId;
    // 错误重试
    private int errorReClickTabPos = ERROR_TAB_POS;
    private boolean isErrorReClick;

    public LiveVirtualGiftDialog(Context context, RoomGiftManager roomGiftManager, IMRoomInItem imRoomInitem) {
        super(context, R.layout.dialog_live_virtual_gift, R.style.CustomTheme_LiveGiftDialog);

        this.mRoomGiftManager = roomGiftManager;
        this.mLiveGiftDialogHelper = new LiveGiftDialogHelper();
        this.mIMRoomInItem = imRoomInitem;

        mLiveGiftDialogHelper.updateManLevel(mIMRoomInItem.manLevel);
        mLiveGiftDialogHelper.updateRoomLevel(mIMRoomInItem.loveLevel);

        mRoomVirtualGiftManager = new RoomVirtualGiftManager(roomGiftManager);

        initData();
    }

    @Override
    public void initView(View v) {
        ImageView mIvQuestion = v.findViewById(R.id.dialog_live_virtual_gift_iv_question);
        ImageView mIvBack = v.findViewById(R.id.dialog_live_virtual_gift_iv_back);

        mIvQuestion.setOnClickListener(this);
        mIvBack.setOnClickListener(this);

        mViewPager = v.findViewById(R.id.dialog_live_virtual_gift_viewPager);
        mTabView = v.findViewById(R.id.dialog_live_virtual_gift_tab);
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.BOTTOM;
        params.width = DisplayUtil.getScreenWidth(mContext);
        setDialogParams(params);
    }

    private void initData() {
        loadGiftTypeList();
    }

    @Override
    public void show() {
        // 防止在退出直播间时，继续操作发送礼物，导致窗口没关闭而内存泄漏
        if (!UIUtils.isActExist(mContext)) {
            return;
        }

        super.show();

        reloadErrorData();
    }

    @Override
    public void destroy() {
        super.destroy();

        // TODO: 2019/9/3

    }

    private void reloadErrorData() {
        /*
            分类数据，只是进来直播间时，获取一次,如果为空，下次 show 时不再获取
            若获取失败，则再次获取
         */
        if (!mLiveGiftDialogHelper.isSendableListSuccess() ||
                !mLiveGiftDialogHelper.isPackageListSuccess()) {
            loadGiftTypeList();
        }
    }

    private void loadGiftTypeList() {
        mRoomVirtualGiftManager.loadGiftTypeList(new RoomVirtualGiftManager.OnVirtualGiftListCallback() {
            @Override
            public void onGiftList(boolean isSuccess, List<GiftTypeItem> giftTypeList, boolean hasPackageItems, int tabCurPosition) {
                if (isSuccess) {
                    // 标记是否加载分类下礼物列表数据成功，用在不同礼物列表页面做状态改变处理
                    mLiveGiftDialogHelper.setPackageListSuccess(true);
                    mLiveGiftDialogHelper.setSendableListSuccess(true);
                } else {
                    mLiveGiftDialogHelper.setPackageListSuccess(false);
                    // 本地有缓存，则代表成功
                    mLiveGiftDialogHelper.setSendableListSuccess(ListUtils.isList(mRoomGiftManager.getLocalSendableList()));
                }

                if (ListUtils.isList(giftTypeList)) {
                    mPagerAdapter = new MyNewPageAdapter(giftTypeList);
                    mViewPager.setAdapter(mPagerAdapter);
                    mTabView.setViewPager(mViewPager);

                    // free 标签显示右上角星星
                    if (hasPackageItems) {
                        showStarTab();
                    }

                    if (isErrorReClick && errorReClickTabPos != ERROR_TAB_POS) {
                        // 重回上次出错的 tab 位置
                        mViewPager.setCurrentItem(errorReClickTabPos);
                    } else {
                        if (giftTypeList.size() > 1 && tabCurPosition == 0) {
                            // 这里先跳转到 1 位置，是因为直接跳转到 0 位置时，会出现 tab 的文字不重绘，即不显示的问题，暂时这样处理
                            mViewPager.setCurrentItem(1);
                            mViewPager.setCurrentItem(0);
                        } else {
                            mViewPager.setCurrentItem(tabCurPosition);
                        }
                    }
                }

                // 恢复默认
                isErrorReClick = false;
                errorReClickTabPos = ERROR_TAB_POS;
            }
        });
    }


    @Override
    public void onClick(View v) {
        int id = v.getId();

        if (id == R.id.dialog_live_virtual_gift_iv_back) {
            dismiss();
        } else if (id == R.id.dialog_live_virtual_gift_iv_question) {
            VirtualGiftStoreTipDialog virtualGiftStoreTipDialog = new VirtualGiftStoreTipDialog(mContext);
            virtualGiftStoreTipDialog.show();
        }
    }

    private void showStarTab() {
        mTabView.showStar(R.drawable.ic_star_red, 0, 2, 10);
    }

    /**
     * 更新直播间信息（目前主要是用户等级改变或房间亲密度改变）
     *
     * @param imRoomInItem
     */
    public void updateRoomInfo(IMRoomInItem imRoomInItem) {
        //更新本地信息及模块共享内存区
        this.mIMRoomInItem = imRoomInItem;
        mLiveGiftDialogHelper.updateManLevel(mIMRoomInItem.manLevel);
        mLiveGiftDialogHelper.updateRoomLevel(mIMRoomInItem.loveLevel);

        notifyGiftListDataChange();
    }

    /**
     * 通知更新所有礼物的状态（尤其切换可能多页之间切换）
     */
    public void notifyGiftListDataChange() {
        if (mPagerAdapter != null) {
            mPagerAdapter.notifyGiftListDataChange();
        }
    }

    /**
     * 礼物发送失败通知
     */
    public void notifyGiftSentFailed() {
        //停止连击动画
//        stopRepeatSendGift();
    }


    /**
     * 礼物 item 的点击事件回调
     */
    LiveVirtualGiftBaseLayout.OnVirtualGiftListListener mOnOnVirtualGiftListListener = new LiveVirtualGiftBaseLayout.OnVirtualGiftListListener() {
        @Override
        public void onGiftClick(boolean isPackage, GiftTypeItem giftTypeItem, String giftId, int pos) {
            sendGiftInternal(isPackage, giftId);
        }

        @Override
        public void onErrorClick() {
            isErrorReClick = true;
            errorReClickTabPos = mViewPager.getCurrentItem();

            reloadErrorData();
        }
    };

    /**
     * 点击礼物发送
     *
     * @param isPackage
     * @param giftId
     */
    public void sendGiftInternal(boolean isPackage, String giftId) {
        if (!checkSendGift(isPackage, giftId)) {
            return;
        }

        // 判断是否同一个 item
        boolean diffGift = false;
        if (TextUtils.isEmpty(lastSendGiftId)) {
            lastSendGiftId = "";
        }
        if (!lastSendGiftId.equals(giftId)) {
            diffGift = true;
        }
        lastSendGiftId = giftId;

        // 发送
        sendGift(isPackage, giftId, diffGift);
    }

    private synchronized void sendGift(boolean isPackage, String giftId, boolean diffGift) {
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);
        if (giftItem != null) {
            //对gift是否为normal的判断加不加没有影响应该，但是为了保持同ios男士端做法一直，加上
            boolean isRepeat = giftItem.giftType == GiftItem.GiftType.Normal && giftItem.canMultiClick
                    && !diffGift && (System.currentTimeMillis() - lastGiftSendTime) <= 3000L;

            int sendNum = 1;

            if (isPackage) {
                // Free 背包礼物
                PackageGiftItem packageGiftItem = mRoomGiftManager.getLocalPackageItem(giftId);
                if (packageGiftItem != null) {
                    GiftSender.getInstance().sendBackpackGift(giftItem, isRepeat, sendNum, packageGiftItem.num, null);
                    //更新本地
                    int leftCount = packageGiftItem.num - sendNum;
                    if (leftCount > 0) {
                        packageGiftItem.num = leftCount;
                    } else {
                        packageGiftItem.num = 0;
                    }

                    //更新界面
                    LiveVirtualGiftFreeLayout view = mPagerAdapter.getFreeView();
                    if (view != null) {
                        view.notifyDataPosition(view.getClickPos());
                    }
                }
            } else {
                // 一般虚拟礼物
                GiftSender.getInstance().sendStoreGift(giftItem, isRepeat, sendNum, null);
            }

            // 记录该次发送时间
            lastGiftSendTime = System.currentTimeMillis();
        }
    }

    private boolean checkSendGift(boolean isPackage, String giftId) {
        String msg = "";
        GiftItem giftItem = NormalGiftManager.getInstance().getLocalGiftDetail(giftId);

        if (giftItem != null) {
            // 房间权限、亲密度判断
            if (!mRoomGiftManager.checkGiftSendable(giftId)) {
                //当前礼物不在可发送列表
                msg = mContext.getResources().getString(R.string.liveroom_gift_pack_notsendable);
            } else {
                //可发送，检测亲密度及等级
                if (giftItem.levelLimit > mIMRoomInItem.manLevel) {
                    msg = mContext.getResources().getString(R.string.liveroom_gift_user_levellimit, String.valueOf(giftItem.levelLimit));
                } else if (giftItem.lovelevelLimit > mIMRoomInItem.loveLevel) {
                    msg = mContext.getResources().getString(R.string.liveroom_gift_intimacy_levellimit, String.valueOf(giftItem.lovelevelLimit));
                }
            }
            if (!TextUtils.isEmpty(msg)) {
                if (mLiveGiftDialogEventListener != null) {
                    mLiveGiftDialogEventListener.onShowToastTipsNotify(msg);
                }
                return false;
            }


            // 信用点、数量判断
            if (isPackage) {
                // Free 背包礼物数量判断
                PackageGiftItem packageGiftItem = mRoomGiftManager.getLocalPackageItem(giftId);
                if (packageGiftItem != null && packageGiftItem.num <= 0) {
                    ToastUtil.showToast(mContext, R.string.live_room_error_pkg_gift_not_enough);
                    return false;
                }
            } else {
                // 一般虚拟礼物信用点判断
                double reqCoins = giftItem.credit;
                double localCoins = LiveRoomCreditRebateManager.getInstance().getCredit();
                if (localCoins < reqCoins) {
                    if (mLiveGiftDialogEventListener != null) {
                        mLiveGiftDialogEventListener.onNoEnoughMoneyTips();
                    }
                    return false;
                }
            }
        }

        return true;
    }

    //***************************************** 外部交互接口 *******************************************/
    public interface LiveGiftDialogEventListener {
        //通知外面需要弹toast提示
        void onShowToastTipsNotify(String message);

        //发送礼物信用点不足通知
        void onNoEnoughMoneyTips();
    }

    /**
     * 设置事件监听器
     *
     * @param listener
     */
    public void setLiveGiftDialogEventListener(LiveGiftDialogEventListener listener) {
        mLiveGiftDialogEventListener = listener;
    }


    //***********************************   Adapter     *************************************************

    /**
     * Adapter
     */
    private class MyNewPageAdapter extends PagerAdapter {

        private List<LiveVirtualGiftBaseLayout> list;
        private List<GiftTypeItem> titleList;

        public MyNewPageAdapter(List<GiftTypeItem> titles) {
            list = new ArrayList<>();
            titleList = new ArrayList<>();

            setData(titles);
        }

        @Override
        public int getCount() {
            return titleList.size();
        }

        @Override
        public boolean isViewFromObject(@NonNull View view, @NonNull Object object) {
            return view == object;
        }

        @Override
        public void destroyItem(@NonNull ViewGroup container, int position, @NonNull Object object) {
//            super.destroyItem(container, position, object);

            container.removeView((View) object);
        }

        @NonNull
        @Override
        public Object instantiateItem(@NonNull ViewGroup container, int position) {
            LiveVirtualGiftBaseLayout view = list.get(position);
            container.addView(view);
            return view;
        }

        @Nullable
        @Override
        public CharSequence getPageTitle(int position) {
            return titleList.get(position).typeName;
        }

        private void setData(List<GiftTypeItem> titleList) {
            if (ListUtils.isList(titleList)) {
                this.titleList.clear();
                this.titleList.addAll(titleList);

                list.clear();

                for (GiftTypeItem giftTypeItem : titleList) {
                    LiveVirtualGiftBaseLayout fragment = null;

                    if (GiftTypeItem.isFreeGiftType(giftTypeItem)) {
                        // free 标签
                        fragment = new LiveVirtualGiftFreeLayout(mContext,
                                mLiveGiftDialogHelper, mRoomGiftManager, mRoomVirtualGiftManager, giftTypeItem);
                    } else {
                        // 一般标签，包括 all 标签
                        fragment = new LiveVirtualGiftNormalLayout(mContext,
                                mLiveGiftDialogHelper, mRoomGiftManager, mRoomVirtualGiftManager, giftTypeItem);
                    }

                    // 事件回调
                    fragment.setOnVirtualGiftListListener(mOnOnVirtualGiftListListener);

                    list.add(fragment);
                }
            }
        }

        /**
         * 通知列表 adapter 刷新 item 数据
         */
        public void notifyGiftListDataChange() {
            for (LiveVirtualGiftBaseLayout layout : list) {
                layout.notifyGiftListDataChange();
            }
        }

        /**
         * 获取背包 Free View
         */
        public LiveVirtualGiftFreeLayout getFreeView() {
            LiveVirtualGiftFreeLayout view = null;

            for (LiveVirtualGiftBaseLayout layout : list) {
                if (layout instanceof LiveVirtualGiftFreeLayout) {
                    view = (LiveVirtualGiftFreeLayout) layout;
                    break;
                }
            }

            return view;
        }
    }

}
