package com.qpidnetwork.livemodule.liveshow.liveroom.gift.dialog;

import android.content.Context;
import android.support.annotation.NonNull;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.GiftItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutAnchorInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.HangoutGiftListItem;
import com.qpidnetwork.livemodule.im.listener.IMHangoutRoomItem;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.HangOutGiftSender;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.HangoutRoomGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.gift.NormalGiftManager;
import com.qpidnetwork.livemodule.liveshow.liveroom.rebate.LiveRoomCreditRebateManager;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpReqStatus;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.livemodule.view.HangoutGiftDialogLayout;
import com.qpidnetwork.livemodule.view.HangoutGiftListBaseLayout;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.util.UIUtils;
import com.qpidnetwork.qnbridgemodule.view.BaseSafeDialog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Hardy on 2019/3/14.
 * <p>
 * Hangout 的礼物 dialog
 */
public class HangoutGiftDialog implements HangOutGiftSender.HangOutGiftSendResultListener {

    private static final String TAG = "info";

    // dialog
    protected BaseSafeDialog dialog;
    // view
    private Context mContext;
    private HangoutGiftDialogLayout mRootView;
    private View mBlurRootView;
    // data
    private Map<String, GiftItem> giftItemMap = new HashMap<>();
    private List<GiftItem> barCounterGiftItems = new ArrayList<>();
    private List<GiftItem> storeGiftItems = new ArrayList<>();
    private List<GiftItem> celebGiftItems = new ArrayList<>();
    // item
    private IMHangoutRoomItem imHangoutRoomItem;
    private GiftItem lastSelectedGiftItem = null;   //用于礼物发送、连送动画逻辑展示
    // manager
    private HangoutRoomGiftManager mHangoutRoomGiftManager;

    // 是否有礼物数据更新
    private boolean hasHangOutGiftDataChanged = false;

    private long lastGiftSendTime = 0L;


    public HangoutGiftDialog(@NonNull Context context, HangoutRoomGiftManager mHangoutRoomGiftManager) {
        this.mContext = context;
        this.mHangoutRoomGiftManager = mHangoutRoomGiftManager;
        init();
    }

    private void init() {
        mRootView = (HangoutGiftDialogLayout) View.inflate(mContext, R.layout.dialog_hang_out_gift, null);

        dialog = new BaseSafeDialog(mContext, R.style.CustomTheme_LiveGiftDialog);
        dialog.setContentView(mRootView);
        initView(mRootView);

        //设置 dialog 窗口宽高，在 setContentView 之后设置
        if (dialog.getWindow() != null) {
            WindowManager.LayoutParams layoutParams = dialog.getWindow().getAttributes();
            layoutParams.gravity = Gravity.BOTTOM;
            layoutParams.width = DisplayUtil.getScreenWidth(mContext);
            dialog.getWindow().setAttributes(layoutParams);
        }

        // 设置数据
        initData();
    }

    private void initView(View view) {
        mRootView.setOnGiftItemClickListener(onGiftItemClickListener);
        mRootView.setOnHangoutGiftLayoutOperaListener(onHangoutGiftLayoutOperaListener);
    }

    private void initData() {
        updateGiftView();
    }


    public void show() {
        // 防止在退出直播间时，继续操作发送礼物，导致窗口没关闭而内存泄漏
        if (!UIUtils.isActExist(mContext)) {
            return;
        }

        if (dialog != null && !dialog.isShowing()) {
            dialog.show();
        }

        if (hasHangOutGiftDataChanged) {
            // 有修改礼物数据，则更新数据到 UI
            updateGiftView();
        }

        hasHangOutGiftDataChanged = false;

        showDataTipsView();

        if (mRootView != null) {
            if (mBlurRootView != null) {
                mRootView.setBlurBgView(mBlurRootView);
            }
            mRootView.enabledAddCreditsBtnDelay();
        }
    }

    public void dismiss() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

    /**
     * 更新礼物展示界面
     */
    private void updateGiftView() {
        Log.d(TAG, "updateGiftView");

        // 更新礼物列表
        mRootView.setBarData(barCounterGiftItems);
        mRootView.setStoreData(storeGiftItems);
        mRootView.setCelebData(celebGiftItems);

        // 设置状态页面
        showDataTipsView();
    }

