package com.qpidnetwork.livemodule.view.dialog;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.DisplayUtil;
import com.qpidnetwork.qnbridgemodule.view.BaseDialog;


/**
 * 个人中心——头像上传选择弹窗
 */
public class UserIconUploadDialog extends BaseDialog implements View.OnClickListener {

    private View contentView;
    private ImageView ivPhoto;
    private TextView tvTitle;
    private TextView tvTitleTips;
    private TextView textViewTakePhoto;
    private TextView textViewSelectExisting;
    private TextView textViewCancel;
    private OnClickCallback callback;

    public UserIconUploadDialog(Context context, OnClickCallback callback) {
        super(context);
        contentView = LayoutInflater.from(context).inflate(R.layout.dialog_choose_photo_live, null);
//        contentView.findViewById(R.id.masterView).getLayoutParams().width = this.getDialogSize();

        int width = DisplayUtil.getScreenWidth(context) - context.getResources().getDimensionPixelSize(R.dimen.live_size_20dp) * 2;
        contentView.findViewById(R.id.masterView).getLayoutParams().width = width;

        this.setContentView(contentView);

        this.callback = callback;
        ivPhoto = (ImageView) findViewById(R.id.imageView);
        tvTitle = (TextView) findViewById(R.id.textView);
        tvTitleTips = (TextView) findViewById(R.id.textViewTips);

        textViewTakePhoto = (TextView) findViewById(R.id.textViewTakePhoto);
        textViewSelectExisting = (TextView) findViewById(R.id.textViewSelectExisting);
        textViewCancel = (TextView) findViewById(R.id.textViewCancel);

        textViewTakePhoto.setOnClickListener(this);
        textViewSelectExisting.setOnClickListener(this);
        textViewCancel.setOnClickListener(this);

    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
    }


    public void setFirstButtonText(CharSequence text) {
        getFirstButton().setText(text);
    }

    public void setSecondButtonText(CharSequence text) {
        getSecondButton().setText(text);
    }

    public TextView getFirstButton() {
        return textViewTakePhoto;
    }

    public TextView getSecondButton() {
        return textViewSelectExisting;
    }

    public TextView getCancelButton() {
        return textViewCancel;
    }


    public void hideImageView() {
        getImageView().setVisibility(View.GONE);
    }

    public ImageView getImageView() {
        return ivPhoto;
    }

    public void setTitle(CharSequence text) {
        getTitle().setText(text);
    }

    public void setMessage(CharSequence text) {
        getMessage().setText(text);
    }

    public TextView getTitle() {
        return tvTitle;
    }

    public TextView getMessage() {
        return tvTitleTips;
    }


    @Override
    public void onClick(View v) {
        dismiss();

        int id = v.getId();
        if (id == R.id.textViewTakePhoto) {
            if (callback != null) callback.OnFirstButtonClick(v);
        } else if (id == R.id.textViewSelectExisting) {
            if (callback != null) callback.OnSecondButtonClick(v);
        } else if (id == R.id.textViewCancel) {
            if (callback != null) callback.OnCancelButtonClick(v);
        }
    }

    public interface OnClickCallback {
        void OnFirstButtonClick(View v);

        void OnSecondButtonClick(View v);

        void OnCancelButtonClick(View v);
    }


}
