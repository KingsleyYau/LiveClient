/*
 * PngWriter.cpp
 *
 *  Created on: 2015-05-14
 *      Author: Samson
 *        desc: png写操作类
 */

#include "PngWriter.h"
#include <common/CheckMemoryLeak.h>

PngWriter::PngWriter()
{
	m_file = NULL;
	m_writePtr = NULL;
	m_writeInfoPtr = NULL;
	m_writeEndInfoPtr = NULL;
}

PngWriter::~PngWriter()
{
	Release();
}

// 设置png文件路径
bool PngWriter::SetFilePath(const string& path)
{
	bool result = false;
	if (!path.empty())
	{
		m_path = path;
		result = true;
	}
	return result;
}

// 初始化
bool PngWriter::Init()
{
	bool result = false;

	Release();

	do {
		if (m_path.empty()) {
			break;
		}

		m_file = fopen(m_path.c_str(), "wb");
		if (NULL == m_file) {
			break;
		}

		m_writePtr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
		if (NULL == m_writePtr) {
			break;
		}

		m_writeInfoPtr = png_create_info_struct(m_writePtr);
		if (NULL == m_writeInfoPtr) {
			break;
		}

		m_writeEndInfoPtr = png_create_info_struct(m_writePtr);
		if (NULL == m_writeEndInfoPtr) {
			break;
		}

		setjmp(png_jmpbuf(m_writePtr));
		png_init_io(m_writePtr, m_file);

		result = true;
	} while (0);

	if (!result)
	{
		Release();
	}

	return result;
}

// 释放资源
void PngWriter::Release()
{
	if (NULL != m_writePtr)
	{
		if (NULL != m_writeEndInfoPtr)
		{
			png_write_end(m_writePtr, m_writeEndInfoPtr);
			png_destroy_info_struct(m_writePtr, &m_writeEndInfoPtr);
			m_writeEndInfoPtr = NULL;
		}
		png_destroy_write_struct(&m_writePtr, &m_writeInfoPtr);

		m_writePtr = NULL;
		m_writeInfoPtr = NULL;
	}

	if (NULL != m_file)
	{
		fclose(m_file);
		m_file = NULL;
	}
}

// 写入一行png数据
bool PngWriter::WriteRowData(png_bytep data)
{
	bool result = false;
	if (NULL != m_writePtr
		&& NULL != m_writeInfoPtr)
	{
		png_write_row(m_writePtr, data);
	}
	return result;
}

// 获取png_strctp
png_structp PngWriter::GetWrite()
{
	return m_writePtr;
}

// 获取png_infop
png_infop PngWriter::GetWriteInfo()
{
	return m_writeInfoPtr;
}

// 获取结尾的png_infop
png_infop PngWriter::GetWriteEndInfo()
{
	return m_writeEndInfoPtr;
}

