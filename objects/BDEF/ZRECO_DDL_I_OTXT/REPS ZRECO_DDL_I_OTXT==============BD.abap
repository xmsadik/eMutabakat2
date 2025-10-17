managed implementation in class zbp_reco_ddl_i_otxt unique;
strict ( 2 );

define behavior for ZRECO_DDL_I_OTXT //alias <alias_name>
persistent table zreco_otxt
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
  field ( readonly : update ) Bukrs, Spras, Ftype;

  mapping for zreco_otxt{
bukrs = Bukrs;
spras = Spras;
ftype = Ftype;
XblnrText = xblnr_text;
SgtxtText = sgtxt_text;
BudatText = budat_text;
NetdtText = netdt_text;
DelayText = delay_text;
AmountText = amount_text;
CurrencyText = currency_text;
TotalText = total_text;
DueText = due_text;

  }
}