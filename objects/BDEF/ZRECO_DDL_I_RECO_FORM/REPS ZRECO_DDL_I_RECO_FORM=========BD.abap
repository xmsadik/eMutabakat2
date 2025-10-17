unmanaged implementation in class zbp_reco_ddl_i_reco_form unique;
strict ( 2 ); //Uncomment this line in order to enable strict mode 2. The strict mode has two variants (strict(1), strict(2)) and is prerequisite to be future proof regarding syntax and to be able to release your BO.

define behavior for zreco_ddl_i_reco_form //alias <alias_name>
//late numbering
lock master
authorization master ( instance )
//etag master <field_name>
{
  //  create;
  //  update;
  //  delete;
  field ( readonly : update ) bukrs, akont, uuid, gjahr, period;

  action send result [1] $self;
  action print result [1] $self;

}