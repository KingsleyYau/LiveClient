/**
  * Author	: Samson
  * Date	: 2016-01-26
  * Description	: for check momory leak
  * File	: CheckMemoryLeak.cpp
  */

#ifdef _CHECK_MEMORY_LEAK
#include <common/KLog.h>
#include <stdio.h>
#include <stdarg.h>
//#include "CheckMemoryLeak.h"
#include "CheckMemoryList.h"

static AllocList g_allocList;
static AllocList g_boundList;
static DataList g_lostList;

// version of OutputDebugString that allows variable # args
void OutputDebugStringf(const char *szFmt, ...)
{
    va_list marker;
    va_start(marker, szFmt);  // the varargs start at szFmt
    char szBuf[20480];
    vsnprintf(szBuf, sizeof(szBuf),szFmt, marker);
	//FileLog("leak", "%s", szBuf);
    OutputDebugStringA(szBuf);
	OutputDebugStringA("\n");
}

void * MyAlloc(size_t cbSize, const char *szFile = __FILE__, unsigned int  nLineNo = __LINE__)
{
    // We allocate a header followed by the desired allocation
    void *p = malloc(sizeof(AllocHeader) + cbSize + sizeof(AllocEnd));
	//void* p = operator new(sizeof(AllocHeader) + cbSize + sizeof(AllocEnd));
    AllocHeader *pHeader = (AllocHeader *)p;
	pHeader->Init();
    strncpy(pHeader->file, szFile, sizeof(pHeader->file));
    pHeader->nLineNo = nLineNo;
	pHeader->size = cbSize;

	// get data point
	char* data = (char*)p + sizeof(AllocHeader);

	// fill end
	AllocEnd *pEnd = (AllocEnd*)(data + cbSize);
	pEnd->Init();

	// insert to map
	g_allocList.Insert(pHeader);

	// print log
//	OutputDebugStringf("new data:%p", p);
//	__android_log_print(ANDROID_LOG_DEBUG, "leak", "new data:%p", p);

    // we return the address + sizeof(AllocHeader)
    return (void *)data;
}

void MyDelete(void *p, const char *szFile = __FILE__, unsigned int  nLineNo = __LINE__)
{
	// print log
//	OutputDebugStringf("delete data:%p", p);
//	__android_log_print(ANDROID_LOG_DEBUG, "leak", "delete data:%p", p);

	if (NULL == p) {
		return;
	}

    // we need to free our allocator too
	if (g_allocList.Has(p)) 
	{
		// get header
		AllocHeader* pHeader = g_allocList.GetAndRemove(p);
		// get end
		AllocEnd* pEnd = (AllocEnd*)((char*)p + pHeader->size);

		// check out of bounds
		if (!pHeader->IsCheckCodeOK()
			|| !pEnd->IsCheckCodeOK())
		{
			// out of bounds
			g_boundList.Insert(pHeader);

			// print log
			OutputDebugStringf("bound file:%s, line:%d, size:%d"
				, pHeader->file, pHeader->nLineNo, pHeader->size);
		}
		else {
			// free momory
			free(pHeader);
			//operator delete(pHeader);
		}
	}
	else {
		// lost point
		g_lostList.Insert(p);
	}
} 

void * operator new(size_t size)
{
	return MyAlloc(size, __FILE__, __LINE__);
}

void * operator new(size_t size, const char *file, int line)
{
	return MyAlloc(size, file, line);
}

#ifndef _WIN32
void * operator new[](size_t size, const char *file, int line)
{
	return MyAlloc(size, file, line);
}
#endif

void operator delete(void * p)  
{
	MyDelete(p);
}

void operator delete[](void * p)  
{  
	MyDelete(p);
}

void operator delete(void * p, const char *file, int line)  
{  
	MyDelete(p, file, line);
}

void operator delete[](void * p, const char *file, int line)  
{  
	MyDelete(p, file, line);
}

#endif

void OutputMemoryLeakInfo(const char* dir)
{
#ifdef _CHECK_MEMORY_LEAK
	AllocHeader* header = NULL;

	if (NULL != dir && strlen(dir) > 0)
	{
		KLog::SetLogDirectory(dir);
	}

	// output momory of leak
	while (NULL != (header = g_allocList.GetHeadAndRemove()))
	{
		OutputDebugStringf("leak file:%s, line:%d, size:%d"
			, header->file, header->nLineNo, header->size);
	}

	// output momory of bound
	while (NULL != (header = g_boundList.GetHeadAndRemove()))
	{
		OutputDebugStringf("bound file:%s, line:%d, size:%d"
			, header->file, header->nLineNo, header->size);
	}

	// output lost momory
	void* data = NULL;
	while (NULL != (data = g_lostList.GetHeadAndRemove()))
	{
		OutputDebugStringf("lost data:%p", data);
	}
#endif
}
