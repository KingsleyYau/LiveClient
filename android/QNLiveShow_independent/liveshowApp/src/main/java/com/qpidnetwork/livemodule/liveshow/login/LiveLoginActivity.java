package com.qpidnetwork.livemodule.liveshow.login;

import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.os.Bundle;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.view.Gravity;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.adapter.TieAdapter;
import com.dou361.dialogui.bean.BuildBean;
import com.dou361.dialogui.bean.TieBean;
import com.dou361.dialogui.listener.DialogUIItemListener;
import com.facebook.common.util.UriUtil;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.liveshow.WebViewActivity;
import com.qpidnetwork.livemodule.liveshow.authorization.LoginManager;

import java.util.ArrayList;
import java.util.List;

/**
 * 登录界面
 * Created by Jagger on 2017/12/19.
 */
public class LiveLoginActivity extends BaseFragmentActivity {

    //控件
    private FrameLayout mFlFaceBook , mFlMail;
    private TextView mTextViewLink;

    //变量
    private String mStrBgFileName = "login_bg.webp";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_live_login);

        initView();
    }

    private void initView(){
        //背景
        Uri uri = new Uri.Builder()
                .scheme(UriUtil.LOCAL_ASSET_SCHEME)
                .path(mStrBgFileName)
                .build();
        SimpleDraweeView simpleDraweeView = (SimpleDraweeView)findViewById(R.id.main_sdv5);
        DraweeController controller = Fresco.newDraweeControllerBuilder()
                .setUri(uri)
                .setAutoPlayAnimations(true)
                .build();
        simpleDraweeView.setController(controller);

        //按钮
        mFlFaceBook= (FrameLayout)findViewById(R.id.fl_login_facebook);
        mFlFaceBook.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedFaceBook();
            }
        });
        mFlMail= (FrameLayout)findViewById(R.id.fl_login_email);
        mFlMail.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedEmail();
            }
        });

        //底部连接
        mTextViewLink = (TextView)findViewById(R.id.txt_guide_link);
//        mTextView.getPaint().setFlags(Paint.UNDERLINE_TEXT_FLAG); //下划线
//        mTextView.getPaint().setAntiAlias(true);//抗锯齿
        mTextViewLink.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onClickedLink();
            }
        });
        //最后一页底部文字
        SpannableString spanText=new SpannableString(getString(R.string.live_login_tips2));
        spanText.setSpan(new ClickableSpan() {
            @Override
            public void updateDrawState(TextPaint ds) {
                super.updateDrawState(ds);
                ds.setColor(Color.WHITE);       //设置文件颜色
                ds.setUnderlineText(true);      //设置下划线
            }
            @Override
            public void onClick(View widget) {
                onClickedLink();
            }
        }, 0 , spanText.length(), Spannable.SPAN_EXCLUSIVE_EXCLUSIVE);
        mTextViewLink.setHighlightColor(Color.TRANSPARENT); //设置点击后的颜色为透明，否则会一直出现高亮
        mTextViewLink.append(" ");
        mTextViewLink.append(spanText);
        mTextViewLink.setMovementMethod(LinkMovementMethod.getInstance());//开始响应点击事件
    }

    /**
     * 点击FaceBook
     */
    private void onClickedFaceBook(){

    }

    /**
     * 点击E-mail
     */
    private void onClickedEmail(){
        showEmailLoginMenu();
    }

    /**
     * 底部菜单--EmailLogin
     */
    private void onClickedMenuEmailLogin(){
        Intent i = new Intent(mContext , LiveEmailLoginActivity.class);
        startActivity(i);
    }

    /**
     * 底部菜单--EmailSingup
     */
    private void onClickedMenuEmailSingup(){
        Intent i = new Intent(mContext , LiveEmailSignUpActivity.class);
        startActivity(i);
    }

    /**
     * 点击连接
     */
    private void onClickedLink(){
        if(LoginManager.getInstance().getSynConfig() != null){
            startActivity(WebViewActivity.getIntent(mContext,
                    getResources().getString(R.string.live_webview_user_terms_title),
                    WebViewActivity.UrlIntent.View_Terms_Of_Use,
                    null,
                    true));
        }
    }

    /**
     * Email菜单列表
     */
    private void showEmailLoginMenu(){
        //列表选项
        TieBean tieLogin = new TieBean(getString(R.string.live_login_with_email));
        tieLogin.setGravity(Gravity.CENTER);

        TieBean tieSignup = new TieBean(getString(R.string.live_sign_up_with_email));
        tieSignup.setGravity(Gravity.CENTER);

        TieBean tieCancel = new TieBean(getString(R.string.common_btn_cancel));
        tieCancel.setColor(getResources().getColor(R.color.black3));
        tieCancel.setGravity(Gravity.CENTER);

        List<TieBean> listMenu = new ArrayList<>();
        listMenu.add(tieLogin);
        listMenu.add(tieSignup);
        listMenu.add(tieCancel);

        //对话框
        TieAdapter adapter = new TieAdapter(mContext, listMenu, true);
        BuildBean buildBean = DialogUIUtils.showMdBottomSheet(this, true, "", listMenu, 0, new DialogUIItemListener() {
            @Override
            public void onItemClick(CharSequence text, int position) {
                if(position == 0){
                    onClickedMenuEmailLogin();
                }else if(position == 1){
                    onClickedMenuEmailSingup();
                }
            }
        });
        buildBean.mAdapter = adapter;
        buildBean.show();

    }

}