    /**
     * 展示错误提示界面，应该在tab点击的时候，判断展示
     */
    private void showDataTipsView() {
        if (null == imHangoutRoomItem) {
            //刷新之中
            mRootView.showDataTipsViewByStatus(true, false, false);
            return;
        }

        List<GiftItem> giftList = getCurTabGiftList();

        if (!ListUtils.isList(giftList)) {
            HttpReqStatus sendableGiftReqStatus = mHangoutRoomGiftManager.getRoomGiftRequestStatus();
            if (HttpReqStatus.Reqing == sendableGiftReqStatus) {
                //刷新之中
                mRootView.showDataTipsViewByStatus(true, false, false);
            } else if (HttpReqStatus.ResFailed == sendableGiftReqStatus) {
                //加载出错
                mRootView.showDataTipsViewByStatus(false, false, true);
            } else {
                //没有数据
                mRootView.showDataTipsViewByStatus(false, true, false);
            }
        } else {
            mRootView.showDataTipsViewByStatus(false, false, false);
        }
    }

    /**
     * 更新礼物列表数据
     */
    private void updateHangOutRoomGiftData() {
        synchronized (giftItemMap) {
            //更新数据
            HangoutGiftListItem anchorHangoutGiftListItem = mHangoutRoomGiftManager.getLoaclHangoutGiftItem();

            barCounterGiftItems.clear();
            storeGiftItems.clear();
            celebGiftItems.clear();
            giftItemMap.clear();

            if (null == anchorHangoutGiftListItem) {
                return;
            }

            GiftItem giftItem = null;
            NormalGiftManager normalGiftManager = NormalGiftManager.getInstance();

            // bar
            if (null != anchorHangoutGiftListItem.buyforList) {
                for (String item : anchorHangoutGiftListItem.buyforList) {
                    giftItem = normalGiftManager.getLocalGiftDetail(item);
                    if (null != giftItem) {
                        barCounterGiftItems.add(giftItem);
                        giftItemMap.put(giftItem.id, giftItem);
                    } else {
                        //礼物详情不在，本地刷新
                        normalGiftManager.getGiftDetail(item, null);
                    }
                }
            }
            // store
            if (null != anchorHangoutGiftListItem.normalList) {
                for (String item : anchorHangoutGiftListItem.normalList) {
                    giftItem = normalGiftManager.getLocalGiftDetail(item);
                    if (null != giftItem) {
                        storeGiftItems.add(giftItem);
                        giftItemMap.put(giftItem.id, giftItem);
                    } else {
                        //礼物详情不在，本地刷新
                        normalGiftManager.getGiftDetail(item, null);
                    }
                }
            }
            //celeb
            if (null != anchorHangoutGiftListItem.celebrationList) {
                for (String item : anchorHangoutGiftListItem.celebrationList) {
                    giftItem = normalGiftManager.getLocalGiftDetail(item);
                    if (null != giftItem) {
                        celebGiftItems.add(giftItem);
                        giftItemMap.put(giftItem.id, giftItem);
                    } else {
                        //礼物详情不在，本地刷新
                        normalGiftManager.getGiftDetail(item, null);
                    }
                }
            }
        }
    }

    private List<GiftItem> getCurTabGiftList() {
        List<GiftItem> listData = null;

        int tab = mRootView.getCurTab();
        if (tab == HangoutGiftDialogLayout.TAB_BAR) {
            listData = barCounterGiftItems;
        } else if (tab == HangoutGiftDialogLayout.TAB_GIFT_STORE) {
            listData = storeGiftItems;
        } else {
            listData = celebGiftItems;
        }

        return listData;
    }


    /**
     * 送礼(调接口)
     */
    private synchronized void sendGift(GiftItem giftItem, boolean diffGift) {
        Log.d(TAG, "sendGift-giftItem:" + giftItem + " diffGift:" + diffGift);
        if (null == giftItem) {
            return;
        }

        //对gift是否为normal的判断加不加没有影响应该，但是为了保持同ios男士端做法一直，加上
        boolean isRepeat = giftItem.giftType == GiftItem.GiftType.Normal && giftItem.canMultiClick
                && !diffGift && (System.currentTimeMillis() - lastGiftSendTime) <= 3000L;

        boolean isPrivate = mRootView.isSendSecretly();

        String nickname = LoginManager.getInstance().getLoginItem() != null ? LoginManager.getInstance().getLoginItem().nickName : "";

        if (giftItem.giftType == GiftItem.GiftType.Celebrate) {
            HangOutGiftSender.getInstance().sendHangOutGift(giftItem, isRepeat, "",
                    nickname, 1, false, false, this);
        } else {
            List<String> toUidList = mRootView.getSend2AnchorId();
            int toUidLen = ListUtils.isList(toUidList) ? toUidList.size() : 0;

            if (toUidLen > 0) {
                // 循环发给主播
                for (String uid : toUidList) {
                    com.qpidnetwork.qnbridgemodule.util.Log.i("info", "OnSendGift-errType uid: " + uid);

                    HangOutGiftSender.getInstance().sendHangOutGift(giftItem, isRepeat, uid,
                            nickname, 1, false, isPrivate, this);
                }
            }
        }

        // 记录该次发送时间
        lastGiftSendTime = System.currentTimeMillis();
    }


