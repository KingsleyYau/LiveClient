#include "AMF3.h"

#define __int64 long long
// modify by samson 2016-03-29 修复由于符号位导致移位出错的问题
//#define BYTE char
#define BYTE unsigned char


namespace AMF3
{
__int64 swap_i64(__int64 data)
{
	// --- mask by samson 2016-03-29 ---
	// 修复由于符号位导致移位出错的问题

	//BYTE buf[8];
	//::memcpy(buf,&data,8);

	//__int64 retvalue = 0;
	//__int64 tmp;

	//tmp = buf[0];
	//retvalue = tmp<<56;

	//tmp = buf[1];
	//retvalue |= tmp<<48;

	//tmp = buf[2];
	//retvalue |= tmp<<40;

	//tmp = buf[3];
	//retvalue |= tmp<<32;

	//tmp = buf[4];
	//retvalue |= tmp<<24;

	//tmp = buf[5];
	//retvalue |= tmp<<16;

	//tmp = buf[6];
	//retvalue |= tmp<<8;

	//tmp = buf[7];
	//retvalue |= tmp;
	// -----------------------------------

	// --- add by samson 2016-03-29 ---
	__int64 retvalue = 0;

	BYTE *src = (BYTE*)&data;
	BYTE *des = (BYTE*)&retvalue;
	for (int i = 0; i < sizeof(data); i++)
	{
		des[i] = src[sizeof(data)-1-i];
	}
	// --------------------------------

	return retvalue;
}

unsigned __int64 swap_u64(unsigned __int64 data)
{
	// --- mask by samson 2016-03-29 ---
	//BYTE buf[8];
	//::memcpy(buf,&data,8);

	//unsigned __int64 retvalue = 0;
	//unsigned __int64 tmp;

	//tmp = buf[0];
	//retvalue = tmp<<56;

	//tmp = buf[1];
	//retvalue |= tmp<<48;

	//tmp = buf[2];
	//retvalue |= tmp<<40;

	//tmp = buf[3];
	//retvalue |= tmp<<32;

	//tmp = buf[4];
	//retvalue |= tmp<<24;

	//tmp = buf[5];
	//retvalue |= tmp<<16;

	//tmp = buf[6];
	//retvalue |= tmp<<8;

	//tmp = buf[7];
	//retvalue |= tmp;
	// --------------------------------

	// --- add by samson 2016-03-29 ---
	unsigned __int64 retvalue = 0;

	BYTE *src = (BYTE*)&data;
	BYTE *des = (BYTE*)&retvalue;
	for (int i = 0; i < sizeof(data); i++)
	{
		des[i] = src[sizeof(data)-1-i];
	}
	// --------------------------------

	return retvalue;
}

std::string UTF8_2_OEM (const char* utf8)
{
	return utf8;
//	if(utf8==0) return "";
//
//	int wlen = ::MultiByteToWideChar(CP_UTF8,0,utf8,-1,0,0);
//	wchar_t* wbuf = new wchar_t[wlen+1];
//	::MultiByteToWideChar(CP_UTF8,0,utf8,-1,wbuf,wlen);
//	wbuf[wlen] = L'0';
//
//	int clen = ::WideCharToMultiByte(CP_OEMCP,0,wbuf,-1,0,0,0,0);
//	char* cbuf = new char[clen+1];
//	::WideCharToMultiByte(CP_OEMCP,0,wbuf,-1,cbuf,clen,0,0);
//	cbuf[clen] = '\0';
//
//	std::string str = cbuf;
//
//	delete wbuf;
//	delete cbuf;
//
//	return str;
}

std::string OEM_2_UTF8(const char* oem)
{
	return oem;
//	if(oem==0) return "";
//
//	int wlen = ::MultiByteToWideChar(CP_OEMCP,0,oem,-1,0,0);
//	wchar_t* wbuf = new wchar_t[wlen+1];
//	::MultiByteToWideChar(CP_OEMCP,0,oem,-1,wbuf,wlen);
//	wbuf[wlen] = L'0';
//
//	int clen = ::WideCharToMultiByte(CP_UTF8,0,wbuf,-1,0,0,0,0);
//	char* cbuf = new char[clen+1];
//	::WideCharToMultiByte(CP_UTF8,0,wbuf,-1,cbuf,clen,0,0);
//	cbuf[clen] = '\0';
//
//	std::string str = cbuf;
//
//	delete wbuf;
//	delete cbuf;
//
//	return str;
}

////////////////////////////////////////
amf_object_handle::amf_object_handle():pobj(0)
{
}

amf_object_handle::amf_object_handle(const amf_object_handle &rhs)
{
	pobj = rhs.pobj;
	
	if(pobj!=NULL) 
		pobj->add_ref();
}

amf_object_handle::amf_object_handle(amf_object* obj)
{
	pobj = obj;
	if(pobj!=0)
		pobj->add_ref();
}

amf_object_handle::~amf_object_handle(void)
{
	if(pobj!=0)
		pobj->release();
}

bool amf_object_handle::isnull() const
{
	return pobj==0;
}

void amf_object_handle::release()
{
	if(pobj!=0)
		pobj->release();

	pobj = 0;
}

amf_object_handle& amf_object_handle::operator = (const amf_object_handle &rhs)
{
	if(pobj==rhs.pobj) 
		return *this;

	amf_object* old = pobj;
	pobj = rhs.pobj;
	
	if(pobj!=NULL) 
		pobj->add_ref();

	if(old!=NULL) 
		old->release();

	return *this;
}

amf_object_handle& amf_object_handle::operator = (amf_object* obj)
{
	if(pobj==obj) 
		return *this;

	amf_object* old = pobj;
	pobj = obj;
	
	if(pobj!=NULL) 
		pobj->add_ref();

	if(old!=NULL) 
		old->release();

	return *this;
}

amf_object* amf_object_handle::operator -> () const
{
	return pobj;
}

bool amf_object_handle::operator ==(const amf_object_handle &rhs) const
{
	return pobj==rhs.pobj;
}

////////////////////////////////////////
amf_object_handle amf_object::Alloc()
{
	amf_object_handle hobj = new amf_object();
	hobj->release();
	return hobj;
}

amf_object::amf_object()
{
	ref = 1;
	bytearrayLen = 0;
	bytearrayValue = 0;
	clear_value();
}

amf_object::~amf_object(void)
{
	clear_value();
}

void amf_object::clear_value()
{
	type = DT_UNDEFINED;
	
	boolValue = false;
	intValue = 0;
	doubleValue = 0.0f;
	strValue.clear();

	bytearrayLen = 0;
	if(bytearrayValue!=0)
	{
		delete bytearrayValue;
		bytearrayValue = 0;
	}

//	::memset(&dateValue,0,sizeof(SYSTEMTIME));
}

void amf_object::add_ref()
{
	ref++;
//	::InterlockedIncrement(&ref);
}

void amf_object::release()
{
	ref--;
	if (ref <= 0) {
		delete this;
	}
//	if(0==::InterlockedDecrement(&ref))
//		delete this;
}

#define EPOCH_DIFF 116444736000000000 //FILETIME starts from 1601-01-01 UTC, epoch from 1970- 01-01

double amf_object::get_time_seed()
{
//	TIME_ZONE_INFORMATION zinfo;
//	::GetTimeZoneInformation(&zinfo);
//
//	SYSTEMTIME st;
//	::TzSpecificLocalTimeToSystemTime(&zinfo,&dateValue,&st);
//
//	dateValue.wYear = st.wYear;
//	dateValue.wMonth = st.wMonth;
//	dateValue.wDay = st.wDay;
//	dateValue.wDayOfWeek = st.wDayOfWeek;
//	dateValue.wHour = st.wHour;
//	dateValue.wMinute = st.wMinute;
//	dateValue.wSecond = st.wSecond;
//	dateValue.wMilliseconds = st.wMilliseconds;
//
//	FILETIME filetime;
//	::SystemTimeToFileTime(&dateValue,&filetime);
//	__int64 t = filetime.dwHighDateTime;
//	t = t<<32 | filetime.dwLowDateTime;
//	t -= EPOCH_DIFF;
//	return (double)(t/10000);
	return 0;
}

void amf_object::set_time_seed(double t)
{
//	__int64 lft = (__int64)t;
//	lft = lft * 10000 + EPOCH_DIFF;
//
//	FILETIME ft;
//	ft.dwLowDateTime = (DWORD)lft;
//	ft.dwHighDateTime = (DWORD)(lft>>32);
//	::FileTimeToSystemTime(&ft,&dateValue);
//
//	TIME_ZONE_INFORMATION zinfo;
//	::GetTimeZoneInformation(&zinfo);
//
//	SYSTEMTIME st;
//	::SystemTimeToTzSpecificLocalTime(&zinfo,&dateValue,&st);
//
//	dateValue.wYear = st.wYear;
//	dateValue.wMonth = st.wMonth;
//	dateValue.wDay = st.wDay;
//	dateValue.wDayOfWeek = st.wDayOfWeek;
//	dateValue.wHour = st.wHour;
//	dateValue.wMinute = st.wMinute;
//	dateValue.wSecond = st.wSecond;
//	dateValue.wMilliseconds = st.wMilliseconds;
}

void amf_object::set_as_unsigned_number(unsigned int num)
{
	if(num<=0x0FFFFFFF)
	{
		type = DT_INTEGER;
		intValue = num;
	}
	else
	{
		type = DT_DOUBLE;
		doubleValue = (double)num;
	}
}

void amf_object::set_as_number(int num)
{
	if(num>0)
	{
		if(num<=0x0FFFFFFF)
		{
			type = DT_INTEGER;
			intValue = num;
		}
		else
		{
			type = DT_DOUBLE;
			doubleValue = (double)num;
		}
	}
	else
	{
		type = DT_DOUBLE;
		doubleValue = (double)num;
	}
}

void amf_object::add_child(amf_object_handle obj)
{
	childrens.push_back(obj);
}

bool amf_object::has_child(const char* name)
{
	for(size_t i=0;i<childrens.size();i++)
	{
		if(childrens[i]->name==name)
			return true;
	}

	return false;
}

amf_object_handle amf_object::get_child(const char* name)
{
	for(size_t i=0;i<childrens.size();i++)
	{
		if(childrens[i]->name==name)
			return childrens[i];
	}

	return 0;
}

//////////////////////////////////////////////////////////////
void init_context(context* ctx,READ_FUNC pRFunc,WRITE_FUNC pWFunc)
{
	ctx->m_IFileHandle = 0;
	ctx->m_OFileHandle = 0;

	ctx->m_ReadFunc = pRFunc;
	ctx->m_WriteFunc = pWFunc;

	ctx->s_ReadBufSize = 0;
	ctx->s_ReadBuf = 0;
}

void clear_context(context* ctx)
{
	if(ctx->s_ReadBufSize>0)
	{
		free(ctx->s_ReadBuf);
		ctx->s_ReadBufSize = 0;
		ctx->s_ReadBuf = 0;
	}

	ctx->m_IFileHandle = 0;
	ctx->m_OFileHandle = 0;

	ctx->m_szReadObjRefTab.clear();
	ctx->m_szReadStrRefTab.clear();
}

unsigned char* realloc_read_buf(context* ctx,size_t size)
{
	if(ctx->s_ReadBufSize >= 0 && (unsigned int)ctx->s_ReadBufSize < size)
	{
		free(ctx->s_ReadBuf);
		ctx->s_ReadBuf = (unsigned char*)malloc(size);
		ctx->s_ReadBufSize = size;
	}

	return ctx->s_ReadBuf;
}

//////////////////////////////////////////////////////////////


//////////////////////////////////////////////////////////////
//refrence
bool is_refrence(int header)
{
	return 0 == (header & REFERENCE_BIT);
}

amf_object_handle get_ref_tab(type_amf_ref_tab &tab,int idx)
{
	if(idx >= 0 && (unsigned int)idx < tab.size())
		return tab[idx];

	return 0;
}

int add_ref_tab(type_amf_ref_tab &tab,amf_object_handle obj)
{
	tab.push_back(obj);
	return tab.size()-1;
}

//refrence
//////////////////////////////////////////////////////////////


amf_object_handle read_elem(context* ctx);

//////////////////////////////////////////////////////////////
int read(context* ctx,size_t size,void* buf)
{
	return ctx->m_ReadFunc(ctx->m_IFileHandle,size,(unsigned char*)buf);
}

unsigned char read_byte(context* ctx)
{
	unsigned char data;
	read(ctx,1,&data);
	return data;
}

DataType read_type(context* ctx)
{
	return (DataType)read_byte(ctx);
}

int read_int(context* ctx)
{
	unsigned char byte = read_byte(ctx);
	int readnum = 0;
	int value = 0;
	while(((byte & 0x80)!=0) && (readnum<3))
	{
		value = (value<<7) | (byte & 0x7F);
		++readnum;
		byte = read_byte(ctx);
	}

	//最后一字节
	if(readnum<3)
		value = (value<<7) | (byte & 0x7F);
	else
		value = (value<<8) | (byte & 0xFF);

	//第29位的符号位
	if((value&0x10000000)!=0) {
		// modify by samson 2015-04-02 修复负数时高位补位不正确的问题
		//value = (value&0x10000000) | 0x80000000;
		value = value | 0xE0000000;
	}
	
	return value;
}

__int64 read_i64(context* ctx)
{
	__int64 data = 0;
	read(ctx,8,(unsigned char*)&data);
	return swap_i64(data);
}

unsigned __int64 read_u64(context* ctx)
{
	unsigned __int64 data = 0;
	read(ctx,8,(unsigned char*)&data);
	return swap_u64(data);
}

double read_double(context* ctx)
{
	double data = 0.0f;
	unsigned __int64 tmp = read_u64(ctx);
	::memcpy(&data,&tmp,8);
	return data;
}

void read_string(context* ctx,std::string &str)
{
	str.clear();

	int head = read_int(ctx);
	if(head==EMPTY_STRING) return;
	
	if(is_refrence(head))
	{
		int idx = head>>1;
		amf_object_handle obj = get_ref_tab(ctx->m_szReadStrRefTab,idx);
		if(!obj.isnull() && obj->type==DT_STRING)
		{
			str = obj->strValue;
		}
	}
	else
	{
		int len = head>>1;
		if(len<=0)
		{
			return;
		}

		char* buf = (char*)realloc_read_buf(ctx,len+1);
		read(ctx,len,buf);
		buf[len] = '\0';

		str = UTF8_2_OEM(buf);

		amf_object_handle obj = amf_object::Alloc();
		obj->type = DT_STRING;
		obj->strValue = str;
		add_ref_tab(ctx->m_szReadStrRefTab,obj);
	}
}

amf_object_handle read_date(context* ctx)
{
	amf_object_handle obj;

	int head = read_int(ctx);
	if(is_refrence(head))
	{
		//索引号
		int idx = head>>1;
		amf_object_handle refobj = get_ref_tab(ctx->m_szReadObjRefTab,idx);
		if(!refobj.isnull() && refobj->type==DT_DATE)
		{
			return refobj;
		}
	}
	else
	{
		double time = read_double(ctx)/1000;

		obj = amf_object::Alloc();
		obj->type = DT_DATE;
		obj->set_time_seed(time);
	
		add_ref_tab(ctx->m_szReadObjRefTab,obj);
	}

	return obj;
}

amf_object_handle read_array(context* ctx)
{
	amf_object_handle obj;

	int head = read_int(ctx);
	if(is_refrence(head))
	{
		int idx = head>>1;
		amf_object_handle refobj = get_ref_tab(ctx->m_szReadObjRefTab,idx);
		if(!refobj.isnull() && refobj->type==DT_ARRAY)
		{
			return refobj;
		}
	}
	else
	{
		obj = amf_object::Alloc();
		obj->type = DT_ARRAY;

		int subnum = head>>1;
		std::string name;
		read_string(ctx,name);

		//读取子元素
		for(int i=0;i<subnum;i++)
		{
			amf_object_handle sub = read_elem(ctx);
			if(!sub.isnull())
				obj->add_child(sub);
			else
				obj->add_child(amf_object::Alloc());
		}

		add_ref_tab(ctx->m_szReadObjRefTab,obj);
	}

	return obj;
}

amf_object_handle read_obj(context* ctx)
{
	amf_object_handle obj;

	int objref = read_int(ctx);
	bool dynamic = false;
	if(is_refrence(objref))
	{
		int idx = objref>>1;

		amf_object_handle refobj = get_ref_tab(ctx->m_szReadObjRefTab,idx);
		if(!refobj.isnull() && refobj->type==DT_OBJECT)
		{
			return refobj;
		}
	}
	else
	{
		int subnum = 0;

		int maskbit2 = ((objref>>1)&0x1);
		int maskbit3 = ((objref>>2)&0x1);
		int maskbit4 = ((objref>>3)&0x1);

		if(maskbit2==0)
		{
			int idx = objref>>2;

			amf_object_handle refobj = get_ref_tab(ctx->m_szReadObjRefTab,idx);
			if(!refobj.isnull() && refobj->type==DT_OBJECT)
			{
				return refobj;
			}
		}
		else
		{
			if(maskbit3==0)
			{
				dynamic = maskbit4!=0;
				subnum = objref>>4;
			}
			else
			{
				//暂不支持
			}
		}

		obj = amf_object::Alloc();
		obj->type = DT_OBJECT;

		read_string(ctx,obj->classname);

		std::string subname;
		std::vector<std::string> subs;
		for(int i=0;i<subnum;i++)
		{
			read_string(ctx,subname);
			subs.push_back(subname);
		}

		for(int i=0;i<subnum;i++)
		{
			amf_object_handle sub = read_elem(ctx);
			if(!sub.isnull())
			{
				sub->name = subs[i];
				obj->add_child(sub);
			}
		}

		//读取动态属性
		if(dynamic)
		{
			for(int i=0;i<DYNAMIC_OBJ_MAX_PROPERTY;i++)
			{
				read_string(ctx,subname);
				if(subname.empty()) break;

				amf_object_handle sub = read_elem(ctx);
				if(!sub.isnull())
				{
					sub->name = subname;
					obj->add_child(sub);
				}
			}
		}

		add_ref_tab(ctx->m_szReadObjRefTab,obj);
	}

	return obj;
}

amf_object_handle read_bytearray(context* ctx)
{
	amf_object_handle obj = amf_object::Alloc();
	obj->type = DT_BYTEARRAY;

	int objref = read_int(ctx);
	if(!is_refrence(objref))
	{
		int len = objref>>1;
		
		unsigned char* buf = (unsigned char*)malloc(len);
		read(ctx,len,buf);

		obj->bytearrayValue = buf;
		obj->bytearrayLen = len;

		return obj;
	}

	//可能有误，暂时不支持引用表
	int idx = objref>>1;
	obj = get_ref_tab(ctx->m_szReadObjRefTab,idx);
	if(!obj.isnull() && obj->type==DT_ARRAY)
	{
		return obj;
	}

	return NULL;
}

amf_object_handle read_elem(context* ctx)
{
	amf_object_handle obj = amf_object::Alloc();

	obj->type = read_type(ctx);
	switch(obj->type)
	{
	case DT_NULL:
	break;
	case DT_FALSE:
		obj->boolValue = false;
	break;
	case DT_TRUE:
		obj->boolValue = true;
	break;
	case DT_INTEGER:
		obj->intValue = read_int(ctx);
	break;
	case DT_DOUBLE:
		obj->doubleValue = read_double(ctx);
	break;
	case DT_STRING:
		read_string(ctx,obj->strValue);
	break;
	case DT_DATE:
		obj = read_date(ctx);
	break;
	case DT_ARRAY:
		obj = read_array(ctx);
	break;
	case DT_OBJECT:
		obj = read_obj(ctx);
	break;
	case DT_BYTEARRAY:
		obj = read_bytearray(ctx);
	break;
	default:
		return 0;
	break;
	}

	return obj;
}

////////////////////////////////////////////////////////////////////////////

void write_elem(context* ctx,amf_object_handle obj);

void write(context* ctx,const void* buf,size_t size)
{
	ctx->m_WriteFunc(ctx->m_OFileHandle,(unsigned char*)buf,size);
}

void write_byte(context* ctx,BYTE data)
{
	write(ctx,&data,1);
}

void write_type(context* ctx,DataType type)
{
	write_byte(ctx,type);
}

bool write_u29(context* ctx,unsigned int data)
{
	if(data<=0x7F)
	{
		write_byte(ctx,(BYTE)data);
		return true;
	}

	unsigned int tmp;
	BYTE buf[4];
	if(data<=0x3FFF)
	{
		tmp = data>>7 | 0x80;
		buf[0] = tmp;

		buf[1] = data & 0x7F;

		write(ctx,buf,2);

		return true;
	}

	if(data<=0x001FFFFF)
	{
		tmp = data>>14 | 0x80;
		buf[0] = tmp;

		tmp = ((data>>7) & 0x7F) | 0x80;
		buf[1] = tmp;

		buf[2] = data & 0x7F;

		write(ctx,buf,3);
		return true;
	}

	if(data<=0x0FFFFFFF)
	{
		tmp = data>>22 | 0x80;
		buf[0] = tmp;

		tmp = ((data>>15) & 0x7F) | 0x80;
		buf[1] = tmp;

		tmp = ((data>>8) & 0x7F) | 0x80;
		buf[2] = tmp;

		buf[3] = data & 0xFF;

		write(ctx,buf,4);

		return true;
	}

	return false;
}

void write_u64(context* ctx,unsigned __int64 data)
{
	unsigned __int64 vdata = swap_u64(data);
	write(ctx,&vdata,8);
}

void write_i64(context* ctx,__int64 data)
{
	__int64 vdata = swap_i64(data);
	write(ctx,&vdata,8);
}

void write_double(context* ctx,double data)
{
	unsigned __int64 tmp;
	::memcpy(&tmp,&data,8);
	write_u64(ctx,tmp);
}

void write_string(context* ctx,std::string str)
{
	str = OEM_2_UTF8(str.c_str());

	int len = str.length();
	if(len==0)
	{
		write_byte(ctx,0x1);
	}
	else
	{
		int objref = len<<1 | 1;
		write_u29(ctx,objref);
		write(ctx,str.c_str(),len);
	}
}

void write_date(context* ctx,amf_object_handle obj)
{
	write_u29(ctx,1);
	write_double(ctx,obj->get_time_seed());
}

void write_array(context* ctx,amf_object_handle obj)
{
	int objref = obj->childrens.size();
	objref = objref<<1 | 1;
	write_u29(ctx,objref);
	
	write_string(ctx,"");
	for(unsigned int i=0;i<obj->childrens.size();i++)
	{
		write_elem(ctx,obj->childrens[i]);
	}
}

void write_obj(context* ctx,amf_object_handle obj)
{
	int objref = 0x0B;
	write_u29(ctx,objref);
	write_string(ctx,"");

	for(unsigned int i=0;i<obj->childrens.size();i++)
	{
		write_string(ctx,obj->childrens[i]->name);
		write_elem(ctx,obj->childrens[i]);
	}

	write_string(ctx,"");
}

void write_bytearray(context* ctx,const BYTE* data,int len)
{
	int objref = len<<1 | 1;
	write_u29(ctx,objref);
	write(ctx,data,len);
}

void write_elem(context* ctx,amf_object_handle obj)
{
	if(obj.isnull()) return;

	write_type(ctx,obj->type);

	switch(obj->type)
	{
	case DT_UNDEFINED:
	case DT_NULL:
	case DT_FALSE:
	case DT_TRUE:
    case DT_XMLDOC:
    case DT_XML:
	break;
	case DT_INTEGER:
		write_u29(ctx,obj->intValue);
	break;
	case DT_DOUBLE:
		write_double(ctx,obj->doubleValue);
	break;
	case DT_STRING:
		write_string(ctx,obj->strValue);
	break;
	case DT_DATE:
		write_date(ctx,obj);
	break;
	case DT_ARRAY:
		write_array(ctx,obj);
	break;
	case DT_OBJECT:
		write_obj(ctx,obj);
	break;
	case DT_BYTEARRAY:
//		write_bytearray(ctx,obj->bytearrayValue,obj->bytearrayLen);
	break;
	}
}
////////////////////////////////////////////////////////////////////////////////////


amf_object_handle decode(context* ctx,void* file_handle)
{
	ctx->m_IFileHandle = file_handle;

	amf_object_handle hobj = read_elem(ctx);

	ctx->m_szReadObjRefTab.clear();
	ctx->m_szReadStrRefTab.clear();

	return hobj;
}


void encode(context* ctx,void* file_handle,amf_object_handle obj)
{
	ctx->m_OFileHandle = file_handle;
	write_elem(ctx,obj);
}



}//end namespace AMF3

