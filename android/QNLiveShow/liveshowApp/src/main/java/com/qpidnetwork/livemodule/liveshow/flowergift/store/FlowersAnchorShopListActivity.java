package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.os.Message;
import android.support.annotation.Nullable;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetUserInfoCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftItem;
import com.qpidnetwork.livemodule.httprequest.item.UserInfoItem;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersGiftAddCartErrorHelper;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersGiftCommonTipDialog;
import com.qpidnetwork.livemodule.liveshow.flowergift.checkout.CheckOutActivity;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.livemodule.utils.ShoppingCarAnimUtil;
import com.qpidnetwork.livemodule.view.BadgeHelper;
import com.qpidnetwork.qnbridgemodule.util.FragmentUtils;

import q.rorbin.badgeview.Badge;
import q.rorbin.badgeview.QBadgeView;


/**
 * 2019/10/10 Hardy
 * 主播——添加鲜花礼品
 *
 * Hunter说加android:launchMode="singleTask"
 */
public class FlowersAnchorShopListActivity extends BaseActionBarFragmentActivity implements OnGetUserInfoCallback {

    private static final int GET_DATA_CODE_ANCHOR_INFO = 20;
    private static final int GET_DATA_CODE_ADD_CART = 21;

    private static final String ANCHOR_ID = "anchorId";
    private static final String ANCHOR_NAME = "anchorName";
    private static final String ANCHOR_IMG = "anchorImg";
    private static final String IS_SHOW_ADD_CART_DIALOG = "isShowAddCartDialog";

    //控件
    private TextView mTvTitleName;
    private SimpleDraweeView mIvTitleIcon;
    private Button mBtnCheckout;
    private Badge mRedCircle;

    private FlowersStoreListFragment storeListFragment;
    // dialog
    private FlowersGiftCommonTipDialog mExitTipDialog;
    private FlowersGiftCommonTipDialog mAddCartSuccessDialog;

    private String mAnchorId = "";
    private String mAnchorName = "";
    private String mAnchorImg = "";
    private boolean isShowAddCartDialog;

    /*
        记录一个完整的事务
        5.continue shopping 页面点击+直到动画播放完成是否需要卡住:
        不需要,点击+后,事务未处理完成,其他点击不处理(一个完整的事务 点击=>调用加入购物车=>添加成功=>播放动画=>动画完成);
     */
    private boolean isGiftAdding;
    private View mStartAnimView;
    private String mStartAnimUrl;

    // 出错处理
    private FlowersGiftAddCartErrorHelper mAddCartErrorHelper;

    /**
     * 启动方式
     *
     * @param isShowAddCartDialog 是否进入页面展示 加入购物车成功弹窗
     */
    public static void startAct(Context context, String anchorId,
                                String anchorName, String anchorImgUrl,
                                boolean isShowAddCartDialog) {
        Intent intent = new Intent(context, FlowersAnchorShopListActivity.class);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(ANCHOR_NAME, anchorName);
        intent.putExtra(ANCHOR_IMG, anchorImgUrl);
        intent.putExtra(IS_SHOW_ADD_CART_DIALOG, isShowAddCartDialog);
        context.startActivity(intent);
    }

    public static void startAct(Context context, String anchorId,
                                String anchorName, String anchorImgUrl) {
        startAct(context, anchorId, anchorName, anchorImgUrl, false);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        initViews();
        initIntentData();
        initData();
    }

