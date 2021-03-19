 /****************************************************************
  * LICENSED MATERIALS - PROPERTY OF IBM
  * "RESTRICTED MATERIALS OF IBM"
  * (C) COPYRIGHT IBM CORPORATION 2021. ALL RIGHTS RESERVED
  * US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
  * OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
  * CONTRACT WITH IBM CORPORATION
  ****************************************************************/
   DCL 1 CUSTOMER_BALANCE_STATS,                                        
         2 BALANCE_COUNT     DEC(8),                                    
         2 BALANCE_TOTAL     DEC(12,2),                                 
         2 BALANCE_MIN       DEC(12,2),                                 
         2 BALANCE_MAX       DEC(12,2),                                 
         2 BALANCE_RANGE     DEC(12,2),                                 
         2 BALANCE_AVG       DEC(12,2),                                 
         2 BALANCE_FIRST_TIME_SW     PIC '9';                           