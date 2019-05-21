package com.qpidnetwork.livemodule.liveshow.authorization;

import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.TextUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.framework.base.BaseNavFragment;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.PicassoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.AndroidBug5497Workaround;

/**
 * @author Jagger 2019-2-3
 * navigation/nav_login
 */
public class LoginNewActivity extends BaseFragmentActivity implements
        BaseNavFragment.OnFragmentInteractionListener{

    private static final String PARAMS_KEY_URL = "url";
    private static final String PARAMS_KEY_DIALOG_MSG = "PARAMS_KEY_DIALOG_MSG";

    private ImageView imgBg;

    private String mUrl = "";
    private String mDialogMsg = "";

    /**
     * 外部启动入口
     * @param context
     */
    public static void launchRegisterActivity(Context context){
        launchRegisterActivity(context , "");
    }

    /**
     * 外部启动入口
     * @param context
     * @param url
     */
    public static void launchRegisterActivity(Context context, String url){
        Intent intent = new Intent(context, LoginNewActivity.class);
        if(!TextUtils.isEmpty(url)){
            intent.putExtra(PARAMS_KEY_URL, url);
        }
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    /**
     * 外部启动入口
     * @param context
     * @param dialogMsg
     */
    public static void launchRegisterActivityWithDialog(Context context, String dialogMsg){
        Intent intent = new Intent(context, LoginNewActivity.class);
        if(!TextUtils.isEmpty(dialogMsg)){
            intent.putExtra(PARAMS_KEY_DIALOG_MSG, dialogMsg);
        }
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login_new);
        AndroidBug5497Workaround.assistActivity(this, true);
        setImmersionBarArtts(R.color.transparent_full);

        Intent theIntent = getIntent();
        //add by Jagger 2018-3-9
        //判空
        if(theIntent != null){
            if(theIntent.hasExtra(PARAMS_KEY_URL)){
                mUrl = theIntent.getStringExtra(PARAMS_KEY_URL);
            }

            if(theIntent.hasExtra(PARAMS_KEY_DIALOG_MSG)){
                mDialogMsg = theIntent.getStringExtra(PARAMS_KEY_DIALOG_MSG);
            }
        }

        imgBg = findViewById(R.id.img_bg);
        // 设置全屏高度
        int height = DisplayUtil.getScreenHeight(this);
        LinearLayout.LayoutParams layoutParamsBg = (LinearLayout.LayoutParams) imgBg.getLayoutParams();
        layoutParamsBg.height = height;

        PicassoLoadUtil.loadRes(imgBg, R.drawable.bg_website_cd);
        ImageUtil.showImageColorFilter(true, imgBg);
    }

    @Override
    public void onFragmentInteraction(Uri uri) {

    }

    @Override
    public void onFinishAct() {
        finish();
    }

    @Override
    public Bundle onRequestBundle(String flag) {
        Bundle bundle = new Bundle();
        if(flag.equals(FragmentLogin.FLAG_REQUEST_BUNDLE)){
            bundle.putString(FragmentLogin.PARAMS_KEY_DIALOG_MSG, mDialogMsg);
        }
        return bundle;
    }
}
