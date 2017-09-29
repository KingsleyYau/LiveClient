package com.qpidnetwork.livemodule.liveshow.liveroom.car;

import android.content.Context;
import android.text.TextPaint;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.liveshow.LiveApplication;
import com.qpidnetwork.livemodule.utils.Log;
import com.squareup.picasso.Picasso;

import java.io.File;

/**
 * Description:
 * <p>
 * Created by Harry on 2017/9/4.
 */

public class CarView extends LinearLayout{

    private Context mContext;
    private final String TAG = CarView.class.getSimpleName();
    private TextView tv_carMaster;
    private TextView tv_joined;
    private ImageView iv_carImg;
    private String masterName;

    public CarView(Context context) {
        this(context,null);
    }

    public CarView(Context context, AttributeSet attrs) {
        this(context, attrs,0);
    }

    public CarView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context){
        mContext = context;
        initView(context);
    }

    private void initView(Context context){
        // 加载布局
        LayoutInflater.from(context).inflate(R.layout.view_liveroom_car, this);
        tv_carMaster = (TextView) findViewById(R.id.tv_carMaster);
        tv_joined = (TextView) findViewById(R.id.tv_joined);
        tv_joined.setText(context.getResources().getString(R.string.liveroom_entrancecar_joined,""));
        iv_carImg = (ImageView) findViewById(R.id.iv_carImg);
    }

    public void setCarMasterName(String masterName){
        Log.d(TAG,"setCarMasterName-masterName:"+masterName);
        this.masterName = masterName;
        TextPaint textPaint = tv_carMaster.getPaint();
        int maxWidth = (int)textPaint.measureText("@^&(_H-Z| ");
        Log.d(TAG,"setCarMasterName-maxWidth:"+maxWidth);
        tv_carMaster.setMaxWidth(maxWidth);
        tv_carMaster.setText(masterName);
    }

    public void setCarImgUrl(String carImgUrl){
        Log.d(TAG,"setCarImgUrl-carImgUrl:"+carImgUrl);
        if(!TextUtils.isEmpty(carImgUrl)){
            Picasso.with(LiveApplication.getContext())
                    .load(new File(carImgUrl)).noFade()
                    .into(iv_carImg);
        }
    }
}
