/*
 * MATLAB Compiler: 4.8 (R2008a)
 * Date: Sun Dec 19 15:58:14 2010
 * Arguments: "-B" "macro_default" "-m" "-W" "main" "-T" "link:exe"
 * "FinicialTimes" "III_IndexMap" "SymbolInfo.m" "-v" "-d"
 * "C:\SourceSafe\Stocks & Shares\Programs\FinicialTimes\Compiled\R0.15\" "-I"
 * "C:\SourceSafe\Stocks & Shares\Programs\FinicialTimes\" 
 */

#include "mclmcrrt.h"

#ifdef __cplusplus
extern "C" {
#endif
const unsigned char __MCC_FinicialTimes_session_key[] = {
    '7', '1', 'F', 'E', '7', '2', 'E', '9', '2', '7', '3', 'C', '7', '3', '4',
    'C', 'D', '2', '7', 'D', 'D', '7', '0', '8', 'B', 'A', 'E', 'C', '6', 'C',
    '1', '5', '2', '0', '2', 'B', '7', '4', '4', '2', '1', 'E', '8', '2', '7',
    '4', 'C', 'C', '4', '9', '6', '5', '6', 'E', 'D', '7', '9', 'A', 'D', '5',
    '4', '8', '3', '8', 'E', 'E', '6', '8', 'B', '1', 'B', 'F', '7', 'C', '2',
    '3', '4', 'B', 'B', 'E', '3', '2', 'A', 'F', 'D', '9', '1', '1', '8', 'B',
    '2', '8', '0', '8', '4', '1', '4', '7', 'D', 'B', '2', 'B', '0', '3', '7',
    '8', 'C', '1', 'F', '9', '4', '1', '8', '4', '2', '1', '8', 'A', '0', 'D',
    '0', '8', '3', '4', '4', '7', 'E', '5', 'F', '8', 'A', '3', '7', 'B', 'A',
    '7', 'C', '2', 'A', '0', '8', 'D', '2', 'F', '4', 'A', 'E', 'D', '4', '5',
    'B', '8', '7', 'B', '1', 'F', '6', 'F', '6', '6', '8', '5', 'C', 'F', '6',
    '6', 'F', '6', 'F', '6', '5', 'B', 'B', 'D', '4', '7', 'D', 'B', '1', '0',
    'D', 'D', 'C', 'B', '8', 'D', '3', '8', '2', 'F', '3', 'F', '2', '8', '6',
    '5', '3', 'B', '6', 'F', '4', '2', '8', '8', 'D', '7', 'C', 'A', '7', '9',
    '4', '5', '9', 'A', '4', '5', 'B', 'B', '4', '1', '8', 'C', '0', '7', 'A',
    '9', '7', '4', '1', 'B', 'E', 'F', '6', '4', 'E', '5', '9', '1', '2', '1',
    '6', '9', 'A', 'C', '2', '6', 'B', '4', 'A', '9', '7', '0', '2', '1', '8',
    '2', '\0'};

const unsigned char __MCC_FinicialTimes_public_key[] = {
    '3', '0', '8', '1', '9', 'D', '3', '0', '0', 'D', '0', '6', '0', '9', '2',
    'A', '8', '6', '4', '8', '8', '6', 'F', '7', '0', 'D', '0', '1', '0', '1',
    '0', '1', '0', '5', '0', '0', '0', '3', '8', '1', '8', 'B', '0', '0', '3',
    '0', '8', '1', '8', '7', '0', '2', '8', '1', '8', '1', '0', '0', 'C', '4',
    '9', 'C', 'A', 'C', '3', '4', 'E', 'D', '1', '3', 'A', '5', '2', '0', '6',
    '5', '8', 'F', '6', 'F', '8', 'E', '0', '1', '3', '8', 'C', '4', '3', '1',
    '5', 'B', '4', '3', '1', '5', '2', '7', '7', 'E', 'D', '3', 'F', '7', 'D',
    'A', 'E', '5', '3', '0', '9', '9', 'D', 'B', '0', '8', 'E', 'E', '5', '8',
    '9', 'F', '8', '0', '4', 'D', '4', 'B', '9', '8', '1', '3', '2', '6', 'A',
    '5', '2', 'C', 'C', 'E', '4', '3', '8', '2', 'E', '9', 'F', '2', 'B', '4',
    'D', '0', '8', '5', 'E', 'B', '9', '5', '0', 'C', '7', 'A', 'B', '1', '2',
    'E', 'D', 'E', '2', 'D', '4', '1', '2', '9', '7', '8', '2', '0', 'E', '6',
    '3', '7', '7', 'A', '5', 'F', 'E', 'B', '5', '6', '8', '9', 'D', '4', 'E',
    '6', '0', '3', '2', 'F', '6', '0', 'C', '4', '3', '0', '7', '4', 'A', '0',
    '4', 'C', '2', '6', 'A', 'B', '7', '2', 'F', '5', '4', 'B', '5', '1', 'B',
    'B', '4', '6', '0', '5', '7', '8', '7', '8', '5', 'B', '1', '9', '9', '0',
    '1', '4', '3', '1', '4', 'A', '6', '5', 'F', '0', '9', '0', 'B', '6', '1',
    'F', 'C', '2', '0', '1', '6', '9', '4', '5', '3', 'B', '5', '8', 'F', 'C',
    '8', 'B', 'A', '4', '3', 'E', '6', '7', '7', '6', 'E', 'B', '7', 'E', 'C',
    'D', '3', '1', '7', '8', 'B', '5', '6', 'A', 'B', '0', 'F', 'A', '0', '6',
    'D', 'D', '6', '4', '9', '6', '7', 'C', 'B', '1', '4', '9', 'E', '5', '0',
    '2', '0', '1', '1', '1', '\0'};

static const char * MCC_FinicialTimes_matlabpath_data[] = 
  { "FinicialTime/", "toolbox/compiler/deploy/",
    "SourceSafe/Stocks & Shares/Programs/Classes/",
    "SourceSafe/Stocks & Shares/Programs/BritishBulls/Maps/",
    "SourceSafe/Stocks & Shares/Programs/BritishBulls/",
    "$TOOLBOXMATLABDIR/general/", "$TOOLBOXMATLABDIR/ops/",
    "$TOOLBOXMATLABDIR/lang/", "$TOOLBOXMATLABDIR/elmat/",
    "$TOOLBOXMATLABDIR/elfun/", "$TOOLBOXMATLABDIR/specfun/",
    "$TOOLBOXMATLABDIR/matfun/", "$TOOLBOXMATLABDIR/datafun/",
    "$TOOLBOXMATLABDIR/polyfun/", "$TOOLBOXMATLABDIR/funfun/",
    "$TOOLBOXMATLABDIR/sparfun/", "$TOOLBOXMATLABDIR/scribe/",
    "$TOOLBOXMATLABDIR/graph2d/", "$TOOLBOXMATLABDIR/graph3d/",
    "$TOOLBOXMATLABDIR/specgraph/", "$TOOLBOXMATLABDIR/graphics/",
    "$TOOLBOXMATLABDIR/uitools/", "$TOOLBOXMATLABDIR/strfun/",
    "$TOOLBOXMATLABDIR/imagesci/", "$TOOLBOXMATLABDIR/iofun/",
    "$TOOLBOXMATLABDIR/audiovideo/", "$TOOLBOXMATLABDIR/timefun/",
    "$TOOLBOXMATLABDIR/datatypes/", "$TOOLBOXMATLABDIR/verctrl/",
    "$TOOLBOXMATLABDIR/codetools/", "$TOOLBOXMATLABDIR/helptools/",
    "$TOOLBOXMATLABDIR/winfun/", "$TOOLBOXMATLABDIR/demos/",
    "$TOOLBOXMATLABDIR/timeseries/", "$TOOLBOXMATLABDIR/hds/",
    "$TOOLBOXMATLABDIR/guide/", "$TOOLBOXMATLABDIR/plottools/",
    "toolbox/local/", "toolbox/shared/dastudio/",
    "$TOOLBOXMATLABDIR/datamanager/", "toolbox/compiler/",
    "toolbox/shared/optimlib/", "toolbox/datafeed/datafeed/",
    "toolbox/finance/calendar/", "toolbox/images/images/",
    "toolbox/images/imuitools/", "toolbox/images/iptutils/",
    "toolbox/shared/imageslib/", "toolbox/images/medformats/",
    "toolbox/stats/", "toolbox/shared/statslib/" };

static const char * MCC_FinicialTimes_classpath_data[] = 
  { "java/jar/toolbox/images.jar" };

static const char * MCC_FinicialTimes_libpath_data[] = 
  { "" };

static const char * MCC_FinicialTimes_app_opts_data[] = 
  { "" };

static const char * MCC_FinicialTimes_run_opts_data[] = 
  { "" };

static const char * MCC_FinicialTimes_warning_state_data[] = 
  { "off:MATLAB:dispatcher:nameConflict" };


mclComponentData __MCC_FinicialTimes_component_data = { 

  /* Public key data */
  __MCC_FinicialTimes_public_key,

  /* Component name */
  "FinicialTimes",

  /* Component Root */
  "",

  /* Application key data */
  __MCC_FinicialTimes_session_key,

  /* Component's MATLAB Path */
  MCC_FinicialTimes_matlabpath_data,

  /* Number of directories in the MATLAB Path */
  51,

  /* Component's Java class path */
  MCC_FinicialTimes_classpath_data,
  /* Number of directories in the Java class path */
  1,

  /* Component's load library path (for extra shared libraries) */
  MCC_FinicialTimes_libpath_data,
  /* Number of directories in the load library path */
  0,

  /* MCR instance-specific runtime options */
  MCC_FinicialTimes_app_opts_data,
  /* Number of MCR instance-specific runtime options */
  0,

  /* MCR global runtime options */
  MCC_FinicialTimes_run_opts_data,
  /* Number of MCR global runtime options */
  0,
  
  /* Component preferences directory */
  "FinicialTime_6F5B3B10DE0D9FBD789889578B6E7A9C",

  /* MCR warning status data */
  MCC_FinicialTimes_warning_state_data,
  /* Number of MCR warning status modifiers */
  1,

  /* Path to component - evaluated at runtime */
  NULL

};

#ifdef __cplusplus
}
#endif


