package com.qpidnetwork.livemodule.liveshow.flowergift.mycart;

import android.content.Context;
import android.support.v7.widget.RecyclerView;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.facebook.drawee.view.SimpleDraweeView;
import com.qpidnetwork.livemodule.R;
import com.qpidnetwork.livemodule.httprequest.item.LSFlowerGiftBaseInfoItem;
import com.qpidnetwork.livemodule.httprequest.item.LSRecipientAnchorGiftItem;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseRecyclerViewAdapter;
import com.qpidnetwork.livemodule.liveshow.adapter.BaseViewHolder;
import com.qpidnetwork.livemodule.utils.ApplicationSettingUtil;
import com.qpidnetwork.livemodule.utils.FrescoLoadUtil;
import com.qpidnetwork.qnbridgemodule.util.ToastUtil;

/**
 * 购物车某主播礼物列表Adapter
 * @author Jagger 2019-10-9
 */
public class MyCartItemAdapter extends BaseRecyclerViewAdapter<LSFlowerGiftBaseInfoItem, MyCartItemAdapter.ViewHolderMyCartItem> implements MyCartGiftsSynManager.OnGiftsSynListener {
    private final int MAX_SUM = 99;
    private Context mContext;
    private LSRecipientAnchorGiftItem mLSRecipientAnchorGiftItem;
    private OnCartEventListener mOnCartEventListener;
    private MyCartGiftsSynManager mMyCartGiftsSynManager;

    public MyCartItemAdapter(Context context, MyCartGiftsSynManager myCartGiftsSynManager) {
        super(context);
        mContext = context;
        mMyCartGiftsSynManager = myCartGiftsSynManager;
        mMyCartGiftsSynManager.addGiftsSynListener(this);
    }

    /**
     * 必须设置
     * @param anchor
     */
    public void setLSRecipientAnchorGiftItem(LSRecipientAnchorGiftItem anchor){
        mLSRecipientAnchorGiftItem = anchor;
    }

    public void setOnEventListener(OnCartEventListener listener){
        mOnCartEventListener = listener;
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.item_mycart_list_flower;
    }

    @Override
    public ViewHolderMyCartItem getViewHolder(View itemView, int viewType) {
        return new ViewHolderMyCartItem(itemView);
    }

    @Override
    public void initViewHolder(final ViewHolderMyCartItem holder) {
        //点击事件
        //Gift
        holder.img_gift.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mOnCartEventListener != null){
                    mOnCartEventListener.onGiftClicked(getItemBean(getPosition(holder)));
                }
            }
        });
        //-1
        holder.img_des.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                holder.setUIEnabled(false);
                String s = holder.edt_sum.getText().toString();
                if(mMyCartGiftsSynManager.getStatus() == MyCartGiftsSynManager.Status.Loading || TextUtils.isEmpty(s)) {
                    holder.setUIEnabled(true);
                    return;
                }

                int sum = Integer.valueOf(s);
                int desSum = sum - 1;
                if(desSum == 0){
                    if(mOnCartEventListener != null){
                        mOnCartEventListener.onDelGift(mLSRecipientAnchorGiftItem, getItemBean(getPosition(holder)));
                    }
                }else{
                    if(mOnCartEventListener != null){
                        mOnCartEventListener.onChangeGiftSum(mLSRecipientAnchorGiftItem, getItemBean(getPosition(holder)), sum, desSum);
                    }
                }
            }
        });

        //+1
        holder.img_inc.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                holder.setUIEnabled(false);
                String s = holder.edt_sum.getText().toString();
                if(mMyCartGiftsSynManager.getStatus() == MyCartGiftsSynManager.Status.Loading || TextUtils.isEmpty(s)) {
                    holder.setUIEnabled(true);
                    return;
                }

                int sum = Integer.valueOf(s);
                if(sum == MAX_SUM) {
                    ToastUtil.showToast(mContext, R.string.my_cart_num_out_range);
                    holder.setUIEnabled(true);
                    return;
                }

                int incSum = sum + 1;
                if(mOnCartEventListener != null){
                    mOnCartEventListener.onChangeGiftSum(mLSRecipientAnchorGiftItem, getItemBean(getPosition(holder)), sum, incSum);
                }
            }
        });

        //输入
        holder.edt_sum.setOnFocusChangeListener(new View.OnFocusChangeListener() {
            @Override
            public void onFocusChange(View v, boolean hasFocus) {
                EditText edt_sum = (EditText)v;
                if(!hasFocus){
                    //失去焦点时代表输入完成
                    if (edt_sum.getText().toString().startsWith("0") || edt_sum.getText().toString().equals("")) {
                        ToastUtil.showToast(mContext, R.string.my_cart_num_out_range);
                        edt_sum.setText(String.valueOf(holder.oldSum) );
                        edt_sum.setSelection(1);
                        return;
                    }

                    int sum = Integer.valueOf(holder.edt_sum.getText().toString());
                    if(holder.isInput && sum != holder.oldSum){
                        //回调
                        if(mOnCartEventListener != null){
                            holder.setUIEnabled(false);
                            mOnCartEventListener.onChangeGiftSum(mLSRecipientAnchorGiftItem, getItemBean(getPosition(holder)), holder.oldSum, sum);
                            holder.isInput = false;
                        }
                    }
                }else{
                    //获得焦点，代表用户正在输入
                    holder.isInput = true;
                    if(edt_sum.length() > 0){
                        holder.oldSum = Integer.valueOf(edt_sum.getText().toString());
                    }
                }
            }
        });
