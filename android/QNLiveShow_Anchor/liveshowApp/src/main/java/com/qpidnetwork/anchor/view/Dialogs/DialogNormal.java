package com.qpidnetwork.anchor.view.Dialogs;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.support.annotation.DrawableRes;
import android.support.annotation.NonNull;
import android.text.Html;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.qpidnetwork.anchor.R;
import com.qpidnetwork.anchor.view.ButtonRaised;

/**
 * 普通对话框
 * Created by Jagger on 2018/1/12.
 */

public class DialogNormal {

    /**
     * 构建器
     */
    public static class Builder{
        private Context context;
        private int titleImgResId = -1;
        private String title = "", des = "", desHtml = "";
        private int textGravity = Gravity.LEFT;
        private boolean cancelable = true;
        private boolean outsideTouchable = true;
        private Button btnLeft ;
        private Button btnRight ;

        public Context getContext() {
            return context;
        }

        public Builder setContext(Context context) {
            this.context = context;
            return this;
        }

        public int getTitleImgResId() {
            return titleImgResId;
        }

        public Builder setTitleImgResId(@DrawableRes int titleImgResId) {
            this.titleImgResId = titleImgResId;
            return this;
        }

        public String getTitle() {
            return title;
        }

        public Builder setTitle(String title) {
            this.title = title;
            return this;
        }

        public String getDes() {
            return des;
        }

        public Builder setDes(String des) {
            this.des = des;
            return this;
        }

        public String getDesHtml() {
            return desHtml;
        }

        public Builder setDesHtml(String desHtml) {
            this.desHtml = desHtml;
            return this;
        }

        public int getTextGravity() {
            return textGravity;
        }

        public Builder setTextGravity(int textGravity) {
            this.textGravity = textGravity;
            return this;
        }

        public boolean isCancelable() {
            return cancelable;
        }

        public Builder setCancleable(boolean cancleable) {
            this.cancelable = cancleable;
            return this;
        }

        public boolean isOutsideTouchable() {
            return outsideTouchable;
        }

        public Builder setOutsideTouchable(boolean outsideTouchable) {
            this.outsideTouchable = outsideTouchable;
            return this;
        }

        public Button getBtnLeft() {
            return btnLeft;
        }

        public Builder setBtnLeft(Button btnLeft) {
            this.btnLeft = btnLeft;
            return this;
        }

        public Button getBtnRight() {
            return btnRight;
        }

        public Builder setBtnRight(Button btnRight) {
            this.btnRight = btnRight;
            return this;
        }
    }

    /**
     * 按钮
     */
    public static class Button{
        private String text = "";
        private boolean isDark = false; //按钮颜色, 是否变暗
        private View.OnClickListener onClickListener;
        private boolean isShowLoading = false;  //点击时,是否显示loading

        public Button(String text , boolean isDark , View.OnClickListener onClickListener){
            this.text = text;
            this.isDark = isDark;
            this.onClickListener = onClickListener;
        }

        public Button(String text , boolean isDark , boolean showLoading, View.OnClickListener onClickListener){
            this.text = text;
            this.isDark = isDark;
            this.onClickListener = onClickListener;
            this.isShowLoading = showLoading;
        }

        public String getText() {
            return text;
        }

        public boolean isDark() {
            return isDark;
        }

        public boolean isShowLoading(){
            return isShowLoading;
        }

        public View.OnClickListener getOnClickListener() {
            return onClickListener;
        }
    }

//    /**
//     * 点击事件(内部用)
//     */
//    private static class OnClick implements View.OnClickListener{
//
//        private View.OnClickListener click;
//        private Dialog dialog;
//        private boolean isDismiss = true;   //默认点击即可关闭对话框
//
//        public OnClick(final Dialog dialog , View.OnClickListener click){
//            this.click = click;
//            this.dialog = dialog;
//        }
//
//        public OnClick(final Dialog dialog , View.OnClickListener click , boolean dismiss ){
//            this.click = click;
//            this.dialog = dialog;
//            this.isDismiss = dismiss;
//        }
//
//        @Override
//        public void onClick(View v) {
//            if(click != null)click.onClick(v);
//
//            if(isDismiss){
//                DialogUIUtils.dismiss(this.dialog);
//            }
//        }
//    }

    //变量
    private Dialog mDialog;
    private Builder mBuilder;

    private DialogNormal(Builder builder){
        mBuilder = builder;
    }

    @NonNull
    public static DialogNormal setBuilder(Builder builder){
        return new DialogNormal(builder);
    }

