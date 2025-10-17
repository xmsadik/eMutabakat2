  METHOD get_name_text.

    CASE is_out-hesap_tur.
      WHEN 'M'.
        READ TABLE gt_kna1 ASSIGNING FIELD-SYMBOL(<lfs_kna1>) WITH KEY Customer = is_out-hesap_no.
        IF sy-subrc EQ 0. "YiğitcanÖzdem
          cs_out-land1 = <lfs_kna1>-Country.


          READ TABLE gt_t005t ASSIGNING FIELD-SYMBOL(<lfs_t005t>) WITH KEY Country = <lfs_kna1>-Country.

          IF sy-subrc EQ 0.
            cs_out-landx = <lfs_t005t>-CountryShortName.
          ENDIF.

        ENDIF.
*      CONCATENATE gt_kna1-name1 gt_kna1-name2 INTO c_out-name1
*      SEPARATED BY space.


      WHEN 'S'.
        READ TABLE gt_lfa1 ASSIGNING FIELD-SYMBOL(<lfs_lfa1>) WITH KEY Supplier = is_out-hesap_no.
        IF sy-subrc EQ 0.
          cs_out-land1 = <lfs_lfa1>-Country.

          READ TABLE gt_t005t ASSIGNING <lfs_t005t> WITH KEY Country = <lfs_lfa1>-Country.
          IF sy-subrc EQ 0.
            cs_out-landx = <lfs_t005t>-CountryShortName.
          ENDIF.
        ENDIF.
*      CONCATENATE gt_lfa1-name1 gt_lfa1-name2 INTO c_out-name1
*      SEPARATED BY space.


    ENDCASE.

  ENDMETHOD.