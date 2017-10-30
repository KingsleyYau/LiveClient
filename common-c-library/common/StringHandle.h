/*
 * File         : StringHandle.h
 * Date         : 2012-07-02
 * Author       : Kingsley Yau
 */

#ifndef _INC_STRINGHANDLE_
#define _INC_STRINGHANDLE_

#include <ctype.h>
#include "KLog.h"
#include "Arithmetic.h"
#include <list>
using namespace std;

class StringHandle {
public:
	static list<string> split(string str, string pattern)
	{
	    list<string> result;
		size_t begin = 0;
		size_t found = 0;
		do {
			found = str.find(pattern, begin);
			if (string::npos != found) {
				string sub = str.substr(begin, found - begin);
				result.push_back(sub);

				begin = found + pattern.length();
			}
			else {
				string end = str.substr(begin, found);
				if (!end.empty()) {
					result.push_back(end);
				}
				break;
			}
		} while (true);

		return result;
	}

	static inline char* strIstr(const char *haystack, const char *needle) {
	    if (!*needle) {
	    	return (char*)haystack;
	    }
	    for (; *haystack; ++haystack) {
	    	if (toupper(*haystack) == toupper(*needle)) {
	    		const char *h, *n;
	    		for (h = haystack, n = needle; *h && *n; ++h, ++n) {
	    			if (toupper(*h) != toupper(*n)) {
	    				break;
	    			}
	    		}
	    		if (!*n) {
	    			return (char*)haystack;
	    		}
	    	}
	    }
	    return 0;
	}
	static inline string findStringBetween(char* pData, char* pBegin, char* pEnd, char* pTmpBuffer, int iTmpLen) {
		string strRet = "";
		char *pC_Begin = NULL, *pC_End = NULL, *pRep = NULL;
		int iLen = 256;

		if (pTmpBuffer && iTmpLen > 0) {
			pRep = pTmpBuffer;
			iLen = iTmpLen;
		} else {

			pRep = new char[256];

		}
		memset(pRep, 0, iLen);

		if ((pC_Begin = strIstr(pData, pBegin)) != 0) {

			if ((pC_End = strIstr(pC_Begin, pEnd)) != 0) {

				memcpy(pRep, pC_Begin, pC_End - pC_Begin);
				strRet = pRep;
			}

		}

		if (!pTmpBuffer || iTmpLen <= 0) {
			delete pRep;
		}

		return strRet;
	}
};

#endif


