package com.qpidnetwork.anchor.liveshow.pushmanager;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.framework.services.LiveService;
import com.qpidnetwork.anchor.liveshow.authorization.LoginManager;
import com.qpidnetwork.qnbridgemodule.bean.CommonConstant;


public class ServiceConflictDialogActivity extends Activity {

    private static final String  DIALOG_NOTIFY_DESCRIPTION = "dialogDesc";
    private static final String  DIALOG_NOTIFY_URL = "conflictUrl";

    private ServiceConflictDialogActivity mActivity;
    private String mUrl = "";


    public static void launchServiceConflictDialog(Context context, String descrition, String url){
        Intent intent = new Intent(context, ServiceConflictDialogActivity.class);
        intent.putExtra(DIALOG_NOTIFY_DESCRIPTION, descrition);
        intent.putExtra(DIALOG_NOTIFY_URL, url);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_service_conflict_dialog);

        mActivity = this;

        String description = "";
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(DIALOG_NOTIFY_DESCRIPTION)) {
                description = bundle.getString(DIALOG_NOTIFY_DESCRIPTION);
            }
            if(bundle.containsKey(DIALOG_NOTIFY_URL)) {
                mUrl = bundle.getString(DIALOG_NOTIFY_URL);
            }
        }
        ((TextView)findViewById(R.id.tvDesc)).setText(description);

        Button btnOk = (Button)findViewById(R.id.btnSure);
        btnOk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(LoginManager.getInstance().isLogined()){
                    //服务冲突，需特殊处理，发送广播通知相关界面处理
//                    LiveService.getInstance().openUrl(mActivity, mUrl);
                    Intent intent = new Intent(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_ACTION);
                    intent.putExtra(CommonConstant.ACTION_NOTIFICATION_SERVICE_CONFLICT_JUMPURL, mUrl);
                    sendBroadcast(intent);
                }else{
                    //停止服务，跳转
                    LiveService.getInstance().stopService();

                    LiveService.getInstance().openAppWithUrl(mActivity, mUrl);
                }
                finish();
            }
        });

        Button btnCancel = (Button)findViewById(R.id.btnCancel);
        btnCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });

    }
}
