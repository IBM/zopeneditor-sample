 /****************************************************************
  * LICENSED MATERIALS - PROPERTY OF IBM
  * "RESTRICTED MATERIALS OF IBM"
  * (C) COPYRIGHT IBM CORPORATION 2021. ALL RIGHTS RESERVED
  * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
  * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
  * CONTRACT WITH IBM CORPORATION
  ****************************************************************/
   DCL 1 CUSTFILE_RECORD     CHAR(80);
   DCL 1 CUSTOMER_RECORD  BASED(ADDR(CUSTFILE_RECORD)),
         2 CUSTOMER_KEY,
           3 CUST_ID         CHAR(5),
           3 RECORD_TYPE     CHAR(1),
           3 CUST_KEY_FILL   CHAR(7),
         2 NAME              CHAR(17),
         2 ACCT_BALANCE      PIC '9999999V99',
         2 ORDERS_YTD        PIC '99999',
         2 CITY              CHAR(15),
         2 OCCUPATION        CHAR(21);
   DCL 1 PRODUCT_RECORD   BASED(ADDR(CUSTFILE_RECORD)),
         2 PRODUCT_KEY,
           3 CUST_ID         CHAR(5),
           3 RECORD_TYPE     CHAR(1),
           3 PRODUCT_ID      CHAR(7),
         2 PRODUCT_NAME      CHAR(25),
         2 DATE_PURCHASED    CHAR(10),
         2 SERVICE_CALLS     PIC '99',
         2 LAST_SERVICE_CALL CHAR(10),
         2 PROD_RECORD_FILL  CHAR(20);
