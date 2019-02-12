/*
 *  author: Alex shum
 *    date: 2016-09-08
 *    file:LSLCMagicIconItem.cpp
 *    desc:LiveChat小高级表情消息item
 */

#include "LSLCMagicIconItem.h"
#include <common/CommonFunc.h>
#include <common/CheckMemoryLeak.h>

LSLCMagicIconItem::LSLCMagicIconItem()
{
    m_magicIconId = "";
    m_thumbPath    = "";
    m_sourcePath  = "";
}

LSLCMagicIconItem::LSLCMagicIconItem(LSLCMagicIconItem* item) {
    if (NULL != item) {
        m_magicIconId = item->m_magicIconId;
        m_thumbPath = item->m_thumbPath;
        m_sourcePath = item->m_sourcePath;
    } else {
        m_magicIconId = "";
        m_thumbPath    = "";
        m_sourcePath  = "";
    }
}

LSLCMagicIconItem::~LSLCMagicIconItem()
{

}


//初始化
bool LSLCMagicIconItem::Init(const string& magicIconId
                           , const string& thumPath
                           , const string& sourcePath)
{
    bool result = false;
    if( !magicIconId.empty())
    {
        m_magicIconId = magicIconId;
        
        if ( !thumPath.empty()) {
            result = true;
            if ( IsFileExist(thumPath)){
                m_thumbPath = thumPath;
            }
            
            if ( IsFileExist(sourcePath)) {
                m_sourcePath = sourcePath;
            }
        }
        
    }
    return result;
}
