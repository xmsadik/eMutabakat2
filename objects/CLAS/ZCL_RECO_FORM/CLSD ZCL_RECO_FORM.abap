class-pool .
*"* class pool for class ZCL_RECO_FORM

*"* local type definitions
include ZCL_RECO_FORM=================ccdef.

*"* class ZCL_RECO_FORM definition
*"* public declarations
  include ZCL_RECO_FORM=================cu.
*"* protected declarations
  include ZCL_RECO_FORM=================co.
*"* private declarations
  include ZCL_RECO_FORM=================ci.
endclass. "ZCL_RECO_FORM definition

*"* macro definitions
include ZCL_RECO_FORM=================ccmac.
*"* local class implementation
include ZCL_RECO_FORM=================ccimp.

*"* test class
include ZCL_RECO_FORM=================ccau.

class ZCL_RECO_FORM implementation.
*"* method's implementations
  include methods.
endclass. "ZCL_RECO_FORM implementation
