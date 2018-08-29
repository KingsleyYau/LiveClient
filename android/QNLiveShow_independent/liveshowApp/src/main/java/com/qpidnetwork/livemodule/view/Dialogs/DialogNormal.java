package com.qpidnetwork.livemodule.view.Dialogs;

import android.app.Dialog;
import android.content.Context;
import android.support.annotation.NonNull;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import com.dou361.dialogui.DialogUIUtils;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.view.ButtonRaised;

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
        private String title = "",content = "";
        private int textGravity = Gravity.LEFT;
        private boolean cancleable = true;
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

        public boolean isCancleable() {
            return cancleable;
        }

        public Builder cancleable(boolean cancleable) {
            this.cancleable = cancleable;
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
     * 点击事件(内部用)
     */
    private static class OnClick implements View.OnClickListener{

        private View.OnClickListener click;
        private Dialog dialog;

        public OnClick(final Dialog dialog , View.OnClickListener click){
            this.click = click;
            this.dialog = dialog;
        }

        @Override
        public void onClick(View v) {
            if(click != null)click.onClick(v);
            DialogUIUtils.dismiss(this.dialog);
        }
    }

    //变量
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
        final Dialog dialog = DialogUIUtils.showCustomAlert(
                mBuilder.getContext(),
                rootView,
                "",
                "",
                Gravity.CENTER,
                mBuilder.isCancleable(),
                mBuilder.isOutsideTouchable() ,
                null).show();

        //title
        TextView textViewTitle = (TextView)rootView.findViewById(R.id.dialogui_tv_title);
        if(TextUtils.isEmpty( mBuilder.getTitle())){
            textViewTitle.setVisibility(View.GONE);
        }else {
            textViewTitle.setText(mBuilder.getTitle());
        }

        //content
        TextView textViewContent = (TextView)rootView.findViewById(R.id.dialogui_tv_content);
        if(TextUtils.isEmpty( mBuilder.getContent())){
            textViewContent.setVisibility(View.GONE);
        }else {
            textViewContent.setText(mBuilder.getContent());
        }

        if(mBuilder.getTextGravity() == Gravity.LEFT){
            textViewContent.setGravity(Gravity.LEFT);
        }else if(mBuilder.getTextGravity() == Gravity.CENTER){
            textViewContent.setGravity(Gravity.CENTER);
        }else if(mBuilder.getTextGravity() == Gravity.RIGHT){
            textViewContent.setGravity(Gravity.RIGHT);
        }


        //left
        ButtonRaised btnLeft = (ButtonRaised)rootView.findViewById(R.id.btn_left);
        if(mBuilder.getBtnLeft() != null){
            //text
            btnLeft.setButtonTitle(mBuilder.getBtnLeft().getText());

            //color
            if(mBuilder.getBtnLeft().isDark()){
                btnLeft.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.black3));
            }else{
                btnLeft.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.cover_state_use));
            }

            //click
            if(mBuilder.getBtnLeft().getOnClickListener() != null){
                btnLeft.setOnClickListener(new OnClick(dialog , mBuilder.getBtnLeft().getOnClickListener()));
            }else{
                btnLeft.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        DialogUIUtils.dismiss(dialog);
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
                btnRight.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.black3));
            }else {
                btnRight.setButtonBackground(mBuilder.getContext().getResources().getColor(R.color.cover_state_use));
            }

            //click
            if(mBuilder.getBtnRight().getOnClickListener() != null){
                btnRight.setOnClickListener(new OnClick(dialog , mBuilder.getBtnRight().getOnClickListener()));
            }else{
                btnRight.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        DialogUIUtils.dismiss(dialog);
                    }
                });
            }
        }else{
            btnRight.setVisibility(View.GONE);
        }
    }
}