    private boolean checkSendGift(GiftItem item) {
        // TODO: 2019/3/14 判断各种条件?
        // 直播间没人
        if (!mRootView.hasAnchorBroadcasters()) {
            ToastUtil.showToast(mContext, mContext.getString(R.string.hangout_gift_send_no_broadcasters, item.name));
            return false;
        }
        // 非庆祝礼物 且 未选中任何主播
        if (!mRootView.hasSelectAnchor() && item.giftType != GiftItem.GiftType.Celebrate) {
            ToastUtil.showToast(mContext, mContext.getString(R.string.hangout_gift_send_no_broadcasters_select, item.name));
            return false;
        }
        // 发礼物，信用点不够
        double curCredits = LiveRoomCreditRebateManager.getInstance().getCredit();
        boolean showAddCredits = curCredits - item.credit < 0;
        if (showAddCredits) {
            showNoCreditsDialog();
            return false;
        }


        return true;
    }

    //=======================   public  ===================================
    public void setImHangoutRoomItem(IMHangoutRoomItem imHangoutRoomItem) {
        this.imHangoutRoomItem = imHangoutRoomItem;
    }

    public void notifyGiftSentFailed() {
        Log.d(TAG, "notifyGiftSentFailed");
    }

    public void notifyHangOutGiftDataChanged() {
        Log.d(TAG, "notifyHangOutGiftDataChanged");

        // 更新数据
        updateHangOutRoomGiftData();

        hasHangOutGiftDataChanged = true;

        // 弹窗打开时，才更新 UI，否则，等到下次打开弹窗时，才刷新 UI 界面
        if (dialog != null && dialog.isShowing()) {
            updateGiftView();
            hasHangOutGiftDataChanged = false;
        }

        Log.d(TAG, "notifyHangOutGiftDataChanged-hasHangOutGiftDataChanged:" + hasHangOutGiftDataChanged);
    }

    /**
     * 出错重新加载
     * 让外层重写实现
     */
    public void reloadGiftData() {
    }

    /**
     * 增加信用点
     * 让外层重写实现
     */
    public void addCredits() {
    }

    /**
     * 发礼物，信用点不够的提示弹窗
     * 让外层重写实现
     */
    public void showNoCreditsDialog() {

    }

    public void setCredits(double credits) {
        mRootView.setCredits(credits);
    }

    public void setBlurBgView(View view) {
        mBlurRootView = view;
    }

    /**
     * 增加主播
     *
     * @param isAnchorMain 是否为第一个
     * @param mAnchorItem  主播信息
     */
    public synchronized void addAnchor(boolean isAnchorMain, HangoutAnchorInfoItem mAnchorItem) {
        mRootView.addAnchor(isAnchorMain, mAnchorItem);
    }

    /**
     * 主播退出直播间，隐藏
     *
     * @param anchorId 主播 id
     */
    public synchronized void hideAnchor(String anchorId) {
        mRootView.hideAnchor(anchorId);
    }
    //=======================   public  ===================================


    /**
     * 礼物的点击事件
     */
    private HangoutGiftListBaseLayout.OnGiftItemClickListener onGiftItemClickListener = new HangoutGiftListBaseLayout.
            OnGiftItemClickListener() {
        @Override
        public void onGiftClick(int pos, GiftItem giftItem) {
            if (!checkSendGift(giftItem)) {
                return;
            }

            // 发送请求
            boolean diffGift = giftItem != lastSelectedGiftItem;
            lastSelectedGiftItem = giftItem;
            sendGift(lastSelectedGiftItem, diffGift);
        }
    };

    /**
     * 界面的其它点击事件
     */
    private HangoutGiftDialogLayout.OnHangoutGiftLayoutOperaListener onHangoutGiftLayoutOperaListener = new HangoutGiftDialogLayout.
            OnHangoutGiftLayoutOperaListener() {
        @Override
        public void onErrorRetry() {
            reloadGiftData();
        }

        @Override
        public void onAddCreditsClick() {
            dismiss();
            addCredits();
        }

        @Override
        public void onTabClick(int pos) {
            // 回调内部，已做 tab 切换时的相关 ui 展示，这里不做处理
            lastSelectedGiftItem = null;
            showDataTipsView();
        }
    };


    @Override
    public void onHangOutGiftReqSent(GiftItem giftItem, HangOutGiftSender.ErrorCode errorCode, String message, boolean isRepeat, int sendNum) {

    }
}
