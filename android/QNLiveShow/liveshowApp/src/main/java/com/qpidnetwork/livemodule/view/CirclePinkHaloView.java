package com.qpidnetwork.livemodule.view;

import android.animation.ObjectAnimator;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.util.AttributeSet;
import android.view.View;

/**
 * Created by Hardy on 2019/3/7.
 * <p>
 * 在布局中的宽高，一定要给定具体的值，而且宽高一致。
 * 因为这里没做 onMeasure 方法的宽高测量
 * <p>
 * 作为某个展示 View 的底层 View，比展示 View 的宽高多出 10dp，用来显示出光晕
 */
public class CirclePinkHaloView extends View {

    //画阴影
    private Paint paint;
    private Shader mShader;

    private int whiteColorHalf;
    private int whiteColor;
    private int widthHalf;

    private ObjectAnimator oj;

    public CirclePinkHaloView(Context context) {
        this(context, null);
    }

    public CirclePinkHaloView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CirclePinkHaloView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        // 半透明
        whiteColorHalf = Color.parseColor("#80FF5756");
        whiteColor = Color.parseColor("#FF5756");

        paint = new Paint();
        paint.setAntiAlias(true);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        widthHalf = w / 2;

        // 圆形渐变的 Gradient
        mShader = new RadialGradient(widthHalf, widthHalf, widthHalf,
                new int[]{whiteColor, whiteColor, whiteColor,
                        whiteColor, whiteColor, whiteColor,
                        whiteColor, whiteColorHalf,  Color.TRANSPARENT},

                null, Shader.TileMode.CLAMP);


        //画阴影
        paint.setShader(mShader);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        //画圆
        canvas.drawCircle(widthHalf, widthHalf, widthHalf, paint);
    }

}
