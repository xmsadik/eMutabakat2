unmanaged implementation in class zbp_reco_ddl_i_merge_tax unique;
strict ( 2 ); //Uncomment this line in order to enable strict mode 2. The strict mode has two variants (strict(1), strict(2)) and is prerequisite to be future proof regarding syntax and to be able to release your BO.

define behavior for zreco_ddl_i_merge_tax //alias <alias_name>
//late numbering
lock master
authorization master ( instance )
//etag master <field_name>
{
  create;
  update;
  delete;
//  field ( readonly : update ) erdat;
}