    public void show(){
        if(mBuilder == null || mBuilder.getContext() == null){
            return;
        }

        //view
        View rootView = View.inflate(mBuilder.getContext(), R.layout.dialog_normal_base, null);
        mDialog = DialogUIUtils.showCustomAlert(
                mBuilder.getContext(),
                rootView,
                "",
                "",
                Gravity.CENTER,
                mBuilder.isCancelable(),
                mBuilder.isOutsideTouchable() ,
                null).show();

        //title img
        ImageView imageViewTitle = (ImageView)rootView.findViewById(R.id.dialogui_img_title);
        if(mBuilder.getTitleImgResId() == -1){
            imageViewTitle.setVisibility(View.GONE);
        }else {
            imageViewTitle.setVisibility(View.VISIBLE);
            imageViewTitle.setImageResource(mBuilder.getTitleImgResId());
        }

        //title
        TextView textViewTitle = (TextView)rootView.findViewById(R.id.dialogui_tv_title);
        if(TextUtils.isEmpty( mBuilder.getTitle())){
            textViewTitle.setVisibility(View.GONE);
        }else {
            textViewTitle.setText(mBuilder.getTitle());
        }

        //des
        TextView textViewContent = (TextView)rootView.findViewById(R.id.dialogui_tv_content);
        if(TextUtils.isEmpty( mBuilder.getDes())){
            if(TextUtils.isEmpty( mBuilder.getDesHtml())){
                textViewContent.setVisibility(View.GONE);
            }else {
                textViewContent.setText(Html.fromHtml(mBuilder.getDesHtml()));
            }
        }else {
            textViewContent.setText(mBuilder.getDes());
        }

        if(mBuilder.getTextGravity() == Gravity.LEFT){
            textViewContent.setGravity(Gravity.LEFT);
        }else if(mBuilder.getTextGravity() == Gravity.CENTER){
            textViewContent.setGravity(Gravity.CENTER);
        }else if(mBuilder.getTextGravity() == Gravity.RIGHT){
            textViewContent.setGravity(Gravity.RIGHT);
        }

        //loading
        final ProgressBar progressBarLoading = (ProgressBar)rootView.findViewById(R.id.progressBar_loading);
        progressBarLoading.setVisibility(View.GONE);

        //left
        ButtonRaised btnLeft = (ButtonRaised)rootView.findViewById(R.id.btn_left);
        if(mBuilder.getBtnLeft() != null){
            //text
            btnLeft.setButtonTitle(mBuilder.getBtnLeft().getText());

            //color
            if(mBuilder.getBtnLeft().isDark()){
                btnLeft.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.custom_dialog_btn_color_dark));
            }else{
                btnLeft.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.custom_dialog_btn_color_ok));
            }

            //click
            if(mBuilder.getBtnLeft().getOnClickListener() != null){
//                setBtnLeft.setOnClickListener(new OnClick(mDialog, mBuilder.getBtnLeft().getOnClickListener(), !mBuilder.getBtnLeft().isShowLoading()));

                btnLeft.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        //做外部指定的事
                        mBuilder.getBtnLeft().getOnClickListener().onClick(v);

                        //自己的逻辑
                        if(mBuilder.getBtnLeft().isShowLoading()){
//                            progressBarLoading.setVisibility(View.VISIBLE);
                        }else {
                            DialogUIUtils.dismiss(mDialog);
                        }
                    }
                });
            }else{
                btnLeft.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        DialogUIUtils.dismiss(mDialog);
                    }
                });
            }
        }else{
            btnLeft.setVisibility(View.GONE);
        }


        //right
        ButtonRaised btnRight = (ButtonRaised)rootView.findViewById(R.id.btn_right);
        if(mBuilder.getBtnRight() != null){
            //text
            btnRight.setButtonTitle(mBuilder.getBtnRight().getText());

            //color
            if(mBuilder.getBtnRight().isDark()){
                btnRight.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.custom_dialog_btn_color_dark));
            }else {
                btnRight.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.custom_dialog_btn_color_ok));
            }

            //click
            if(mBuilder.getBtnRight().getOnClickListener() != null){
//                setBtnRight.setOnClickListener(new OnClick(mDialog, mBuilder.getBtnRight().getOnClickListener() , !mBuilder.getBtnRight().isShowLoading()));

                btnRight.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        //做外部指定的事
                        mBuilder.getBtnRight().getOnClickListener().onClick(v);

                        //自己的逻辑
                        if(mBuilder.getBtnRight().isShowLoading()){
                            progressBarLoading.setVisibility(View.VISIBLE);
                        }else {
                            DialogUIUtils.dismiss(mDialog);
                        }
                    }
                });
            }else{
                btnRight.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        DialogUIUtils.dismiss(mDialog);
                    }
                });
            }
        }else{
            btnRight.setVisibility(View.GONE);
        }
    }

    public void dismiss(){
        if(mDialog != null){
            ((Activity) mBuilder.getContext()).runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    DialogUIUtils.dismiss(mDialog);
                }
            });
        }
    }
}
