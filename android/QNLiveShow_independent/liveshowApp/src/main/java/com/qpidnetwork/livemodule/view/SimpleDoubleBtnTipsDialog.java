package com.qpidnetwork.livemodule.view;

import android.app.Dialog;
import android.content.Context;
import android.support.annotation.NonNull;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;


/**
 * Description:
 * <p>
 * Created by Harry on 2017/5/24.
 */

public class SimpleDoubleBtnTipsDialog extends Dialog {

    public interface OnTipsDialogBtnClickListener{
        void onCancelBtnClick();
        void onConfirmBtnClick();
    }

    private TextView tv_cancel;
    private TextView tv_confirm;
    private ImageView iv_closeSimpleTips;
    private TextView tv_simpleTips;

    private OnTipsDialogBtnClickListener listener;
    public void setOnBtnClickListener(OnTipsDialogBtnClickListener listener){
        this.listener = listener;
    }

    public SimpleDoubleBtnTipsDialog(@NonNull Context context) {
        super(context, R.style.CustomTheme_SimpleDialog);
        View rootView = View.inflate(context,R.layout.dialog_simple_double_btn,null);
        iv_closeSimpleTips = (ImageView) rootView.findViewById(R.id.iv_closeSimpleTips);
        tv_cancel = (TextView) rootView.findViewById(R.id.tv_cancel);
        tv_confirm = (TextView) rootView.findViewById(R.id.tv_confirm);
        tv_simpleTips = (TextView) rootView.findViewById(R.id.tv_simpleTips);

        View.OnClickListener onClickListener = new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                int i = v.getId();
                if (i == R.id.tv_cancel || i == R.id.iv_closeSimpleTips) {
                    if(null != listener){
                        listener.onCancelBtnClick();
                    }
                } else if (i == R.id.tv_confirm) {
                    if(null != listener){
                        listener.onConfirmBtnClick();
                    }
                }
                dismiss();
            }
        };
        tv_cancel.setOnClickListener(onClickListener);
        tv_confirm.setOnClickListener(onClickListener);
        iv_closeSimpleTips.setOnClickListener(onClickListener);
        setContentView(rootView);
        setCanceledOnTouchOutside(false);
        setCancelable(false);
    }

    public void show(String tips, String confirm,String cancel) {
        tv_simpleTips.setText(tips);
        tv_cancel.setText(cancel);
        tv_confirm.setText(confirm);
        show();
    }

    @Override
    public void show() {
        super.show();

    }
}
