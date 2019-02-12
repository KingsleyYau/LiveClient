package com.qpidnetwork.livemodule.framework.widget.magicfly;

import android.animation.TypeEvaluator;
import android.graphics.Bitmap;
import android.graphics.PointF;
import com.qpidnetwork.qnbridgemodule.util.Log;

/**
 * 点赞动画第一阶段，平移，缩放，晃动，alpha渐进
 * Created by Hunter Mun on 2017/6/29.
 */

public class FlyEnterEvaluator implements TypeEvaluator<ValueState> {

    private Bitmap mBitmap;

    public FlyEnterEvaluator(Bitmap bitmap){
        this.mBitmap = bitmap;
    }

    @Override
    public ValueState evaluate(float fraction, ValueState startValue, ValueState endValue) {
        float timeStart = 1.0f - fraction;

        ValueState valueState = new ValueState();
        PointF point = new PointF();

        //平移
        point.x = startValue.pointF.x + (endValue.pointF.x - startValue.pointF.x) * fraction;
        point.y = startValue.pointF.y + (endValue.pointF.y - startValue.pointF.y) * fraction;
        valueState.pointF = point;

        //缩放
//        valueState.scale = 0.2f + 0.8f * fraction;
        float scale = 0.2f + 1.2f * fraction; //出来到2/3时就到最大
        valueState.scale = scale >= 1.0f ? 1.0f:scale;

        //alpha值不变
        valueState.alpha = 255;

        //图片
        valueState.bitmap = mBitmap;

        return valueState;
    }
}
