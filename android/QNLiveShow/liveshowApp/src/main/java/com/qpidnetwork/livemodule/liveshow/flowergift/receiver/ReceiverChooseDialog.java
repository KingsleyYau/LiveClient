package com.qpidnetwork.livemodule.liveshow.flowergift.receiver;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Paint;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.DragEvent;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.LiveRequestOperator;
import com.qpidnetwork.livemodule.httprequest.OnRequestCallback;
import com.qpidnetwork.livemodule.httprequest.item.IntToEnumUtils;
import com.qpidnetwork.livemodule.liveshow.flowergift.FlowersGiftAddCartErrorHelper;
import com.qpidnetwork.livemodule.liveshow.flowergift.store.FlowersAnchorShopListActivity;
import com.qpidnetwork.qnbridgemodule.bean.BaseUserInfo;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;
import com.qpidnetwork.qnbridgemodule.view.BaseSafeDialog;

import java.util.List;

import static com.qpidnetwork.livemodule.httprequest.item.HttpLccErrType.HTTP_LCC_ERR_FLOWERGIFT_ANCHORID_INVALID;

public class ReceiverChooseDialog extends BaseSafeDialog implements View.OnClickListener {

    private View contentView;
    private LinearLayout llCardContent;
    private RelativeLayout rlChooseAnchor;
    private ImageView ivLeftArraw;
    private RecyclerView recycleView;
    private ImageView ivRightArraw;
    private LinearLayout llIdSearch;
    private EditText etId;
    private TextView tvErrorTips;
    private Button btnOrder;
    private TextView tvSwitch;
    private ImageView ivClose;
    private ProgressBar pbLoading;

    /**
     * 纪录当前卡片状态
     */
    private enum TabType {
        TabTypeChoose,
        TabTypeId
    }

    private TabType mCurrentTabType = TabType.TabTypeChoose;
    //主播选择器
    private int mCurrentPosition = 0;
    private LiveReceiverAdapter mAdapter;
    private ReceiverListManager mReceiverListManager;

    private Activity mContext;
    private String mGiftId;
    private OnReceiversProcessResultListener mListener;
    // 出错处理
    private FlowersGiftAddCartErrorHelper mAddCartErrorHelper;

    public ReceiverChooseDialog(Activity context) {
        super(context, R.style.CustomTheme_SimpleDialog);

        init(context);
    }

    @SuppressLint("ClickableViewAccessibility")
    private void init(Activity context) {
        mContext = context;
        contentView = LayoutInflater.from(context).inflate(R.layout.dialog_receiver_choose_layout, null);
        llCardContent = (LinearLayout) contentView.findViewById(R.id.llCardContent);
        pbLoading = (ProgressBar) contentView.findViewById(R.id.pbLoading);
        rlChooseAnchor = (RelativeLayout) contentView.findViewById(R.id.rlChooseAnchor);
        ivLeftArraw = (ImageView) contentView.findViewById(R.id.ivLeftArraw);
        ivRightArraw = (ImageView) contentView.findViewById(R.id.ivRightArraw);
        llIdSearch = (LinearLayout) contentView.findViewById(R.id.llIdSearch);
        tvErrorTips = (TextView) contentView.findViewById(R.id.tvErrorTips);
        btnOrder = (Button) contentView.findViewById(R.id.btnOrder);
        ivClose = (ImageView) contentView.findViewById(R.id.ivClose);

        //Id编辑处理
        etId = (EditText) contentView.findViewById(R.id.etId);
        etId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {

            }

            @Override
            public void afterTextChanged(Editable s) {
                tvErrorTips.setVisibility(View.GONE);
            }
        });

        //添加下划线
        tvSwitch = (TextView) contentView.findViewById(R.id.tvSwitch);
        tvSwitch.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG);

        recycleView = (RecyclerView) contentView.findViewById(R.id.recycleView);
        LinearLayoutManager linearLayoutManager = new LinearLayoutManager(context);
        linearLayoutManager.setOrientation(LinearLayoutManager.HORIZONTAL);
        recycleView.setLayoutManager(linearLayoutManager);
        recycleView.setNestedScrollingEnabled(false);
        //屏蔽手动拖动等手动滚动列表动作
        recycleView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent motionEvent) {
                if (motionEvent.getAction() == MotionEvent.ACTION_MOVE
                        || motionEvent.getAction() == MotionEvent.ACTION_SCROLL) {
                    return true;
                }
                return false;
            }
        });
        recycleView.setOnDragListener(new View.OnDragListener() {
            @Override
            public boolean onDrag(View view, DragEvent dragEvent) {
                return true;
            }
        });

        recycleView.setOnFlingListener(new RecyclerView.OnFlingListener() {
            @Override
            public boolean onFling(int i, int i1) {
                return true;
            }
        });

        //add click listener
        ivClose.setOnClickListener(this);
        tvSwitch.setOnClickListener(this);
        btnOrder.setOnClickListener(this);
        ivLeftArraw.setOnClickListener(this);
        ivRightArraw.setOnClickListener(this);

        initData(context);

        this.setContentView(contentView);

        this.setCanceledOnTouchOutside(false);

