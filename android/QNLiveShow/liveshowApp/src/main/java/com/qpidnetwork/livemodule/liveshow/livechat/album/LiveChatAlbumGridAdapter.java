package com.qpidnetwork.livemodule.liveshow.livechat.album;

import android.app.Activity;
import android.graphics.Bitmap;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.utils.ImageUtil;
import com.qpidnetwork.qnbridgemodule.util.ListUtils;
import com.qpidnetwork.qnbridgemodule.util.Log;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumPictureCache;
import com.qpidnetwork.qnbridgemodule.view.camera.AlbumPictureCache.ImageCallback;
import com.qpidnetwork.qnbridgemodule.view.camera.ImageBean;

import java.util.ArrayList;
import java.util.List;

import static com.qpidnetwork.livemodule.liveshow.livechat.album.AlbumGridAdapter.getInitItemLayoutParam;


/**
 * LiveChat 聊天界面
 * 本地相册 Adapter
 */
public class LiveChatAlbumGridAdapter extends BaseAdapter {

    final String TAG = getClass().getSimpleName();

    Activity mActivity;
    AlbumPictureCache cache;
    private List<ImageBean> mAlbumList;

    private RelativeLayout.LayoutParams mItemParam;
    private LiveChatAlbumItemView.OnImageOperaListener onImageOperaListener;

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
            return adjustImageDegree(filePath, tempBitmap);
        }
    };

    public static Bitmap adjustImageDegree(String filePath, Bitmap tempBitmap){
        try {
            int degree = ImageUtil.readImageDegree(filePath);
            if (degree != 0) {
                /**
                 * 把图片旋转为正的方向
                 */
                tempBitmap = ImageUtil.rotaingImageView(degree, tempBitmap);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
        }

        return tempBitmap;
    }

    public LiveChatAlbumGridAdapter(Activity act, List<ImageBean> list) {
        this.mActivity = act;
        cache = new AlbumPictureCache();

        mAlbumList = new ArrayList<>();
        if (ListUtils.isList(list)) {
            mAlbumList.addAll(list);
        }

        int itemSize = AlbumGridAdapter.getInitItemSize(act, 2);
        mItemParam = getInitItemLayoutParam(itemSize);
    }

    public void setData(List<ImageBean> list){
        mAlbumList.clear();
        if (ListUtils.isList(list)) {
            mAlbumList.addAll(list);
        }
        this.notifyDataSetChanged();
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

    @Override
    public View getView(int position, View convertView, ViewGroup parent) {
        Holder holder;
        if (convertView == null) {
            holder = new Holder();

            convertView = LayoutInflater.from(mActivity).inflate(R.layout.adapter_album_item_live_chat_live, null);

            holder.mRootView = (LiveChatAlbumItemView) convertView;

//            holder.ivAlbum = (ImageView) convertView.findViewById(R.id.ivAlbum);
            holder.touch_feedback_region = (View) convertView.findViewById(R.id.touch_region);
            holder.touch_feedback_region.setLayoutParams(mItemParam);

//            holder.ivAlbum.setLayoutParams(mItemParam);
            holder.mRootView.setImageLayoutParam(mItemParam);
            holder.mRootView.setOnImageOperaListener(onImageOperaListener);

            convertView.setTag(holder);
        } else {
            holder = (Holder) convertView.getTag();
        }

        final ImageBean item = mAlbumList.get(position);
        // old
//        holder.ivAlbum.setTag(item.imagePath);
//        cache.displayBmp(holder.ivAlbum, item.thumbnailPath, item.imagePath, callback);

        // new
        holder.mRootView.setPosition(position);
        holder.mRootView.setImagePathTag(item.imagePath);
        holder.mRootView.showImageOperaButton(item.isSelect);

        cache.displayBmp(holder.mRootView.getIvImage(), item.thumbnailPath, item.imagePath, callback);

//        Log.i("info", "-----> position: " + position);

        return convertView;
    }

    public void setOnImageOperaListener(LiveChatAlbumItemView.OnImageOperaListener onImageOperaListener) {
        this.onImageOperaListener = onImageOperaListener;
    }

    /**
     * ViewHolder
     */
    static class Holder {
        //        private ImageView ivAlbum;
        private View touch_feedback_region;
        //
        private LiveChatAlbumItemView mRootView;
    }
}
