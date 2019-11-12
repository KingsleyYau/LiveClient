package com.qpidnetwork.livemodule.view.dialog;

import android.content.Context;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.LiveModule;
import com.qpidnetwork.livemodule.liveshow.googleanalytics.AnalyticsManager;
import com.qpidnetwork.livemodule.liveshow.model.NoMoneyParamsBean;
import com.qpidnetwork.livemodule.view.ButtonRaised;

public class CommonBuyCreditDialog extends BaseCommonDialog{

    private TextView tvAddCredits;

    public CommonBuyCreditDialog(Context context) {
        super(context, R.layout.dialog_buy_credit);
    }

    @Override
    public void initView(View v) {
        ButtonRaised btnAddCredit = (ButtonRaised)v.findViewById(R.id.btnAddCredit);
        Button btnCancel = (Button)v.findViewById(R.id.btnCancel);
        tvAddCredits = (TextView)v.findViewById(R.id.tvAddCredits);
        btnAddCredit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                LiveModule.getInstance().onAddCreditClick(mContext, new NoMoneyParamsBean());

                //GA统计点击充值
                AnalyticsManager.getsInstance().ReportEvent(mContext.getResources().getString(R.string.Live_Global_Category),
                        mContext.getResources().getString(R.string.Live_Global_Action_AddCredit),
                        mContext.getResources().getString(R.string.Live_Global_Label_AddCredit));
                dismiss();

            }
        });

        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                dismiss();
            }
        });
    }

    /**
     * 设置弹窗消息提示
     * @param message
     */
    public void setMessage(String message){
        if(tvAddCredits != null){
            tvAddCredits.setText(message);
        }
    }

    @Override
    public void initDialogAttributes(WindowManager.LayoutParams params) {
        params.gravity = Gravity.CENTER;
        params.width = getDialogNormalWidth();
        setDialogParams(params);
    }

}