//        设置宽度全屏，要设置在 setContentView 的后面
        WindowManager.LayoutParams layoutParams = getWindow().getAttributes();
        layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT;
        layoutParams.height = ViewGroup.LayoutParams.WRAP_CONTENT;
        layoutParams.gravity = Gravity.CENTER;
        getWindow().getDecorView().setPadding(0, 0, 0, 0);
        getWindow().setAttributes(layoutParams);
    }

    /**
     * 初始化数据
     */
    private void initData(Activity context) {
        // 2019/10/11 Hardy
        mAddCartErrorHelper = new FlowersGiftAddCartErrorHelper(context);

        mReceiverListManager = new ReceiverListManager(context);
        mCurrentTabType = TabType.TabTypeChoose;
        switchToTab(mCurrentTabType);
        if (mAdapter == null) {
            getReceiversList();
        }
    }

    /**
     * 绑定礼物Id
     */
    public void bindGiftId(String giftId) {
        this.mGiftId = giftId;
    }

    /**
     * 绑定事件监听器
     */
    public void setOnReceiversProcessResultListener(OnReceiversProcessResultListener listener) {
        mListener = listener;
    }

    @Override
    public void show() {
        super.show();

        if (mCurrentTabType == TabType.TabTypeChoose && mAdapter == null) {
            getReceiversList();
        }
    }

    /**
     * 刷新数据状态
     */
    private void switchToTab(TabType tabType) {
        if (tabType == TabType.TabTypeChoose) {
            rlChooseAnchor.setVisibility(View.VISIBLE);
            llIdSearch.setVisibility(View.GONE);
            tvSwitch.setText(mContext.getResources().getString(R.string.live_receiver_search_by_ID));
            // 2019/10/11 Hardy
            getListViewWidthListView();
        } else {
            rlChooseAnchor.setVisibility(View.GONE);
            llIdSearch.setVisibility(View.VISIBLE);
            tvSwitch.setText(mContext.getResources().getString(R.string.live_receiver_back));
            // 2019/10/11 Hardy
            setOrderBtnWidthInputView();
        }
    }

    private void getListViewWidthListView() {
        recycleView.post(new Runnable() {
            @Override
            public void run() {
                int width = recycleView.getWidth();
                setOrderBtnWidth(width);
            }
        });
    }

    private void setOrderBtnWidthInputView() {
        llIdSearch.post(new Runnable() {
            @Override
            public void run() {
                int width = llIdSearch.getWidth();
                setOrderBtnWidth(width);
            }
        });
    }

    private void setOrderBtnWidth(int width) {
        LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) btnOrder.getLayoutParams();
        params.width = width;
        btnOrder.setLayoutParams(params);
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();

        if (i == R.id.ivClose) {
            dismiss();

        } else if (i == R.id.tvSwitch) {
            if (mCurrentTabType == TabType.TabTypeChoose) {
                mCurrentTabType = TabType.TabTypeId;
            } else {
                mCurrentTabType = TabType.TabTypeChoose;
            }
            switchToTab(mCurrentTabType);

        } else if (i == R.id.btnOrder) {
            String anchorId = "";

            if (mCurrentTabType == TabType.TabTypeChoose) {
                if (mAdapter != null) {
                    anchorId = mAdapter.getItemInfo(mCurrentPosition).userId;
                }
            } else {
                anchorId = etId.getText().toString().trim();    // 去除空格
                // 2019/10/12 Hardy
                if (TextUtils.isEmpty(anchorId)) {
                    ToastUtil.showToast(mContext, "Please " + mContext.getString(R.string.live_receiver_enter_profile_ID));
                    return;
                }
            }

            addToGiftCart(anchorId, mGiftId);

        } else if (i == R.id.ivLeftArraw) {
            mCurrentPosition = mCurrentPosition + 1;
            recycleView.smoothScrollToPosition(mCurrentPosition);

        } else if (i == R.id.ivRightArraw) {
            if (mCurrentPosition >= 1) {
                mCurrentPosition = mCurrentPosition - 1;
                recycleView.smoothScrollToPosition(mCurrentPosition);
            }
        }
    }

    /**
     * 获取主播列表
     */
    private void getReceiversList() {
        //初始化为获取receivers状态
        llCardContent.setVisibility(View.INVISIBLE);
        pbLoading.setVisibility(View.VISIBLE);

        mReceiverListManager.getReceiversList(new ReceiverListManager.OnGetAnchorListCallback() {
            @Override
            public void onGetAnchorList(boolean isSuccess, List<BaseUserInfo> anchorList) {
                pbLoading.setVisibility(View.GONE);
                llCardContent.setVisibility(View.VISIBLE);
                if (isSuccess) {
                    mAdapter = new LiveReceiverAdapter(mContext, anchorList);
                    recycleView.setAdapter(mAdapter);
                    mCurrentPosition = Integer.MAX_VALUE / 2;//初始化到第一个
                    recycleView.scrollToPosition(mCurrentPosition);
                } else {
                    dismiss();

                    // 2019/10/11 Hardy 网络出错
                    mAddCartErrorHelper.showAddCartNormalError(mContext.getResources()
                            .getString(R.string.common_connect_error_description));

                    //通知获取 receiver 失败
                    if (mListener != null) {
                        mListener.onGetReceiverListError();
                    }
                }
            }
        });
    }

    /**
     * 添加礼物到购物车
     */
    private void addToGiftCart(final String anchorId, String giftId) {
        pbLoading.setVisibility(View.VISIBLE);
        LiveRequestOperator.getInstance().AddCartGift(anchorId, giftId, new OnRequestCallback() {
            @Override
            public void onRequest(final boolean isSuccess, final int errCode, final String errMsg) {
                mContext.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        pbLoading.setVisibility(View.GONE);
                        if (!isSuccess && mCurrentTabType == TabType.TabTypeId &&
                                IntToEnumUtils.intToHttpErrorType(errCode) == HTTP_LCC_ERR_FLOWERGIFT_ANCHORID_INVALID) {
                            //主播 ID 无效特殊处理
                            tvErrorTips.setVisibility(View.VISIBLE);
                            tvErrorTips.setText(errMsg);
                        } else {
                            dismiss();

                            // 2019/10/11 Hardy
                            if (isSuccess) {
                                //添加购物车成功，跳转到指定主播的鲜花礼品购买页面
                                FlowersAnchorShopListActivity.startAct(mContext, anchorId,
                                        "", "", true);
                            } else {
                                mAddCartErrorHelper.handlerAddCartError(errCode, errMsg, anchorId);
                            }

                            //通知外面添加购物车结果
                            if (mListener != null) {
                                mListener.onAddGiftCartCallback(isSuccess, errCode, errMsg, anchorId);
                            }
                        }
                    }
                });
            }
        });
    }

    public interface OnReceiversProcessResultListener {
        void onGetReceiverListError();

        void onAddGiftCartCallback(boolean isSuccess, int errCode, String errMsg, String anchorId);
    }

}
