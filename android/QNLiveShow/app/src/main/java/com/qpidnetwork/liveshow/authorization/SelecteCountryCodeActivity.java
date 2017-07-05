package com.qpidnetwork.liveshow.authorization;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.MotionEvent;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.qpidnetwork.framework.base.BaseFragmentActivity;
import com.qpidnetwork.liveshow.R;
import com.qpidnetwork.utils.DisplayUtil;
import com.qpidnetwork.view.SlideBar;

import java.util.HashMap;
import java.util.Map;

/**
 * Description:选取国家码界面
 * <p>
 * Created by Harry on 2017/5/19.
 */

public class SelecteCountryCodeActivity extends BaseFragmentActivity implements SlideBar.OnTouchLetterChangeListenner, AdapterView.OnItemClickListener {

    public static final int REQ_SELECTCOUNTRY=1;
    public static final int RES_SELECTCOUNTRY=2;

    private ListView lv_countryCodes;
    private SlideBar sb_codeIndex;
    private TextView tv_selectedCodeIndex;
    private float itemWidth = 0;//条目的宽度59+dp2px(40)
    private float itemHeight = 0;
    private float indexWidth = 0;//dp2px(40)
    private float fontSize = 0;
    private String[] allCountryCodes = new String[0];
    private ArrayAdapter la_countryCodes;
    // 准备好的A~Z的字母数组
    public static String[] letters = {"A", "B", "C", "D", "E", "F", "G",
            "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
            "U", "V", "W", "X", "Y", "Z" };
    public Map<String,Integer> indexMap = new HashMap<String,Integer>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        TAG = getClass().getSimpleName();
        super.onCreate(savedInstanceState);
        initView();
        initDataNeeded();
    }

    /**
     * 返回当前activity的视图布局ID
     *
     * @return
     */
    @Override
    public int getActivityViewId() {
        return R.layout.activity_select_country_code;
    }

    private void initView(){
        tv_selectedCodeIndex = (TextView)findViewById(R.id.tv_selectedCodeIndex);
        lv_countryCodes = (ListView)findViewById(R.id.lv_countryCodes);
        lv_countryCodes.setOnItemClickListener(SelecteCountryCodeActivity.this);
        sb_codeIndex = (SlideBar)findViewById(R.id.sb_codeIndex);
        sb_codeIndex.setTipView(tv_selectedCodeIndex);

        sb_codeIndex.setOnTouchLetterChangeListenner(SelecteCountryCodeActivity.this);
    }

    private void initDataNeeded(){
        indexWidth = DisplayUtil.dip2px(SelecteCountryCodeActivity.this,40f);
        fontSize = DisplayUtil.dip2px(SelecteCountryCodeActivity.this, 12f);
        int leftJianTouWidth = DisplayUtil.dip2px(SelecteCountryCodeActivity.this,10f);
        itemWidth = indexWidth+leftJianTouWidth;
        itemHeight = fontSize+DisplayUtil.dip2px(SelecteCountryCodeActivity.this,8f);
        sb_codeIndex.setShowTipView(true);
        //非自适应模式，即手动设置相关的高宽属性
        sb_codeIndex.setShowType(SlideBar.SHOWTYPE_ADAPTIVESIZE);
        sb_codeIndex.setItemSize(itemWidth,itemHeight);
        sb_codeIndex.setIndexWidth(indexWidth);
        sb_codeIndex.setIndexData(letters,indexMap);
        sb_codeIndex.setIndexTxtFont(fontSize);
        la_countryCodes = new ArrayAdapter<String>(SelecteCountryCodeActivity.this, android.R.layout.simple_list_item_1,allCountryCodes);
        lv_countryCodes.setAdapter(la_countryCodes);
        new Thread(){
            @Override
            public void run() {
                allCountryCodes = SelecteCountryCodeActivity.this.getResources().getStringArray(R.array.allCountryCodes);
                indexMap.clear();
                for(String letter : letters){
                    indexMap.put(letter,-1);
                    for(int index=0; index<allCountryCodes.length;index++ ){
                        if(allCountryCodes[index].substring(0,1).equals(letter)){
                            indexMap.put(letter,index);
                            break;
                        }
                    }
                }

                SelecteCountryCodeActivity.this.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        la_countryCodes = new ArrayAdapter<String>(SelecteCountryCodeActivity.this, android.R.layout.simple_list_item_1,allCountryCodes);
                        lv_countryCodes.setAdapter(la_countryCodes);
                        la_countryCodes.notifyDataSetChanged();
                    }
                });
            }
        }.start();
    }

    @Override
    public void onTouchLetterChange(MotionEvent event, String letter, int index, float itemHeight, boolean isFignUp) {
        lv_countryCodes.setSelection(index);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(null != sb_codeIndex){
            sb_codeIndex.setTipView(null);
        }

    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        onCountryCodeSelected(allCountryCodes[position]);
    }

    private void onCountryCodeSelected(String countrycode) {
        Intent intent = new Intent();
        intent.putExtra("countryCode",countrycode);
        setResult(RES_SELECTCOUNTRY,intent);
        finish();
    }
}
