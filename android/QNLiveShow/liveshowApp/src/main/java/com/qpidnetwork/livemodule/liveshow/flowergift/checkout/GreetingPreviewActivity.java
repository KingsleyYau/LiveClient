package com.qpidnetwork.livemodule.liveshow.flowergift.checkout;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;

/**
 * @author Jagger 2019-10-12
 */
public class GreetingPreviewActivity extends BaseFragmentActivity {

    private static final String CONTENT = "KEY_CONTENT";
    private static final String NAME = "KEY_NAME";

    private ImageView iv_commBack ;
    private SimpleDraweeView img_card;
    private TextView tv_content, tv_name;

    private String content, name;

    public static void lanchAct(Context context, String content, String name) {
        Intent intent = new Intent(context, GreetingPreviewActivity.class);
        intent.putExtra(CONTENT, content);
        intent.putExtra(NAME, name);
        context.startActivity(intent);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_greeting_preview);

        iv_commBack = findViewById(R.id.iv_commBack);
        iv_commBack.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        img_card = findViewById(R.id.img_card);
        tv_content = findViewById(R.id.tv_content);
        tv_content.setMovementMethod(ScrollingMovementMethod.getInstance());
        tv_name = findViewById(R.id.tv_name);
    }

    @Override
    protected void onStart() {
        super.onStart();

        //传入的参数
        Bundle bundle = getIntent().getExtras();
        if(bundle != null){
            if(bundle.containsKey(CONTENT)){
                content = bundle.getString(CONTENT);
            }

            if(bundle.containsKey(NAME)){
                name = bundle.getString(NAME);
            }
        }

        FrescoLoadUtil.loadRes(img_card, R.drawable.bg_greetingcard);
        tv_content.setText(content);
        tv_name.setText("From " + name);
    }
}
