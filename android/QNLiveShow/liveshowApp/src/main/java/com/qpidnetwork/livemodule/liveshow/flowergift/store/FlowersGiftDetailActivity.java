package com.qpidnetwork.livemodule.liveshow.flowergift.store;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextUtils;
import android.text.style.AbsoluteSizeSpan;
import android.text.style.ForegroundColorSpan;
import android.text.style.StyleSpan;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseActionBarFragmentActivity;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnGetFlowerGiftDetailCallback;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftItem;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersGiftAddCartErrorHelper;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersGiftUtil;
import com.qpidnetwork.livemodule.liveshow.flowergift.receiver.ReceiverChooseDialog;
import com.qpidnetwork.livemodule.liveshow.model.http.HttpRespObject;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

/**
 * 2019/10/11 Hardy
 * 鲜花礼品详情页
 */
public class FlowersGiftDetailActivity extends BaseActionBarFragmentActivity implements OnGetFlowerGiftDetailCallback {

    private static final int GET_DATA_CODE_DETAIL = 10;
    private static final int GET_DATA_CODE_ADD_CART = 12;
    private static final String ANCHOR_ID = "anchorId";
    private static final String GIFT_ID = "giftId";

    private SimpleDraweeView mIvBg;
    private TextView mTvName;
//    private TextView mTvId;
    private TextView mTvMoneySymbol;
    private TextView mTvMoneyRed;
    private TextView mTvMoneyGrey;
    private TextView mTvDesc;
    private Button mBtnAdd;

    private String mAnchorId = "";
    private String mGiftId = "";

    // 出错处理
    private FlowersGiftAddCartErrorHelper mAddCartErrorHelper;

    private ReceiverChooseDialog mReceiverDialog;

    /**
     * 启动方式
     *
     * @param anchorId 赋空值：在 store、my cart、delivery 页面打开礼物详情
     *                 不为空：在 continue shopping 页面打开礼物详情
     */
    public static void startAct(Context context, String anchorId, String giftId, int requestCode) {
        Intent intent = new Intent(context, FlowersGiftDetailActivity.class);
        intent.putExtra(ANCHOR_ID, anchorId);
        intent.putExtra(GIFT_ID, giftId);
        ((Activity) context).startActivityForResult(intent, requestCode);
    }

    public static void startAct(Context context, String giftId, int requestCode) {
        startAct(context, "", giftId, requestCode);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setCustomContentView(R.layout.activity_flowers_gift_detail);

        initView();
        initData();
    }

    private void initView() {
        setOnlyTitle("Gift & Flower Detail");

        if (getIntent() != null) {
            mAnchorId = getIntent().getStringExtra(ANCHOR_ID);
            mGiftId = getIntent().getStringExtra(GIFT_ID);
        }

        mIvBg = findViewById(R.id.act_flowers_detail_iv_bg);
        mTvName = findViewById(R.id.act_flowers_detail_tv_name);
//        mTvId = findViewById(R.id.act_flowers_detail_tv_id);
        mTvMoneySymbol = findViewById(R.id.item_flowers_store_tv_money_symbol);
        mTvMoneyRed = findViewById(R.id.item_flowers_store_tv_money_red);
        mTvMoneyGrey = findViewById(R.id.item_flowers_store_tv_money_grey);
        mTvDesc = findViewById(R.id.act_flowers_detail_tv_desc);

        mTvMoneySymbol.setVisibility(View.GONE);

        mBtnAdd = findViewById(R.id.act_flowers_detail_btn_add);
        mBtnAdd.setOnClickListener(this);
    }

    private void initData() {
        mAddCartErrorHelper = new FlowersGiftAddCartErrorHelper(mContext);

        loadDetail();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        if (mReceiverDialog != null) {
            mReceiverDialog.dismiss();
        }
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);

