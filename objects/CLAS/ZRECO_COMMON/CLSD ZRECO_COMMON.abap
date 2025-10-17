class-pool .
*"* class pool for class ZRECO_COMMON

*"* local type definitions
include ZRECO_COMMON==================ccdef.

*"* class ZRECO_COMMON definition
*"* public declarations
  include ZRECO_COMMON==================cu.
*"* protected declarations
  include ZRECO_COMMON==================co.
*"* private declarations
  include ZRECO_COMMON==================ci.
endclass. "ZRECO_COMMON definition

*"* macro definitions
include ZRECO_COMMON==================ccmac.
*"* local class implementation
include ZRECO_COMMON==================ccimp.

*"* test class
include ZRECO_COMMON==================ccau.

class ZRECO_COMMON implementation.
*"* method's implementations
  include methods.
endclass. "ZRECO_COMMON implementation
