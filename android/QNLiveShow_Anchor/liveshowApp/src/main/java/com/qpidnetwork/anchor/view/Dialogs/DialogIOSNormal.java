package com.qpidnetwork.anchor.view.Dialogs;

import android.app.Activity;
import android.support.annotation.NonNull;
import android.view.Gravity;
import android.view.View;

import com.dou361.dialogui.DialogUIUtils;
import com.dou361.dialogui.listener.DialogUIListener;
import com.qpidnetwork.anchor.R;

/**
 * 普通对话框
 * Created by Jagger on 2018/3/13.
 */

public class DialogIOSNormal {

    /**
     * 构建器
     */
    public static class Builder{
        private Activity activity;
        private String title = "",content = "";
        private int textGravity = Gravity.LEFT;
        private boolean cancelable = true;
        private boolean outsideTouchable = true;
        private Button btnLeft ;
        private Button btnRight ;
        private onDismissListener onDismissListener;

        public Activity getActivity() {
            return activity;
        }

        public Builder setActivity(Activity activity) {
            this.activity = activity;
            return this;
        }

        public String getTitle() {
            return title;
        }

        public Builder setTitle(String title) {
            this.title = title;
            return this;
        }

        public String getContent() {
            return content;
        }

        public Builder setContent(String content) {
            this.content = content;
            return this;
        }

        public int getTextGravity() {
            return textGravity;
        }

        public Builder textGravity(int textGravity) {
            this.textGravity = textGravity;
            return this;
        }

        public boolean isCancelable() {
            return cancelable;
        }

        public Builder cancleable(boolean cancleable) {
            this.cancelable = cancleable;
            return this;
        }

        public boolean isOutsideTouchable() {
            return outsideTouchable;
        }

        public Builder outsideTouchable(boolean outsideTouchable) {
            this.outsideTouchable = outsideTouchable;
            return this;
        }

        public Button getBtnLeft() {
            return btnLeft;
        }

        public Builder btnLeft(Button btnLeft) {
            this.btnLeft = btnLeft;
            return this;
        }

        public Button getBtnRight() {
            return btnRight;
        }

        public Builder btnRight(Button btnRight) {
            this.btnRight = btnRight;
            return this;
        }

        public onDismissListener getOnDismissListener(){return this.onDismissListener;}

        public Builder setOnDismissListner(onDismissListener onDismissListener) {
            this.onDismissListener = onDismissListener;
            return this;
        }
    }

    /**
     * 按钮
     */
    public static class Button{
        private String text = "";
        private boolean isDark = false;
        private View.OnClickListener onClickListener;

        public Button(String text , boolean isDark , View.OnClickListener onClickListener){
            this.text = text;
            this.isDark = isDark;
            this.onClickListener = onClickListener;
        }

        public String getText() {
            return text;
        }

        public boolean isDark() {
            return isDark;
        }

        public View.OnClickListener getOnClickListener() {
            return onClickListener;
        }
    }


    /**
     * 对话框消失事件
     */
    public interface onDismissListener {
        void onDismiss();
    }

    //变量
    private Builder mBuilder;

    private DialogIOSNormal(Builder builder){
        mBuilder = builder;
    }

    @NonNull
    public static DialogIOSNormal setBuilder(Builder builder){
        return new DialogIOSNormal(builder);
    }

    public void show(){
        if(mBuilder == null || mBuilder.getActivity() == null){
            return;
        }

        //按钮文字颜色
        int btnLeftTextColor = R.color.black;
        int btnRightTextColor = R.color.black;
        if(mBuilder.getBtnLeft() != null && mBuilder.getBtnLeft().isDark()){
            btnLeftTextColor = R.color.black3;
        }

        if(mBuilder.getBtnRight() != null && mBuilder.getBtnRight().isDark()){
            btnRightTextColor = R.color.black3;
        }

        //view
        DialogUIUtils.showAlert(
                mBuilder.getActivity(),
                mBuilder.getTitle(),
                mBuilder.getContent(),
                "",
                "",
                mBuilder.getBtnLeft() == null ? "" : mBuilder.getBtnLeft().getText(),
                mBuilder.getBtnRight() == null ? "" : mBuilder.getBtnRight().getText(),
                btnLeftTextColor,
                btnRightTextColor,
                false,
                mBuilder.isCancelable(),
                mBuilder.isOutsideTouchable(),
                new DialogUIListener() {
                    @Override
                    public void onPositive() {
                        if(mBuilder.getBtnLeft() != null){
                            //click
                            if(mBuilder.getBtnLeft().getOnClickListener() != null){
                                mBuilder.getBtnLeft().getOnClickListener().onClick(null);
                            }

                            //
                            if(mBuilder.getOnDismissListener() != null){
                                mBuilder.getOnDismissListener().onDismiss();
                            }
                        }
                    }

                    @Override
                    public void onNegative() {
                        if(mBuilder.getBtnRight() != null){

                            //click
                            if(mBuilder.getBtnRight().getOnClickListener() != null){
                                mBuilder.getBtnRight().getOnClickListener().onClick(null);
                            }

                            //
                            if(mBuilder.getOnDismissListener() != null){
                                mBuilder.getOnDismissListener().onDismiss();
                            }
                        }
                    }
                }).show();
    }
}
