package com.qpidnetwork.qnbridgemodule.util;

import android.app.Activity;
import android.content.DialogInterface;
import android.net.http.SslError;
import android.support.v7.app.AlertDialog;
import android.view.KeyEvent;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;

/**
 * 解决WebView onReceivedSslError 使用SslErrorHandler.proceed Google Play提示安全漏洞问题
 */
public class WebviewSSLProcessHelper {

    /**
     * ssl出错需要使用proceed跳过时，使用此替代
     * @param activity
     * @param view
     * @param handler
     * @param error
     */
    public static void showWebviewSSLErrorTips(Activity activity, WebView view, final SslErrorHandler handler, SslError error){
        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
        String message = "SSL certificate verification failed （error code：" + error.getPrimaryError() + ")";
        builder.setMessage(message);
        builder.setPositiveButton("Continue", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                handler.proceed();
            }
        });
        builder.setNegativeButton("Cancel", new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                handler.cancel();
            }
        });
        builder.setOnKeyListener(new DialogInterface.OnKeyListener() {
            @Override
            public boolean onKey(DialogInterface dialog, int keyCode, KeyEvent event) {
                if (event.getAction() == KeyEvent.ACTION_UP && keyCode == KeyEvent.KEYCODE_BACK) {
                    handler.cancel();
                    dialog.dismiss();
                    return true;
                }
                return false;
            }
        });
        AlertDialog dialog = builder.create();
        dialog.show();
    }

}
