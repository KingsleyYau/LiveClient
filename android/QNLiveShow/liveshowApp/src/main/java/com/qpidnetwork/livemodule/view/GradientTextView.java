package com.qpidnetwork.livemodule.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.LinearGradient;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.Shader;
import android.support.annotation.Nullable;
import android.support.v4.content.ContextCompat;
import android.support.v7.widget.AppCompatTextView;
import android.util.AttributeSet;

import com.qpidnetwork.livemodule.R;


/**
 * Created by Hardy on 2019/3/11.
 * <p>
 * 文字渐变+圆角背景框渐变
 * <p>
 * android:layout_width="wrap_content"
 * android:layout_height="wrap_content"
 * android:layout_margin="10dp"
 * android:gravity="center"
 * android:paddingLeft="8dp"
 * android:paddingTop="4dp"
 * android:paddingRight="8dp"
 * android:paddingBottom="4dp"
 * android:text="Check All"
 * android:textSize="12sp"
 */
public class GradientTextView extends AppCompatTextView {

    private static final int RECT_CORNER = 100;

    private LinearGradient mLinearGradientFond;
    private LinearGradient mLinearGradientBg;

    private Paint mBgPaint;

    private int width;
    private int height;
    private RectF mRectBg;

    private float strokeWidth = 3;
    private int colorStart;
    private int colorEnd;

    public GradientTextView(Context context) {
        this(context, null);
    }

    public GradientTextView(Context context, @Nullable AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public GradientTextView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context);
    }

    private void init(Context context) {
        colorStart = ContextCompat.getColor(context, R.color.live_ho_orange_deep);
        colorEnd = ContextCompat.getColor(context, R.color.live_ho_orange_light);

        // 圆角背景画笔
        mBgPaint = new Paint();
        mBgPaint.setAntiAlias(true);
        mBgPaint.setStyle(Paint.Style.STROKE);  //绘制空心
        mBgPaint.setStrokeWidth(strokeWidth);
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldw, int oldh) {
        super.onSizeChanged(w, h, oldw, oldh);

        // 宽高
        width = w;
        height = h;

        // 圆框
        float textPaintWidth = getPaint().measureText(getText().toString());
        mLinearGradientFond = new LinearGradient(0, 0, textPaintWidth, 0,
                colorStart,
                colorEnd,
                Shader.TileMode.CLAMP);

        // 背景
        mLinearGradientBg = new LinearGradient(0, 0, width, 0,
                colorStart,
                colorEnd,
                Shader.TileMode.CLAMP);
        mBgPaint.setShader(mLinearGradientBg);

        // 解决四个圆角的线比较粗的问题
        // https://blog.csdn.net/kuaiguixs/article/details/78753149
        mRectBg = new RectF(strokeWidth / 2, strokeWidth / 2, width - strokeWidth / 2, height - strokeWidth / 2);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        // 提前设置画笔，画文本
        getPaint().setShader(mLinearGradientFond);

        super.onDraw(canvas);

        if (isInEditMode()) {
            return;
        }

        // 最后画圆角边框
        canvas.drawRoundRect(mRectBg, RECT_CORNER, RECT_CORNER, mBgPaint);
    }
}
