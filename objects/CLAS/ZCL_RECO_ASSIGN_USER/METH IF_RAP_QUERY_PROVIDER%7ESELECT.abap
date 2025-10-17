  METHOD if_rap_query_provider~select.

    TRY.


        DATA(lt_filter) = io_request->get_filter( )->get_as_ranges( ).
        DATA: lt_bukrs_range     TYPE RANGE OF bukrs,
              lt_reco_type_range TYPE RANGE OF zreco_type,
              lt_kunnr_range     TYPE RANGE OF kunnr,
              lt_lifnr_range     TYPE RANGE OF lifnr,
              lt_akont_range     TYPE RANGE OF akont,
              lt_ktokd_range     TYPE RANGE OF ktokd,
              lt_brsch_range     TYPE RANGE OF brsch,


              lt_output          TYPE TABLE OF zreco_ddl_i_assign_user,
              ls_output          TYPE zreco_ddl_i_assign_user.

        DATA(lt_paging) = io_request->get_paging( ).
*
        LOOP AT lt_filter INTO DATA(ls_filter).
          CASE ls_filter-name.
            WHEN 'bukrs'.
              lt_bukrs_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'reco_type'.
              lt_reco_type_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'kunnr'.
              lt_kunnr_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'lifnr'.
              lt_lifnr_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'akont'.
              lt_akont_range = CORRESPONDING #( ls_filter-range ).
            WHEN 'ktokd'.
              lt_ktokd_Range = CORRESPONDING #( ls_filter-range ).
            WHEN 'brsch'.
              lt_brsch_range = CORRESPONDING #( ls_filter-range ).


          ENDCASE.
        ENDLOOP.
*
        p_bukrs  = VALUE #( lt_bukrs_range[ 1 ]-low OPTIONAL ).
        p_mtype  = VALUE #( lt_bukrs_range[ 1 ]-low OPTIONAL ).
        p_kunnr  = VALUE #( lt_kunnr_range[ 1 ]-low OPTIONAL ).
        p_lifnr = VALUE #( lt_lifnr_range[ 1 ]-low OPTIONAL ).
        p_akont  = VALUE #( lt_akont_range[ 1 ]-low OPTIONAL ).
        p_ktokd  = VALUE #( lt_ktokd_Range[ 1 ]-low OPTIONAL ).
        p_brsch  = VALUE #( lt_brsch_range[ 1 ]-low OPTIONAL ).

        TYPES: BEGIN OF ty_kna1,
                 kunnr TYPE kunnr,
                 name  TYPE char256,
               END OF ty_kna1.

        TYPES: BEGIN OF ty_lfa1,
                 lifnr TYPE lifnr,
                 name  TYPE char256,
               END OF ty_lfa1.

        DATA: lt_kna1 TYPE TABLE OF ty_kna1,
              ls_kna1 TYPE ty_kna1,
              lt_lfa1 TYPE TABLE OF ty_lfa1,
              ls_lfa1 TYPE ty_lfa1.

        DATA: ls_outx TYPE zreco_ddl_i_assign_user,
              ls_out  TYPE zreco_cvua.
* hkizilkaya --->

