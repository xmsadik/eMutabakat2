INTERFACE zreco_if_common_types
  PUBLIC .

  constants MC_PARAMID_COMPANY type c LENGTH 20 value 'BUK'.
  constants MC_ICON_DELETE type ICON_D value '@11@'.
  constants MC_ICON_PROTOCOL type ICON_D value '@DH@'.
  constants MC_PARM_MFORM type c LENGTH 10 value 'MFORM'.
  constants MC_PARM_VAL type c LENGTH 10 value 'VAL'.
  constants MC_PARM_TRAN type c LENGTH 10 value 'TRAN'.
  constants MC_PARM_MTAX type c LENGTH 10 value 'MTAX'.
  constants MC_PARM_NO_LOCAL type c LENGTH 10 value 'NO_LOCAL'.
  constants MC_PARM_NO_VALUE type c LENGTH 10 value 'NO_VALUE'.
  constants MC_PARM_S_ODK type c LENGTH 10 value 'S_ODK'.
  constants MC_PARM_LOG type c LENGTH 10 value 'LOG'.
  constants MC_PARM_NO_MERGE type c LENGTH 10 value 'NO_MERGE'.
  constants MC_PARM_S4HANA type c LENGTH 10 value 'S4HANA'.
  constants MC_SELECT_YES type abap_boolean value 'X'.
  constants MC_SELECT_NO type abap_boolean value ''.
  constants MC_SCREEN_GROUP_F1 type c length 3 value 'F1'.
  constants MC_SCREEN_GROUP_V1 type c length 3 value 'V1'.
  constants MC_SCREEN_GROUP_R1 type c length 3 value 'R1'.
  constants MC_SCREEN_GROUP_L1 type c length 3 value 'L1'.
  constants MC_SCREEN_GROUP_D1 type c length 3 value 'D1'.
  constants MC_SCREEN_GROUP_D2 type c length 3 value 'D2'.
  constants MC_SCREEN_GROUP_D3 type c length 3 value 'D3'.
  constants MC_SCREEN_GROUP_BDT type c length 3 value 'BDT'.
  constants MC_SCREEN_GROUP_DAT type c length 3 value 'DAT'.
  constants MC_SCREEN_GROUP_GR2 type c length 3 value 'GR2'.
  constants MC_SCREEN_GROUP_GR1 type c length 3 value 'GR1'.
  constants MC_SCREEN_GROUP_K1 type c length 3 value 'K1'.
  constants MC_SCREEN_GROUP_GR3 type c length 3 value 'GR3'.
  constants MC_SCREEN_GROUP_X1 type c length 3 value 'X1'.
  constants MC_SCREEN_NAME_P_SELK type c LENGTH 100 value 'P_SELK'.
  constants MC_SCREEN_NAME_P_ALL type c LENGTH 100 value 'P_ALL'.
  constants MC_SCREEN_NAME_P_TRAN type c LENGTH 100 value 'P_TRAN'.
  constants MC_SCREEN_NAME_P_PERIOD type c LENGTH 100 value 'P_PERIOD'.
  constants MC_SCREEN_NAME_P_GJAHR type c LENGTH 100 value 'P_GJAHR'.
  constants MC_SCREEN_NAME_S_WAERS type c LENGTH 100 value '*S_WAERS*'.
  constants MC_SCREEN_NAME_S_GSBER type c LENGTH 100 value '*S_GSBER*'.
  constants MC_SCREEN_NAME_P_ZERO type c LENGTH 100 value '*P_ZERO*'.
  constants MC_SCREEN_NAME_P_EXCH type c LENGTH 100 value 'P_EXCH'.
  constants MC_SCREEN_NAME_BUDAT type c LENGTH 100 value '*BUDAT*'.
  constants MC_SCREEN_NAME_WAERS type c LENGTH 100 value '*WAERS*'.
  constants MC_SCREEN_NAME_NAME type c LENGTH 100 value '*NAME*'.
  constants MC_SCREEN_NAME_PARW type c LENGTH 100 value '*PARW*'.
  constants MC_SCREEN_NAME_DMBTR type c LENGTH 100 value 'DMBTR'.
  constants MC_SCREEN_NAME_P_FTYPE type c LENGTH 100 value 'P_FTYPE'.
  constants MC_HESAP_TUR_M type c LENGTH 20 value 'M'.
  constants MC_HESAP_TUR_S type c LENGTH 20 value 'S'.
  constants MC_MTYPE_B type c LENGTH 20 value 'B'.
  constants MC_MTYPE_C type c LENGTH 20 value 'C'.
  constants MC_DATE_BT type c LENGTH 20 value 'BT'.
  constants MC_DATE_KT type c LENGTH 20 value 'KT'.
  constants MC_NRART_LI type c LENGTH 20 value 'LI'.
  constants MC_NRART_PE type c LENGTH 20 value 'PE'.
  constants MC_UNLISTED_STATUS_99 type c LENGTH 20 value '99'.
  constants MC_MSG_E type SYMSGTY value 'E'.
  constants MC_MSG_S type SYMSGTY value 'S'.
  constants MC_MSG_W type SYMSGTY value 'W'.
  constants MC_MSG_CLASS type SYMSGID value '/ITETR/RECO'.
ENDINTERFACE.