        int id = v.getId();
        if (id == R.id.act_flowers_detail_btn_add) {
            if (isContinueShopping()) {
                showToastProgressing("Loading...");

                addToGiftCart(mAnchorId, mGiftId);
            } else {
                // 2019/10/11 选择联系人弹窗
                showReceiversSelectDialog(mGiftId);
            }
        }
    }

    @Override
    protected void handleUiMessage(Message msg) {
        super.handleUiMessage(msg);

        HttpRespObject respObject = (HttpRespObject) msg.obj;
        switch (msg.what) {
            case GET_DATA_CODE_DETAIL: {
                if (respObject.isSuccess) {
                    setData((LSFlowerGiftItem) respObject.data);
                } else {
                    ToastUtil.showToast(mContext, respObject.errMsg);
                }
            }
            break;

            case GET_DATA_CODE_ADD_CART: {
                cancelToastImmediately();

                if (respObject.isSuccess) {
                    setResult(Activity.RESULT_OK);
                    finish();
                } else {
                    // 2019/10/11 出错弹窗提示
                    mAddCartErrorHelper.handlerAddCartError(respObject.errCode, respObject.errMsg, mAnchorId);
                }
            }
            break;

            default:
                break;
        }
    }

    /**
     * 是否当前在 continue shopping 页面打开礼物详情
     * 则点击加入按钮直接以当前主播为收件对象添加到购物车（不用再选择收货人），跳转至加入购物车成功页
     */
    private boolean isContinueShopping() {
        return !TextUtils.isEmpty(mAnchorId);
    }

    private void setData(LSFlowerGiftItem item) {
        if (item == null) {
            return;
        }

        mTvMoneySymbol.setVisibility(View.VISIBLE);

        FlowersGiftUtil.handlerFlowersDetailPrice(mTvMoneyRed, mTvMoneyGrey, item);
        int radius = DisplayUtil.dip2px(mContext, 3);
        FrescoLoadUtil.loadUrl(mContext, mIvBg, item.giftImg, DisplayUtil.getScreenWidth(mContext),
                R.color.black4, false, radius, radius, radius, radius);

        mTvDesc.setText(item.giftDescription);

//        mTvName.setText(item.giftName);
//        mTvId.setText(mContext.getString(R.string.flowers_gift_item_code, item.giftId));

        String id = mContext.getString(R.string.flowers_gift_item_code, item.giftId);
        String val = item.giftName + "  " + id;

        SpannableString spString = new SpannableString(val);
        // 起始位置
        int startIndex = val.indexOf(id);
        int endIndex = startIndex + id.length();
        // 字体颜色
        ForegroundColorSpan span = new ForegroundColorSpan(ContextCompat.getColor(mContext, R.color.text_color_grey_light));
        spString.setSpan(span, startIndex, endIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        // 字体大小
        AbsoluteSizeSpan spanSize = new AbsoluteSizeSpan(DisplayUtil.sp2px(mContext, 14));  // 14sp
        spString.setSpan(spanSize, startIndex, endIndex, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        // 粗体
        StyleSpan spanBold = new StyleSpan(Typeface.BOLD);
        spString.setSpan(spanBold, 0, item.giftName.length(), Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTvName.setText(spString);
    }


    /**
     * 收货人选择
     *
     * @param giftId
     */
    private void showReceiversSelectDialog(String giftId) {
        if (mReceiverDialog == null) {
            mReceiverDialog = new ReceiverChooseDialog(mContext);
            mReceiverDialog.setOnReceiversProcessResultListener(new ReceiverChooseDialog.OnReceiversProcessResultListener() {
                @Override
                public void onGetReceiverListError() {

                }

                @Override
                public void onAddGiftCartCallback(boolean isSuccess, int errCode, String errMsg, String anchorId) {

                }
            });
        }

        mReceiverDialog.bindGiftId(giftId);
        mReceiverDialog.show();
    }


    /**
     * 礼物详情
     */
    private void loadDetail() {
        LiveRequestOperator.getInstance().GetFlowerGiftDetail(mGiftId, this);
    }

    @Override
    public void onGetFlowerGiftDetail(boolean isSuccess, int errCode, String errMsg, LSFlowerGiftItem glowerGiftItem) {
        HttpRespObject respObject = new HttpRespObject(isSuccess, errCode, errMsg, glowerGiftItem);
        Message message = Message.obtain();
        message.what = GET_DATA_CODE_DETAIL;
        message.obj = respObject;
        mHandler.sendMessage(message);
    }

    /**
     * 添加礼物到购物车
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
