//
// Sample Program: Biorhythm
// Description   : Calculates biorhythm based on the current
//                 system date and birth date entered
//
// File 1 of 2-other file is CCNUBRC
//
// LICENSED MATERIALS - PROPERTY OF IBM
// "RESTRICTED MATERIALS OF IBM"
// (C) COPYRIGHT IBM CORPORATION 2022, 2026. ALL RIGHTS RESERVED
// US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
// OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
// CONTRACT WITH IBM CORPORATION
//
// This example is taken from
// https://www.ibm.com/docs/en/zos/3.2.0?topic=guide-zos-xl-c-examples

class Date {
public:
  Date();
  int DaysSince(const char *date);

protected:
  int curYear, curDay;
  static const int dateLen = 10;
  static const int numMonths = 12;
  static const int numDays[];
};

class BirthDate : public Date {
public:
  BirthDate();
  BirthDate(const char *birthText);
  int DaysOld() { return (DaysSince(text)); }

private:
  char text[Date::dateLen + 1];
};