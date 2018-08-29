package com.qpidnetwork.livemodule.liveshow.liveroom.car;

import android.content.Context;
import android.text.TextPaint;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.livemodule.utils.Log;
import com.qpidnetwork.livemodule.utils.SystemUtils;

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
        mContext = context;
    }

    public void init(int txtColor, int bgResId){
        // 加载布局
        LayoutInflater.from(mContext).inflate(R.layout.view_liveroom_car, this);
        View ll_carView = findViewById(R.id.ll_carView);
        if(0 != bgResId){
            ll_carView.setBackgroundDrawable(mContext.getResources().getDrawable(bgResId));
        }

        tv_carMaster = (TextView) findViewById(R.id.tv_carMaster);
        tv_joined = (TextView) findViewById(R.id.tv_joined);
        if(0 != bgResId){
            tv_joined.setTextColor(txtColor);
        }
        tv_joined.setText(mContext.getResources().getString(R.string.liveroom_entrancecar_joined,""));
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

    /**
     *
     * @param carImgLocalPath
     */
    public void setCarImgLocalPath(String carImgLocalPath){
        Log.d(TAG,"setCarImgLocalPath-carImgLocalPath:"+carImgLocalPath);
        if(SystemUtils.fileExists(carImgLocalPath)){
            iv_carImg.setImageBitmap(ImageUtil.decodeSampledBitmapFromFile(
                    carImgLocalPath,DisplayUtil.dip2px(mContext,57f),
                    DisplayUtil.dip2px(mContext,57f)));
            //使用Picasso会出现https://github.com/square/picasso/issues/1504，
            // 为避免该bug导致的体验不佳，尝试手动加载为bigmap放到imageview来显示
//            Picasso.with(mContext.getApplicationContext())
//                    .load(new File(carImgLocalPath))
//                    .noFade()//img直接加载在imageview上，去掉默认的淡入效果
//                    .into(iv_carImg);
        }
    }
}
