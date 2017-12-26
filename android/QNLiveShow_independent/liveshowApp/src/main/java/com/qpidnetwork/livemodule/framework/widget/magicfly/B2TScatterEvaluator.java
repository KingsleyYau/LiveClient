/**
 * MIT License
 *
 * Copyright (c) 2016 yanbo
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package com.qpidnetwork.livemodule.framework.widget.magicfly;

import android.graphics.Bitmap;
import android.graphics.PointF;
import android.util.Log;

import java.util.Random;

/**
 * Animator from View's bottom to top, and scattered all the time.
 */

public class B2TScatterEvaluator extends AbsAnimatorEvaluator {
    private PointF pointF1, pointF2;

    public B2TScatterEvaluator(int width, int heigh, Bitmap bitmap) {
        super(width, heigh, bitmap);
        int realH = getMeasuredHeigh() - getBitmap().getHeight();
        pointF1 = getBezierP01PointF(realH / 2, realH);
        pointF2 = getBezierP01PointF(0, realH / 2);
    }

    protected PointF getBezierP01PointF(int min, int max) {

        PointF pointF = new PointF();
        pointF.x = new Random().nextInt(getMeasuredWith() - getBitmap().getWidth());
        Log.i("hunter", "width: " + getMeasuredWith() + " bitmap width: " + getBitmap().getWidth() + " pointF.x: " + pointF.x);
        pointF.y = randomRange(min, max);
        return pointF;
    }

    protected int randomRange(int min, int max) {
        Random random = new Random();
        return random.nextInt(max) % (max - min + 1) + min;
    }

    @Override
    public ValueState evaluate(float fraction, ValueState startValue, ValueState endValue) {
        float timeStart = 1.0f - fraction;

        ValueState valueState = new ValueState();
        PointF point = new PointF();

        //原版
        point.x = timeStart * timeStart * timeStart * (startValue.pointF.x) + 3
                * timeStart * timeStart * fraction * (pointF1.x) + 3 * timeStart
                * fraction * fraction * (pointF2.x) + fraction * fraction * fraction * (endValue.pointF.x);

        point.y = timeStart * timeStart * timeStart * (startValue.pointF.y) + 3
                * timeStart * timeStart * fraction * (pointF1.y) + 3 * timeStart
                * fraction * fraction * (pointF2.y) + fraction * fraction * fraction * (endValue.pointF.y);

        //改版
//        point.x = timeStart * timeStart * timeStart * timeStart * timeStart * (startValue.pointF.x)//越大，范围更随机
//                + 3 * timeStart * timeStart * fraction * (pointF1.x)
//                + fraction * (endValue.pointF.x);   //越大，越向右
//
//        point.y = timeStart * timeStart * timeStart * (startValue.pointF.y) * timeStart
//                + 3 * timeStart * fraction * (pointF1.y)     //会在一半停留一下再飞
//                + fraction * fraction * fraction * (endValue.pointF.y);
        valueState.pointF = point;
//        valueState.scale = Math.abs((float)(1.0f - Math.pow((1.0f - fraction), 2 * 10)));    //2 * ?决定图缩放速率 ?越小，缩放距离越大。
        valueState.scale = 1.0f;
//        valueState.alpha = (int) (timeStart * 255);
        if(fraction >= 0.5){
            //飞行过半再开始渐进消失
            valueState.alpha = (int)(2 * (1 - fraction)* 255);
        }else{
            valueState.alpha = 255;
        }
        valueState.bitmap = getBitmap();
        return valueState;
    }

    @Override
    public ValueState createAnimatorStart() {
        ValueState valueState = new ValueState();
        valueState.bitmap = getBitmap();
        valueState.alpha = 255;
        valueState.scale = 0.1f;
        valueState.pointF = new PointF((getMeasuredWith()) / 2, getMeasuredHeigh() - getBitmap().getHeight() / 2);
        return valueState;
    }

    @Override
    public ValueState createAnimatorEnd() {
        ValueState valueState = new ValueState();
        valueState.bitmap = getBitmap();
        valueState.alpha = 0;
        valueState.scale = 1f;
        valueState.pointF = new PointF(new Random().nextInt(getMeasuredWith()), 0);
        return valueState;
    }
}
