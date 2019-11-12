package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.Point;
import android.os.Build;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumPictureCache;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumPictureCache.ImageCallback;
import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;

import java.util.ArrayList;
import java.util.List;

/**
 * 本地相册 Adapter
 */
public class AlbumGridAdapter extends BaseAdapter {

    final String TAG = getClass().getSimpleName();

    Activity mActivity;
    AlbumPictureCache cache;
    private List<ImageBean> mAlbumList;

    private RelativeLayout.LayoutParams mItemParam;

    ImageCallback callback = new ImageCallback() {
        @Override
        public void imageLoad(ImageView imageView, Bitmap bitmap,
                              Object... params) {
            if (imageView != null && bitmap != null) {
                String url = (String) params[0];
                if (url != null && url.equals((String) imageView.getTag())) {
                    ((ImageView) imageView).setImageBitmap(bitmap);
                } else {
                    Log.e(TAG, "callback, bmp not match");
                }
            } else {
                Log.e(TAG, "callback, bmp null");
            }
        }

        @Override
        public Bitmap onBitmapHandlerIntercept(String filePath, Bitmap tempBitmap) {
            return LiveChatAlbumGridAdapter.adjustImageDegree(filePath, tempBitmap);
        }
    };

    public AlbumGridAdapter(Activity act, List<ImageBean> list) {
        this.mActivity = act;
        cache = new AlbumPictureCache();

        mAlbumList = new ArrayList<>();
        if (ListUtils.isList(list)) {
            mAlbumList.addAll(list);
        }

        int itemSize = getInitItemSize(act, 3);
        mItemParam = getInitItemLayoutParam(itemSize);
    }

    public void setData(List<ImageBean> list){
        mAlbumList.clear();
        if (ListUtils.isList(list)) {
            mAlbumList.addAll(list);
        }
        this.notifyDataSetChanged();
    }

    public static int getInitItemSize(Activity mActivity, int gridCount) {
        float density = mActivity.getResources().getDisplayMetrics().density;
        Display display = mActivity.getWindowManager().getDefaultDisplay();
        Point size = new Point();

        if (Build.VERSION.SDK_INT > 12) {
            display.getSize(size);
        } else {
            size.x = display.getWidth();
            size.y = display.getHeight();
        }

        int itemSize = (int) (((float) size.x - (int) (1.0f * density)) / gridCount);

        return itemSize;
    }

    public static RelativeLayout.LayoutParams getInitItemLayoutParam(int itemSize){
        return new RelativeLayout.LayoutParams(itemSize, itemSize);
    }

    @Override
    public int getCount() {
        int count = 0;
        if (mAlbumList != null) {
            count = mAlbumList.size();
        }
        return count;
    }

    @Override
    public ImageBean getItem(int position) {
        return mAlbumList.get(position);
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @SuppressWarnings("deprecation")
    @SuppressLint({"NewApi", "InflateParams"})
    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Holder holder;
        if (convertView == null) {
            holder = new Holder();

            convertView = LayoutInflater.from(mActivity).inflate(R.layout.adapter_album_item_live, null);
            holder.ivAlbum = (ImageView) convertView.findViewById(R.id.ivAlbum);
            holder.touch_feedback_region = (View) convertView.findViewById(R.id.touch_region);
            holder.ivAlbum.setLayoutParams(mItemParam);
            holder.touch_feedback_region.setLayoutParams(mItemParam);

            convertView.setTag(holder);
        } else {
            holder = (Holder) convertView.getTag();
        }
        final ImageBean item = mAlbumList.get(position);


        holder.ivAlbum.setTag(item.imagePath);
        cache.displayBmp(holder.ivAlbum, item.thumbnailPath, item.imagePath, callback);
        return convertView;
    }

    class Holder {
        private ImageView ivAlbum;
        private View touch_feedback_region;
    }
}