    private void initViews() {
        //自定义Title
        View titleView = LayoutInflater.from(mContext).inflate(R.layout.layout_checkout_title, ll_title_body, false);
        setCustomTitleView(titleView);
        mTvTitleName = findViewById(R.id.tvName);
        mIvTitleIcon = findViewById(R.id.img_anchor);
        mBtnCheckout = findViewById(R.id.btn_checkout);
        mBtnCheckout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                CheckOutActivity.lanchAct(mContext, mAnchorId, mAnchorName, mAnchorImg);
            }
        });

        mBtnCheckout.setVisibility(View.VISIBLE);
        mRedCircle = new QBadgeView(mContext).bindTarget(ll_title_body);
        mRedCircle.setBadgeGravity(Gravity.TOP | Gravity.END);
        BadgeHelper.setBaseStyle(mContext, mRedCircle);
        mRedCircle.setGravityOffset(3, 2, true);
    }

    private void initIntentData() {
        Bundle bundle = getIntent().getExtras();
        if (bundle != null) {
            if (bundle.containsKey(IS_SHOW_ADD_CART_DIALOG)) {
                isShowAddCartDialog = bundle.getBoolean(IS_SHOW_ADD_CART_DIALOG, false);
            }
            if (bundle.containsKey(ANCHOR_ID)) {
                mAnchorId = bundle.getString(ANCHOR_ID);
            }
            if (bundle.containsKey(ANCHOR_NAME)) {
                mAnchorName = bundle.getString(ANCHOR_NAME);
                mTvTitleName.setText(mAnchorName);
            }
            if (bundle.containsKey(ANCHOR_IMG)) {
                mAnchorImg = bundle.getString(ANCHOR_IMG);
                if (!TextUtils.isEmpty(mAnchorImg)) {
                    setIcon(mAnchorImg);
                }
            }
        }
    }

    private void setIcon(String url) {
        FrescoLoadUtil.loadUrl(mContext, mIvTitleIcon, url,
                mContext.getResources().getDimensionPixelSize(R.dimen.my_cart_anchor_img_size),
                R.color.black4, true);
    }

    private void initData() {
        // add fragment
        storeListFragment = new FlowersStoreListFragment();
        storeListFragment.setAnchorId(mAnchorId);
        storeListFragment.setOnFlowersStoreMainListener(onFlowersStoreMainListener);
        FragmentUtils.addFragment(getSupportFragmentManager(), storeListFragment, R.id.llContainer);

        mAddCartErrorHelper = new FlowersGiftAddCartErrorHelper(mContext);

        // 加载主播资料
        if (TextUtils.isEmpty(mAnchorName) || TextUtils.isEmpty(mAnchorImg)) {
            loadAnchorInfo();
        }

        // 是否展示加入购物车成功弹窗?
        if (isShowAddCartDialog) {
            mHandler.postDelayed(new Runnable() {
                @Override
                public void run() {
                    showAddCartSuccessDialog();
                }
            }, 1000);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (mExitTipDialog != null) {
            mExitTipDialog.destroy();
            mExitTipDialog = null;
        }
        if (mAddCartSuccessDialog != null) {
            mAddCartSuccessDialog.destroy();
            mAddCartSuccessDialog = null;
        }
    }

    @Override
    public void onClick(View v) {
//        super.onClick(v);

        int id = v.getId();
        if (id == R.id.iv_commBack) {
            onBackPressed();
        }
    }

    @Override
    public void onBackPressed() {
//        super.onBackPressed();

        if (mRedCircle.getBadgeNumber() > 0) {
            // 若当前主播有为结算的商品，则弹出
            showExitDialog();
        } else {
            super.onBackPressed();
        }
    }

    /**
     * 退出页面拦截弹窗
     */
    private void showExitDialog() {
        if (mExitTipDialog == null) {
            mExitTipDialog = new FlowersGiftCommonTipDialog(mContext) {
                @Override
                public void onBtnTopClick() {
                    mBtnCheckout.performClick();
                }

                @Override
                public void onBtnBottomClick() {
                    finish();
                }
            };

            mExitTipDialog.setTitleText("You have unfinished order, settle now?");
            mExitTipDialog.setBtnTopText(mContext.getString(R.string.proceed_to_checkout));
            mExitTipDialog.setBtnBottomText(mContext.getString(R.string.continue_to_exit));
        }

        mExitTipDialog.show();
    }


    /**
     * 加入购物车成功弹窗.
     */
    private void showAddCartSuccessDialog() {
        if (mAddCartSuccessDialog == null) {
            mAddCartSuccessDialog = new FlowersGiftCommonTipDialog(mContext) {
                @Override
                public void onBtnTopClick() {
                    mBtnCheckout.performClick();
                }

                @Override
                public void onBtnBottomClick() {

                }
            };

            mAddCartSuccessDialog.setTitleIconText("This item has been successfully");
            mAddCartSuccessDialog.setTitleText("added to your cart!");
            mAddCartSuccessDialog.setBtnTopText(mContext.getString(R.string.proceed_to_checkout));
            mAddCartSuccessDialog.setBtnBottomText(mContext.getString(R.string.continue_shopping));
        }

        mAddCartSuccessDialog.show();
    }


    /**
     * Fragment 的事件回调
     */
    FlowersStoreListFragment.OnFlowersStoreMainListener onFlowersStoreMainListener = new FlowersStoreListFragment.OnFlowersStoreMainListener() {
        @Override
        public void onCountChange(int num) {
            if (num < 0) {
                num = 0;
            }
            mRedCircle.setBadgeNumber(num);
        }

        @Override
        public void onGiftAdd(LSFlowerGiftItem item, View startView) {
            if (isGiftAdding) {
                return;
            }
            if (item != null && startView != null) {
                isGiftAdding = true;
                mStartAnimView = startView;
                mStartAnimUrl = item.giftImg;

                addToGiftCart(mAnchorId, item.giftId);
            }
        }
    };

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject respObject = (HttpRespObject) msg.obj;
        switch (msg.what) {
            case GET_DATA_CODE_ANCHOR_INFO: {
                UserInfoItem userItem = (UserInfoItem) respObject.data;
                if (respObject.isSuccess && userItem != null) {
                    mAnchorName = userItem.nickName;
                    mAnchorImg = userItem.photoUrl;

                    mTvTitleName.setText(mAnchorName);
                    setIcon(mAnchorImg);
                }
            }
            break;

            case GET_DATA_CODE_ADD_CART: {
                if (respObject.isSuccess) {
                    // 2019/10/10 开启动画
                    ShoppingCarAnimUtil animManager = new ShoppingCarAnimUtil.Builder()
                            .with(this)
                            .startView(mStartAnimView)
                            .endView(mBtnCheckout)
                            .imageUrl(mStartAnimUrl)
                            .animWidth(mStartAnimView.getWidth())
                            .animHeight(mStartAnimView.getHeight())
                            .listener(new ShoppingCarAnimUtil.AnimListener() {
                                @Override
                                public void setAnimBegin(ShoppingCarAnimUtil a) {

                                }

                                @Override
                                public void setAnimEnd(ShoppingCarAnimUtil a) {
                                    isGiftAdding = false;
                                    // 刷新数量
                                    storeListFragment.loadCartCount();
                                }
                            }).build();
                    animManager.startAnim();
                } else {
                    isGiftAdding = false;
                    // 2019/10/11 出错弹窗提示
                    mAddCartErrorHelper.handlerAddCartError(respObject.errCode, respObject.errMsg, mAnchorId);
                }
            }
            break;

            default:
                break;
        }
    }


    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        switch (requestCode) {
            case FlowersStoreListFragment.REQUEST_CODE_DETAIL: {
                if (resultCode == Activity.RESULT_OK) {
                    storeListFragment.loadCartCount();
                    showAddCartSuccessDialog();
                }
            }
            break;

            default:
                break;
        }
    }

    private void loadAnchorInfo() {
        LiveRequestOperator.getInstance().GetUserInfo(mAnchorId, this);
    }

    @Override
    public void onGetUserInfo(boolean isSuccess, int errCode, String errMsg, UserInfoItem userItem) {
        HttpRespObject object = new HttpRespObject(isSuccess, errCode, errMsg, userItem);
        Message message = Message.obtain();
        message.what = GET_DATA_CODE_ANCHOR_INFO;
        message.obj = object;
        mHandler.sendMessage(message);
    }

    /**
     * 添加礼物到购物车
     *
     * @param anchorId
     * @param giftId
     */
    private void addToGiftCart(String anchorId, String giftId) {
        LiveRequestOperator.getInstance().AddCartGift(anchorId, giftId, new OnRequestCallback() {
            @Override
            public void onRequest(final boolean isSuccess, final int errCode, final String errMsg) {
                HttpRespObject object = new HttpRespObject(isSuccess, errCode, errMsg, "");
                Message message = Message.obtain();
                message.what = GET_DATA_CODE_ADD_CART;
                message.obj = object;
                mHandler.sendMessage(message);
            }
        });
    }
}