// 把读取的png信息写入到文件
bool PngWriter::SetWriteInfoByReadInfo(PngReader& readPng, png_uint_32 desWidth, png_uint_32 desHeight)
{
	bool result = false;

	// 初始化变量
	png_structp read_ptr = readPng.GetRead();
	png_infop read_info_ptr = readPng.GetReadInfo();
	png_structp write_ptr = GetWrite();
	png_infop write_info_ptr = GetWriteInfo();

	// 读取png文件信息
    png_uint_32 width;
    png_uint_32 height;
	int bit_depth;
    int color_type;
    int interlace_type;
	int compression_type;
	int filter_type;
	if (png_get_IHDR(read_ptr, read_info_ptr, &width, &height, &bit_depth,
          &color_type, &interlace_type, &compression_type, &filter_type) != 0)
      {
		png_set_IHDR(write_ptr, write_info_ptr, desWidth, desHeight, bit_depth,
            color_type, interlace_type, compression_type, filter_type);

		result = true;
	}

#ifdef PNG_FIXED_POINT_SUPPORTED
#ifdef PNG_cHRM_SUPPORTED
   {
      png_fixed_point white_x, white_y, red_x, red_y, green_x, green_y, blue_x,
         blue_y;

      if (png_get_cHRM_fixed(read_ptr, read_info_ptr, &white_x, &white_y,
         &red_x, &red_y, &green_x, &green_y, &blue_x, &blue_y) != 0)
      {
         png_set_cHRM_fixed(write_ptr, write_info_ptr, white_x, white_y, red_x,
            red_y, green_x, green_y, blue_x, blue_y);
      }
   }
#endif
#ifdef PNG_gAMA_SUPPORTED
   {
      png_fixed_point gamma;

      if (png_get_gAMA_fixed(read_ptr, read_info_ptr, &gamma) != 0)
         png_set_gAMA_fixed(write_ptr, write_info_ptr, gamma);
   }
#endif
#else /* Use floating point versions */
#ifdef PNG_FLOATING_POINT_SUPPORTED
#ifdef PNG_cHRM_SUPPORTED
   {
      double white_x, white_y, red_x, red_y, green_x, green_y, blue_x,
         blue_y;

      if (png_get_cHRM(read_ptr, read_info_ptr, &white_x, &white_y, &red_x,
         &red_y, &green_x, &green_y, &blue_x, &blue_y) != 0)
      {
         png_set_cHRM(write_ptr, write_info_ptr, white_x, white_y, red_x,
            red_y, green_x, green_y, blue_x, blue_y);
      }
   }
#endif
#ifdef PNG_gAMA_SUPPORTED
   {
      double gamma;

      if (png_get_gAMA(read_ptr, read_info_ptr, &gamma) != 0)
         png_set_gAMA(write_ptr, write_info_ptr, gamma);
   }
#endif
#endif /* Floating point */
#endif /* Fixed point */
#ifdef PNG_iCCP_SUPPORTED
   {
      png_charp name;
      png_bytep profile;
      png_uint_32 proflen;
      int compression_type;

      if (png_get_iCCP(read_ptr, read_info_ptr, &name, &compression_type,
                      &profile, &proflen) != 0)
      {
         png_set_iCCP(write_ptr, write_info_ptr, name, compression_type,
                      profile, proflen);
      }
   }
#endif
#ifdef PNG_sRGB_SUPPORTED
   {
      int intent;

      if (png_get_sRGB(read_ptr, read_info_ptr, &intent) != 0)
         png_set_sRGB(write_ptr, write_info_ptr, intent);
   }
#endif
   {
      png_colorp palette;
      int num_palette;

      if (png_get_PLTE(read_ptr, read_info_ptr, &palette, &num_palette) != 0)
         png_set_PLTE(write_ptr, write_info_ptr, palette, num_palette);
   }
#ifdef PNG_bKGD_SUPPORTED
   {
      png_color_16p background;

      if (png_get_bKGD(read_ptr, read_info_ptr, &background) != 0)
      {
         png_set_bKGD(write_ptr, write_info_ptr, background);
      }
   }
#endif
#ifdef PNG_hIST_SUPPORTED
   {
      png_uint_16p hist;

      if (png_get_hIST(read_ptr, read_info_ptr, &hist) != 0)
         png_set_hIST(write_ptr, write_info_ptr, hist);
   }
#endif
#ifdef PNG_oFFs_SUPPORTED
   {
      png_int_32 offset_x, offset_y;
      int unit_type;

      if (png_get_oFFs(read_ptr, read_info_ptr, &offset_x, &offset_y,
          &unit_type) != 0)
      {
         png_set_oFFs(write_ptr, write_info_ptr, offset_x, offset_y, unit_type);
      }
   }
#endif
#ifdef PNG_pCAL_SUPPORTED
   {
      png_charp purpose, units;
      png_charpp params;
      png_int_32 X0, X1;
      int type, nparams;

      if (png_get_pCAL(read_ptr, read_info_ptr, &purpose, &X0, &X1, &type,
         &nparams, &units, &params) != 0)
      {
         png_set_pCAL(write_ptr, write_info_ptr, purpose, X0, X1, type,
            nparams, units, params);
      }
   }
#endif
#ifdef PNG_pHYs_SUPPORTED
   {
      png_uint_32 res_x, res_y;
      int unit_type;

      if (png_get_pHYs(read_ptr, read_info_ptr, &res_x, &res_y,
          &unit_type) != 0)
         png_set_pHYs(write_ptr, write_info_ptr, res_x, res_y, unit_type);
   }
#endif
#ifdef PNG_sBIT_SUPPORTED
   {
      png_color_8p sig_bit;

      if (png_get_sBIT(read_ptr, read_info_ptr, &sig_bit) != 0)
         png_set_sBIT(write_ptr, write_info_ptr, sig_bit);
   }
#endif
#ifdef PNG_sCAL_SUPPORTED
#if defined(PNG_FLOATING_POINT_SUPPORTED) && \
   defined(PNG_FLOATING_ARITHMETIC_SUPPORTED)
   {
      int unit;
      double scal_width, scal_height;

      if (png_get_sCAL(read_ptr, read_info_ptr, &unit, &scal_width,
         &scal_height) != 0)
      {
         png_set_sCAL(write_ptr, write_info_ptr, unit, scal_width, scal_height);
      }
   }
#else
#ifdef PNG_FIXED_POINT_SUPPORTED
   {
      int unit;
      png_charp scal_width, scal_height;

      if (png_get_sCAL_s(read_ptr, read_info_ptr, &unit, &scal_width,
          &scal_height) != 0)
      {
         png_set_sCAL_s(write_ptr, write_info_ptr, unit, scal_width,
             scal_height);
      }
   }
#endif
#endif
#endif
#ifdef PNG_TEXT_SUPPORTED
   {
      png_textp text_ptr;
      int num_text;

      if (png_get_text(read_ptr, read_info_ptr, &text_ptr, &num_text) > 0)
      {
         png_set_text(write_ptr, write_info_ptr, text_ptr, num_text);
      }
   }
#endif
#ifdef PNG_tIME_SUPPORTED
   {
      png_timep mod_time;

      if (png_get_tIME(read_ptr, read_info_ptr, &mod_time) != 0)
      {
         png_set_tIME(write_ptr, write_info_ptr, mod_time);
      }
   }
#endif
#ifdef PNG_tRNS_SUPPORTED
   {
      png_bytep trans_alpha;
      int num_trans;
      png_color_16p trans_color;

      if (png_get_tRNS(read_ptr, read_info_ptr, &trans_alpha, &num_trans,
         &trans_color) != 0)
      {
         int sample_max = (1 << bit_depth);
         /* libpng doesn't reject a tRNS chunk with out-of-range samples */
         if (!((color_type == PNG_COLOR_TYPE_GRAY &&
             (int)trans_color->gray > sample_max) ||
             (color_type == PNG_COLOR_TYPE_RGB &&
             ((int)trans_color->red > sample_max ||
             (int)trans_color->green > sample_max ||
             (int)trans_color->blue > sample_max))))
            png_set_tRNS(write_ptr, write_info_ptr, trans_alpha, num_trans,
               trans_color);
      }
   }
#endif
#ifdef PNG_WRITE_UNKNOWN_CHUNKS_SUPPORTED
   {
      png_unknown_chunkp unknowns;
      int num_unknowns = png_get_unknown_chunks(read_ptr, read_info_ptr,
         &unknowns);

      if (num_unknowns != 0)
      {
         png_set_unknown_chunks(write_ptr, write_info_ptr, unknowns,
           num_unknowns);
#if PNG_LIBPNG_VER < 10600
         /* Copy the locations from the read_info_ptr.  The automatically
          * generated locations in write_end_info_ptr are wrong prior to 1.6.0
          * because they are reset from the write pointer (removed in 1.6.0).
          */
         {
            int i;
            for (i = 0; i < num_unknowns; i++)
              png_set_unknown_chunk_location(write_ptr, write_info_ptr, i,
                unknowns[i].location);
         }
#endif
      }
   }
#endif

#ifdef PNG_WRITE_SUPPORTED
   /* Write the info in two steps so that if we write the 'unknown' chunks here
    * they go to the correct place.
    */
   png_write_info_before_PLTE(write_ptr, write_info_ptr);

   png_write_info(write_ptr, write_info_ptr);

#endif

	return result;
}
// 把读取结尾的png信息写入到文件
bool PngWriter::SetWriteEndInfoByReadEndInfo(PngReader& readPng)
{
	bool result = false;

	png_structp read_ptr = readPng.GetRead();
	png_infop end_info_ptr = readPng.GetReadEndInfo();
	png_structp write_ptr = GetWrite();
	png_infop write_end_info_ptr = GetWriteEndInfo();

#ifdef PNG_TEXT_SUPPORTED
   {
      png_textp text_ptr;
      int num_text;

      if (png_get_text(read_ptr, end_info_ptr, &text_ptr, &num_text) > 0)
      {
         png_set_text(write_ptr, write_end_info_ptr, text_ptr, num_text);
      }
   }
#endif
#ifdef PNG_tIME_SUPPORTED
   {
      png_timep mod_time;

      if (png_get_tIME(read_ptr, end_info_ptr, &mod_time) != 0)
      {
         png_set_tIME(write_ptr, write_end_info_ptr, mod_time);
      }
   }
#endif

	return result;
}