//        holder.edt_sum.setOnTouchListener(new View.OnTouchListener() {
//            @Override
//            public boolean onTouch(View v, MotionEvent event) {
//                holder.isInput = true;
//                if(holder.edt_sum.length() > 0){
//                    holder.oldSum = Integer.valueOf(holder.edt_sum.getText().toString());
//                }
//                return false;
//            }
//        });
//        holder.edt_sum.addTextChangedListener(new TextWatcher() {
//
//            @Override
//            public void onTextChanged(CharSequence s, int start, int before, int count) {
//                Log.i("Jagger" , "onTextChanged");
//            }
//
//            @Override
//            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
//                Log.i("Jagger" , "beforeTextChanged");
//            }
//
//            @Override
//            public void afterTextChanged(Editable s) {
//                Log.i("Jagger" , "afterTextChanged:" + holder.isInput);
//
//                if (s.toString().startsWith("0") || s.toString().equals("")) {
//                    ToastUtil.showToast(mContext, R.string.my_cart_num_out_range);
//                    holder.isInput = false;
//                    holder.edt_sum.setText(String.valueOf(holder.oldSum) );
//                    holder.edt_sum.setSelection(1);
//                    return;
//                }
//
//                if(holder.isInput){
//                    holder.inputFeed.input(holder.edt_sum.getText().toString());
//                }
//            }
//        });
//        holder.edt_sum.setOnEditorActionListener(new TextView.OnEditorActionListener() {
//            @Override
//            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
//                if(actionId == EditorInfo.IME_ACTION_DONE){
//                    if (holder.edt_sum.toString().startsWith("0") || holder.edt_sum.toString().equals("")) {
//                        ToastUtil.showToast(mContext, R.string.my_cart_num_out_range);
////                        holder.isInput = false;
//                        holder.edt_sum.setText(String.valueOf(holder.oldSum) );
//                        holder.edt_sum.setSelection(1);
//                        return false;
//                    }
//
//                    if(holder.isInput){
//                        holder.inputFeed.input(holder.edt_sum.getText().toString());
//                    }
//                }
//                return false;
//            }
//        });
//        //输入频率控制，以免用户输入过慢而重复提交
//        Observable.create(new ObservableOnSubscribe<String>() {
//
//            @Override
//            public void subscribe(final ObservableEmitter<String> emitter) {
//                InputFeed.InputListener listener = new InputFeed.InputListener() {
//
//                    @Override
//                    public void onInputTick(String text) {
//                        //触发发射
//                        emitter.onNext(text);
//                    }
//                };
//
//                //输入事件发射源
//                holder.inputFeed.register(listener);
//            }})
//            .throttleWithTimeout(1000, TimeUnit.MILLISECONDS)   //通过时间来限流，源Observable每次发射出来一个数据后就会进行计时，如果在设定好的时间结束前源Observable有新的数据发射出来，这个数据就会被丢弃，同时重新开始计时。
//            .subscribeOn(Schedulers.io())		//io线程接收键盘输入
//            .observeOn(AndroidSchedulers.mainThread())//主线程显示表情
//            .subscribe(new Observer<String>() {
//
//                @Override
//                public void onComplete() {
//                    // TODO Auto-generated method stub
//
//                }
//
//                @Override
//                public void onError(Throwable arg0) {
//                    // TODO Auto-generated method stub
//
//                }
//
//                @Override
//                public void onNext(String inputStr) {
//                    // TODO Auto-generated method stub
//                    //回调
//                    if(mOnCartEventListener != null){
////                        isUiLock = true;
//                        holder.edt_sum.setEnabled(false);
//                        mOnCartEventListener.onChangeGiftSum(mLSRecipientAnchorGiftItem, getItemBean(getPosition(holder)), holder.oldSum, Integer.valueOf(inputStr));
//                        holder.isInput = false;
//                    }
//
//                }
//
//                @Override
//                public void onSubscribe(Disposable arg0) {
//                    // TODO Auto-generated method stub
//
//                }
//            });
    }

    @Override
    public void convertViewHolder(ViewHolderMyCartItem holder, LSFlowerGiftBaseInfoItem data, int position) {
        holder.setData(data, position);
    }

    /**
     * 当图片不显示的时候自动释放，防止oom
     *
     * @param holder
     */
    @Override
    public void onViewRecycled(RecyclerView.ViewHolder holder) {
        super.onViewRecycled(holder);
        if (holder instanceof ViewHolderMyCartItem) {
            ViewHolderMyCartItem viewHolder = (ViewHolderMyCartItem) holder;
            if (viewHolder.img_gift.getController() != null) {
                viewHolder.img_gift.getController().onDetach();
            }
        }
    }

    @Override
    public void onSummitResult(boolean isSuccess) {
        if(mMyCartGiftsSynManager.anchorId.equals(mLSRecipientAnchorGiftItem.anchorId)){
            if(isSuccess){
                for(int i = 0 ; i < getList().size(); i++){
                    if(getItemBean(i).giftId.equals(mMyCartGiftsSynManager.giftId)){
                        getItemBean(i).giftNumber = mMyCartGiftsSynManager.newSum;
                        changedItem(i);
                        break;
                    }
                }
            }else {
                for(int i = 0 ; i < getList().size(); i++){
                    if(getItemBean(i).giftId.equals(mMyCartGiftsSynManager.giftId)){
                        getItemBean(i).giftNumber = mMyCartGiftsSynManager.oldSum;
                        changedItem(i);
                        break;
                    }
                }
            }
        }
    }

    /**
     * 接收键盘输入内容，从而触发 onInputTick() 处理
     */
    protected static class InputFeed{
        public interface InputListener{
            void onInputTick(String text);
        }

        private InputListener mInputListener ;

        /**
         * 注册监听器
         * @param listener
         */
        public void register(InputListener listener){
            mInputListener = listener;
        }

        /**
         * 接收输入的文字
         * @param text
         */
        public void input(String text){
            if(mInputListener != null){
                mInputListener.onInputTick(text);
            }
        }
    }

    /**
     * ViewHolder
     */
    protected class ViewHolderMyCartItem extends BaseViewHolder<LSFlowerGiftBaseInfoItem> {
        public SimpleDraweeView img_gift;
        public ImageView img_des, img_inc;
        public TextView tv_flower_name, tv_price;
        public EditText edt_sum;
        public InputFeed inputFeed;
        public boolean isInput = false; //是否通过手动输入更改数据
        public int oldSum = 1;
        private int picSize ;

        public ViewHolderMyCartItem(View itemView) {
            super(itemView);
        }

        @Override
        public void bindItemView(View itemView) {
            img_gift = f(R.id.img_gift);
            img_des = f(R.id.img_des);
            img_inc = f(R.id.img_inc);
            tv_flower_name = f(R.id.tv_flower_name);
            tv_price = f(R.id.tv_price);
            edt_sum = f(R.id.edt_sum);

            picSize = mContext.getResources().getDimensionPixelSize(R.dimen.my_cart_flower_img_size);
            FrescoLoadUtil.setHierarchy(mContext, img_gift, R.color.black4, false, 6 , 6 ,6,6);
            inputFeed = new InputFeed();
        }

        @Override
        public void setData(final LSFlowerGiftBaseInfoItem data, int position) {
            FrescoLoadUtil.loadUrl(img_gift, data.giftImg, picSize);
            tv_flower_name.setText(data.giftId + " - " + data.giftName);
            if(data.giftNumber > 0){
                edt_sum.setText(String.valueOf(data.giftNumber));
                tv_price.setText( mContext.getString(R.string.my_cart_price, ApplicationSettingUtil.formatCoinValue(data.giftPrice*data.giftNumber)));
            }
            if(mMyCartGiftsSynManager.getStatus() == MyCartGiftsSynManager.Status.Waiting){
                setUIEnabled(true);
            }
        }

        /**
         * 修改礼物数量时，需要先锁UI， 返回后解锁
         * @param enabled
         */
        public void setUIEnabled(boolean enabled){
            img_des.setEnabled(enabled);
            img_inc.setEnabled(enabled);
            edt_sum.setEnabled(enabled);
        }
    }
}
