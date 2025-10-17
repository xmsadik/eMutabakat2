class-pool .
*"* class pool for class ZCL_MERGE_TAX

*"* local type definitions
include ZCL_MERGE_TAX=================ccdef.

*"* class ZCL_MERGE_TAX definition
*"* public declarations
  include ZCL_MERGE_TAX=================cu.
*"* protected declarations
  include ZCL_MERGE_TAX=================co.
*"* private declarations
  include ZCL_MERGE_TAX=================ci.
endclass. "ZCL_MERGE_TAX definition

*"* macro definitions
include ZCL_MERGE_TAX=================ccmac.
*"* local class implementation
include ZCL_MERGE_TAX=================ccimp.

*"* test class
include ZCL_MERGE_TAX=================ccau.

class ZCL_MERGE_TAX implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_MERGE_TAX implementation
