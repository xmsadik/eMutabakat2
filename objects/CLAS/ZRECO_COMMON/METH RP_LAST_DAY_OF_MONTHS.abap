  METHOD  rp_last_day_of_months.
    DATA: BEGIN OF date,
            j(4),
            m(2),
            t(2),
          END OF date.

    DATA: zahl TYPE i.

    DATA: januar(2)   VALUE '01',
          december(2) VALUE '12',
          lowdate(4)  VALUE '1800',
          frist(2)    VALUE '01'.

    DATA: BEGIN OF highdate,
            j(4) VALUE '9999',
            m(2) VALUE '12',
            t(2) VALUE '31',
          END OF highdate.

    date = day_in.

    IF date-m LT januar OR date-m GT december.
*   MESSAGE e401(5d) WITH day_in
*      MESSAGE e010     WITH day_in
*                RAISING day_in_no_date.
    ENDIF.

    IF date-j LT lowdate.
*   MESSAGE e401(5d) WITH day_in8
*      MESSAGE e010     WITH day_in
*               RAISING day_in_no_date.
    ENDIF.

    IF date-j EQ highdate-j AND
       date-m EQ highdate-m.

      last_day_of_month = highdate.

    ELSE.

      IF date-m EQ december.
        zahl = date-j + 1.
*        UNPACK zahl TO date-j.
        date-j = zahl.
        date-m = frist.
      ELSE.
        zahl = date-m + 1.
        date-m = zahl.
*        UNPACK zahl TO date-m.
        IF zahl BETWEEN 1 AND 9.
          date-m = '0' && zahl.
        ENDIF.
      ENDIF.
* Erster des Folgemonats
      date-t = frist.
      last_day_of_month = date.
      last_day_of_month -= 1.
    ENDIF.
  ENDMETHOD.