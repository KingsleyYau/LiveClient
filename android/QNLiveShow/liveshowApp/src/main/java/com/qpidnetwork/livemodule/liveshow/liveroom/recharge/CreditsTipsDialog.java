package com.qpidnetwork.livemodule.liveshow.liveroom.recharge;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import com.qpidnetwork.qnbridgemodule.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;


public class CreditsTipsDialog extends Dialog implements View.OnClickListener {

    private final String TAG = CreditsTipsDialog.class.getSimpleName();
    private Context mContext;
    private View rootView;
    private ImageView iv_closeCreditsTips;
    private TextView tv_balanceTips;
    private String creditsTips;
    private TextView tv_getCredits;

    //没钱参数配置
    private NoMoneyParamsBean mNoMoneyParamsBean;

    public CreditsTipsDialog(Context context) {
        super(context, R.style.CustomTheme_SimpleDialog);
        Log.d(TAG, "CreditsTipsDialog");
        this.mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//        getWindow().setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
//                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
//        getWindow().setFlags(WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
//                WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH);
        this.rootView = View.inflate(mContext, R.layout.view_credits_tips, null);
        initView();
        setContentView(rootView);
        getWindow().setLayout(WindowManager.LayoutParams.MATCH_PARENT,WindowManager.LayoutParams.WRAP_CONTENT);
        setCanceledOnTouchOutside(false);
        setCancelable(true);
        mNoMoneyParamsBean = new NoMoneyParamsBean();
    }

    private void initView() {
        Log.d(TAG, "initView");
        iv_closeCreditsTips = (ImageView) rootView.findViewById(R.id.iv_closeCreditsTips);
        iv_closeCreditsTips.setOnClickListener(this);
        tv_balanceTips = (TextView) rootView.findViewById(R.id.tv_balanceTips);
        tv_getCredits = (TextView) rootView.findViewById(R.id.tv_getCredits);
        tv_getCredits.setOnClickListener(this);

    }

    private void updateViewData() {
        if(null != creditsTips){
            tv_balanceTips.setText(creditsTips);
        }
    }

    @Override
    public void onClick(View v) {
        int i = v.getId();
        if (i == R.id.iv_closeCreditsTips) {
            dismiss();

        } else if (i == R.id.tv_getCredits) {
            LiveModule.getInstance().onAddCreditClick(mContext, mNoMoneyParamsBean);
            //GA统计点击充值
            AnalyticsManager.getsInstance().ReportEvent(mContext.getResources().getString(R.string.Live_Global_Category),
                    mContext.getResources().getString(R.string.Live_Global_Action_AddCredit),
                    mContext.getResources().getString(R.string.Live_Global_Label_AddCredit));
            dismiss();
        }
    }

    @Override
    public void show() {
        super.show();
        updateViewData();
    }

    public void setCreditsTips(String creditsTips){
        this.creditsTips = creditsTips;
    }

    /**
     * 设置没钱传递参数
     * @param params
     */
    public void setmNoMoneyParamsBean(NoMoneyParamsBean params){
        mNoMoneyParamsBean = params;
    }
}
