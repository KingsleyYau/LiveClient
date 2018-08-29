package com.qpidnetwork.livemodule.liveshow.pushmanager;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.services.LiveService;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;


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

        Button btnOk = (Button)findViewById(R.id.btnOk);
        btnOk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                //停止服务，跳转
                LiveService.getInstance().stopService();

                if(LoginManager.getInstance().isLogined()){
                    LiveService.getInstance().openUrl(mActivity, mUrl);
                }else{
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
