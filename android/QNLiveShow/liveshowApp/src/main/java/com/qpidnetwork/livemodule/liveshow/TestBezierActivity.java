package com.qpidnetwork.livemodule.liveshow;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.framework.base.BaseFragmentActivity;
import com.qpidnetwork.livemodule.view.LiveRoomHeaderBezierView;

public class TestBezierActivity extends BaseFragmentActivity {

    private LiveRoomHeaderBezierView lrhbv_flag0;
    private LiveRoomHeaderBezierView lrhbv_flag1;
    private TextView tv_subControll1X;
    private TextView tv_controll1XValue;
    private TextView tv_addControll1X;
    private TextView tv_subControll1Y;
    private TextView tv_controll1YValue;
    private TextView tv_addControll1Y;
    private TextView tv_subControll2X;
    private TextView tv_controll2XValue;
    private TextView tv_addControll2X;
    private TextView tv_subControll2Y;
    private TextView tv_controll2YValue;
    private TextView tv_addControll2Y;
    private TextView tv_subLengthX;
    private TextView tv_lengthValue;
    private TextView tv_addLengthX;

    private int controllX1=0;
    private int controllY1=0;
    private int controllX2=0;
    private int controllY2=0;
    private int bezierXWidth = 0;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TAG = TestBezierActivity.class.getSimpleName();
        setContentView(R.layout.activity_bezier_test);
        initView();
        initViewData();
    }

    private void initViewData(){
        controllX1 = lrhbv_flag1.getControllX1();
        controllY1 = lrhbv_flag1.getControllY1();
        controllX2 = lrhbv_flag1.getControllX2();
        controllY2 = lrhbv_flag1.getControllY2();
        bezierXWidth = lrhbv_flag1.getBezierXWidth();
        tv_controll1XValue.setText(String.valueOf(controllX1));
        tv_controll1YValue.setText(String.valueOf(controllY1));
        tv_controll2XValue.setText(String.valueOf(controllX2));
        tv_controll2YValue.setText(String.valueOf(controllY2));
        tv_lengthValue.setText(String.valueOf(bezierXWidth));
    }

    private void initView() {
        lrhbv_flag0 = (LiveRoomHeaderBezierView) findViewById(R.id.lrhbv_flag0);
        lrhbv_flag1 = (LiveRoomHeaderBezierView) findViewById(R.id.lrhbv_flag1);
        tv_subControll1X = (TextView) findViewById(R.id.tv_subControll1X);
        tv_controll1XValue = (TextView) findViewById(R.id.tv_controll1XValue);
        tv_addControll1X = (TextView) findViewById(R.id.tv_addControll1X);
        tv_subControll1Y = (TextView) findViewById(R.id.tv_subControll1Y);
        tv_controll1YValue = (TextView) findViewById(R.id.tv_controll1YValue);
        tv_addControll1Y = (TextView) findViewById(R.id.tv_addControll1Y);
        tv_subControll2X = (TextView) findViewById(R.id.tv_subControll2X);
        tv_controll2XValue = (TextView) findViewById(R.id.tv_controll2XValue);
        tv_addControll2X = (TextView) findViewById(R.id.tv_addControll2X);
        tv_subControll2Y = (TextView) findViewById(R.id.tv_subControll2Y);
        tv_controll2YValue = (TextView) findViewById(R.id.tv_controll2YValue);
        tv_addControll2Y = (TextView) findViewById(R.id.tv_addControll2Y);
        tv_subLengthX = (TextView) findViewById(R.id.tv_subLengthX);
        tv_lengthValue = (TextView) findViewById(R.id.tv_lengthValue);
        tv_addLengthX = (TextView) findViewById(R.id.tv_addLengthX);

        tv_subControll1X.setOnClickListener(this);
        tv_addControll1X.setOnClickListener(this);
        tv_subControll1Y.setOnClickListener(this);
        tv_addControll1Y.setOnClickListener(this);
        tv_subControll2X.setOnClickListener(this);
        tv_addControll2X.setOnClickListener(this);
        tv_subControll2Y.setOnClickListener(this);
        tv_addControll2Y.setOnClickListener(this);
        tv_subLengthX.setOnClickListener(this);
        tv_addLengthX.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        super.onClick(v);
        int viewId = v.getId();
        if(viewId == R.id.tv_subControll1X){
            controllX1-=1;
        }else if(viewId == R.id.tv_addControll1X){
            controllX1+=1;
        }else if(viewId == R.id.tv_subControll1Y){
            controllY1-=1;
        }else if(viewId == R.id.tv_addControll1Y){
            controllY1+=1;
        }else if(viewId == R.id.tv_subControll2X){
            controllX2-=1;
        }else if(viewId == R.id.tv_addControll2X){
            controllX2+=1;
        }else if(viewId == R.id.tv_subControll2Y){
            controllY2-=1;
        }else if(viewId == R.id.tv_addControll2Y){
            controllY2+=1;
        }else if(viewId == R.id.tv_subLengthX){
            bezierXWidth-=1;
        }else if(viewId == R.id.tv_addLengthX){
            bezierXWidth+=1;
        }
        tv_controll1XValue.setText(String.valueOf(controllX1));
        tv_controll1YValue.setText(String.valueOf(controllY1));
        tv_controll2XValue.setText(String.valueOf(controllX2));
        tv_controll2YValue.setText(String.valueOf(controllY2));
        tv_lengthValue.setText(String.valueOf(bezierXWidth));
        reDrawBezierView();
    }

    private void reDrawBezierView(){
        lrhbv_flag1.reDrawBezier(bezierXWidth,controllX1,controllY1,controllX2,controllY2);
        lrhbv_flag0.reDrawBezier(bezierXWidth,controllX1,controllY1,controllX2,controllY2);
    }
}
