package net.qdating.utils;

import net.qdating.LSConfig;

import java.io.File;
import java.io.FileWriter;
import java.util.Calendar;

public class Log {
	/**
	 * file log param
	 */
	private static String mDirPath = "";
	private static boolean mIsWriteFileLog = false;

	public static void v(String tag, String msg, Object... args) {
		if (android.util.Log.VERBOSE >= LSConfig.LOG_LEVEL) {
			android.util.Log.v(tag, String.format(msg, args));
			file(tag, msg, args);
		}
	}

	public static void d(String tag, String msg, Object... args) {
		if (android.util.Log.DEBUG >= LSConfig.LOG_LEVEL) {
			String m = String.format(msg, args);
			// m = (m.length() > 300 ? m.substring(0, 300) : m);
			android.util.Log.d(tag, m);
			file(tag, msg, args);
		}
	}

	public static void i(String tag, String msg, Object... args) {
		if (android.util.Log.INFO >= LSConfig.LOG_LEVEL) {
			android.util.Log.i(tag, String.format(msg, args));
			file(tag, msg, args);
		}
	}

	public static void w(String tag, String msg, Object... args) {
		if (android.util.Log.WARN >= LSConfig.LOG_LEVEL) {
			android.util.Log.w(tag, String.format(msg, args));
			file(tag, msg, args);
		}
	}

	public static void w(String tag, String msg, Throwable tr, Object... args) {
		if (android.util.Log.WARN >= LSConfig.LOG_LEVEL) {
			android.util.Log.w(tag, String.format(msg, args), tr);
			file(tag, msg, args);
		}
	}

	public static void e(String tag, String msg, Object... args) {
		if (android.util.Log.ERROR >= LSConfig.LOG_LEVEL) {
			android.util.Log.e(tag, String.format(msg, args));
			file(tag, msg, args);
		}
	}

	public static void e(String tag, String msg, Throwable tr, Object... args) {
		if (android.util.Log.ERROR >= LSConfig.LOG_LEVEL) {
			android.util.Log.e(tag, String.format(msg, args), tr);
		}
	}
	
	public static boolean initFileLog(String dirPath) {
		boolean result = false;
		if (!dirPath.isEmpty()) {
			mDirPath = dirPath;
			result = true;
		}
		return result;
	}
	
	public static void setWriteFileLog(boolean isWrite)
	{
		mIsWriteFileLog = isWrite;
	}
	
	public static void file(String tag, String msg, Object... agrs) {
		writeLog(mDirPath, tag, String.format(msg, agrs));
	}
	
	private static void writeLog(String dirPath, String tag, String strLog){
		if(!dirPath.isEmpty()  
			&& mIsWriteFileLog)
		{
			final String LASTNAME_OF_LOGFILE = ".log";
			try {
				String strLogToFile = "";
		        // 系统时间
	            Calendar cal = Calendar.getInstance();
	            int year = cal.get(Calendar.YEAR);
	            int month = cal.get(Calendar.MONTH)+1;
	            int day = cal.get(Calendar.DAY_OF_MONTH);

	            int hour = cal.get(Calendar.HOUR_OF_DAY);
	            int minute = cal.get(Calendar.MINUTE);
	            int second = cal.get(Calendar.SECOND);
	            int milsecond = cal.get(Calendar.MILLISECOND);

	            strLogToFile = String.format("(%d-%02d-%02d %02d:%02d:%02d.%03d) [%s] %s\n"
	            		, year, month, day, hour, minute, second, milsecond
	            		, tag, strLog);

	            // 文件名
	            String packageName = "coollive";
	            String fileName = packageName + "_" + year +"_"+ month + "_" + day + LASTNAME_OF_LOGFILE;
	            // 文件夹
	            String pathName = dirPath;

	            File path = new File(pathName);
	            File file = new File(pathName + fileName);
	            if(!path.exists()) {
	            	path.mkdirs();
	            }
	            if(!file.exists()) {
					file.createNewFile();
	            }
	            // 写文件
	            FileWriter writer = new FileWriter(file, true);
	            writer.write(strLogToFile);
	            writer.close();
			}
			catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
}