*  REFRESH: gt_out_temp, gt_out, gt_data_temp, gt_data.

        SELECT * FROM zreco_cvua
                WHERE bukrs EQ @p_bukrs
                  AND mtype EQ @p_mtype
                  AND kunnr EQ @p_kunnr
                  AND lifnr EQ @p_lifnr
                  INTO TABLE @gt_data_temp.

        IF p_kunnr IS NOT INITIAL.
          SELECT customer AS kunnr ,CustomerName AS name
            FROM i_customer
           WHERE customer EQ @p_kunnr
             AND CustomerAccountGroup EQ @p_ktokd
             AND Industry EQ @p_brsch
             INTO TABLE @lt_kna1.

          SELECT  kna1~customer AS kunnr ,
                 kna1~CustomerName AS name

            FROM i_customer AS kna1 INNER JOIN i_CUSTOMERCOMPANY AS knb1 ON kna1~customer EQ knb1~Customer
           WHERE kna1~customer EQ @p_kunnr
             AND kna1~CustomerAccountGroup EQ @p_ktokd
             AND kna1~Industry EQ @p_brsch
             AND knb1~CompanyCode EQ @p_bukrs
             AND knb1~ReconciliationAccount EQ @p_akont
             AND kna1~DeletionIndicator EQ ''
             AND knb1~DeletionIndicator EQ ''
             APPENDING CORRESPONDING FIELDS OF TABLE @gt_out.
        ENDIF.

        IF p_lifnr IS NOT INITIAL.
          SELECT supplier AS lifnr, suppliername AS name1
            FROM i_supplier

           WHERE supplier EQ @p_lifnr
             AND SupplierAccountGroup EQ @p_ktokd
             AND Industry EQ @p_brsch
             INTO TABLE @lt_lfa1.

          SELECT  lfa1~supplier AS kunnr ,
                 lfa1~suppliername AS name


            FROM i_supplier AS lfa1 INNER JOIN i_suppliercompany AS lfb1 ON lfa1~supplier EQ lfb1~supplier
           WHERE lfa1~supplier EQ @P_lifnr
             AND lfa1~SupplierAccountGroup EQ @p_ktokd
             AND lfa1~Industry EQ @p_brsch
             AND lfb1~CompanyCode EQ @p_bukrs
             AND lfb1~ReconciliationAccount EQ @P_Akont
             AND lfa1~DeletionIndicator EQ ''
             AND lfb1~DeletionIndicator EQ ''
             APPENDING CORRESPONDING FIELDS OF TABLE @gt_out.
        ENDIF.

        SORT lt_kna1 BY kunnr.
        SORT lt_lfa1 BY lifnr.
        SORT gt_data_temp BY kunnr mtype.


*         değişecek.. RYA
          data(base_url) = 'https://' && zcl_etr_regulative_common=>get_ui_url( ) && '/ui#'.

        LOOP AT gt_out INTO ls_outx WHERE kunnr IS NOT INITIAL .
*          ls_outx-authorized_users = TEXT-005.

          READ TABLE lt_kna1 INTO ls_kna1 WITH KEY kunnr = ls_outx-kunnr BINARY SEARCH.

          IF ls_outx-name IS INITIAL.
*            CONCATENATE ls_kna1-name ls_kna1-name2 INTO ls_outx-name
*            SEPARATED BY space.
            ls_outx-name = ls_kna1-name .
          ENDIF.

          READ TABLE gt_data_temp INTO ls_out WITH KEY kunnr = ls_outx-kunnr
                                                             mtype = p_mtype BINARY SEARCH.

*          ls_outx-uname1 = ls_out-uname1.
*          ls_outx-uname2 = ls_out-uname2.
*          ls_outx-uname3 = ls_out-uname3.



*           ls_outx-name_url = base_url && kunnr

          MODIFY gt_out FROM ls_outx. CLEAR ls_outx.
        ENDLOOP.

        SORT gt_data_temp BY lifnr mtype.
        LOOP AT gt_out INTO ls_outx WHERE lifnr IS NOT INITIAL.
*          ls_outx-authorized_users = TEXT-005.

          CLEAR: ls_out.

          READ TABLE lt_lfa1 INTO ls_lfa1 WITH KEY lifnr = ls_outx-lifnr BINARY SEARCH.

          IF ls_outx-name IS INITIAL.
*            CONCATENATE ls_lfa1-name1 ls_lfa1-name2 INTO ls_outx-name
*            SEPARATED BY space.
            ls_outx-name = ls_lfa1-name .
          ENDIF.

          READ TABLE gt_data_temp INTO ls_out WITH KEY lifnr = ls_outx-lifnr
                                                       mtype = p_mtype BINARY SEARCH.




*          ls_outx-uname1 = ls_out-uname1.
*          ls_outx-uname2 = ls_out-uname2.
*          ls_outx-uname3 = ls_out-uname3.

          MODIFY gt_out FROM ls_outx. CLEAR ls_outx.
        ENDLOOP.

        SORT gt_out BY kunnr lifnr.

        IF gt_out_temp[] IS INITIAL.
          gt_out_temp[] = gt_out[].
        ENDIF.

        LOOP AT gt_out_temp INTO DATA(ls_OUT1) .
          MOVE-CORRESPONDING ls_OUT1 TO ls_output.
          APPEND ls_output TO lt_output.
        ENDLOOP.


        IF io_request->is_total_numb_of_rec_requested(  ).
          io_response->set_total_number_of_records( iv_total_number_of_records = lines( lt_output ) ).
        ENDIF.
        io_response->set_data( it_data = lt_output ).


      CATCH cx_rap_query_filter_no_range.
    ENDTRY.
  ENDMETHOD.