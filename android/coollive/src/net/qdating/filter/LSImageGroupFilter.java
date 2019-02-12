package net.qdating.filter;

import android.opengl.GLES20;

import net.qdating.LSConfig;
import net.qdating.utils.Log;

import java.util.ArrayList;

/**
 * 滤镜组合
 * @author max
 *
 */
public class LSImageGroupFilter extends LSImageFilter {
	private ArrayList<LSImageFilter> filterArray = new ArrayList<LSImageFilter>();

	public LSImageGroupFilter() {
		super();
	}

	public void init() {
		Log.d(LSConfig.TAG, String.format("LSImageGroupFilter::init( this : 0x%x )", hashCode()));

		for(int i = 0; i < filterArray.size(); i++) {
			LSImageFilter filter = filterArray.get(i);
			filter.init();
		}
	}

	public void uninit() {
		Log.d(LSConfig.TAG, String.format("LSImageGroupFilter::uninit( this : 0x%x )", hashCode()));

		for(int i = 0; i < filterArray.size(); i++) {
			LSImageFilter filter = filterArray.get(i);
			filter.uninit();
		}
	}

	public void addFilter(LSImageFilter filter) {
		Log.d(LSConfig.TAG, String.format("LSImageGroupFilter::addFilter( this : 0x%x )", hashCode()));

		if ( !filterArray.contains(filter) ) {
			if( filterArray.size() > 0 ) {
				LSImageFilter lastFilter = filterArray.get(filterArray.size() - 1);
				lastFilter.setFilter(filter);
			}
			filterArray.add(filter);
		}
	}

	public void removeFilter(LSImageFilter filter) {
		int index = filterArray.indexOf(filter);
		if( index != -1) {
			LSImageFilter preFilter = null;
			LSImageFilter nextFilter = null;

			if( index > 0 ) {
				preFilter = filterArray.get(index - 1);
			}

			if( index < filterArray.size() - 1 ) {
				nextFilter = filterArray.get(index + 1);
			}

			if( preFilter != null && nextFilter != null ) {
				preFilter.setFilter(nextFilter);
			}

			filterArray.remove(index);
		}
	}

	@Override
	protected void onDrawStart(int textureId) {
	}

	@Override
	protected int onDrawFrame(int textureId) {
		int newTextureId = textureId;

		if( filterArray.size() > 0 ) {
			LSImageFilter filter = filterArray.get(0);
			newTextureId = filter.draw(textureId, inputWidth, inputHeight);
		}

		return newTextureId;
	}

	@Override
	protected void onDrawFinish(int textureId) {
	}
}
