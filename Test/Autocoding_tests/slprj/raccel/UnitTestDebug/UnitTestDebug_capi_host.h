#include "__cf_UnitTestDebug.h"
#ifndef RTW_HEADER_UnitTestDebug_cap_host_h_
#define RTW_HEADER_UnitTestDebug_cap_host_h_
#ifdef HOST_CAPI_BUILD
#include "rtw_capi.h"
#include "rtw_modelmap.h"
typedef struct { rtwCAPI_ModelMappingInfo mmi ; }
UnitTestDebug_host_DataMapInfo_T ;
#ifdef __cplusplus
extern "C" {
#endif
void UnitTestDebug_host_InitializeDataMapInfo (
UnitTestDebug_host_DataMapInfo_T * dataMap , const char * path ) ;
#ifdef __cplusplus
}
#endif
#endif
#endif
