//
// Sample Program: Biorhythm
// Description   : Calculates biorhythm based on the current
//                 system date and birth date entered
//
// File 2 of 2-other file is CCNUBRH
//
// LICENSED MATERIALS - PROPERTY OF IBM
// "RESTRICTED MATERIALS OF IBM"
// (C) COPYRIGHT IBM CORPORATION 2022. ALL RIGHTS RESERVED
// US GOVERNMENT USERS RESTRICTED RIGHTS - USE, DUPLICATION,
// OR DISCLOSURE RESTRICTED BY GSA ADP SCHEDULE
// CONTRACT WITH IBM CORPORATION
//
// This example is taken from
// https://www.ibm.com/docs/en/zos/3.2.0?topic=guide-zos-xl-c-examples

#include <iomanip>
#include <iostream>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "ccnubrh.h" //BioRhythm class and Date class
using namespace std;
static ostream &operator<<(ostream &, BioRhythm &);

int main(int argc, char *argv[]) {
  int code;

  if (argc > 1) {
    // Birthdate supplied as command line argument (yyyy/mm/dd)
    BioRhythm bio(argv[1]);
    if (!bio.ok()) {
      cerr << "Error in birthdate specification - format is yyyy/mm/dd\n";
      code = 8;
    } else {
      cout << bio;
      code = 0;
    }
  } else {
    // No argument provided - prompt the user interactively
    BioRhythm bio;
    if (!bio.ok()) {
      cerr << "Error in birthdate specification - format is yyyy/mm/dd\n";
      code = 8;
    } else {
      cout << bio;
      code = 0;
    }
  }
  return (code);
}

const int Date::dateLen;
const int Date::numMonths;
const int Date::numDays[Date::numMonths] = {31, 28, 31, 30, 31, 30,
                                            31, 31, 30, 31, 30, 31};

const int BioRhythm::pCycle;
const int BioRhythm::eCycle;
const int BioRhythm::iCycle;

ostream &operator<<(ostream &os, BioRhythm &bio) {
  os << "Total Days  : " << bio.AgeInDays() << "\n";
  os << "Physical    : " << bio.Physical() << "\n";
  os << "Emotional   : " << bio.Emotional() << "\n";
  os << "Intellectual: " << bio.Intellectual() << "\n";

  return (os);
}
Date::Date() {
  time_t lTime;
  struct tm *newTime;

  time(&lTime);
  newTime = localtime(&lTime);
  cout << "local time is " << asctime(newTime) << endl;

  curYear = newTime->tm_year + 1900;
  curDay = newTime->tm_yday + 1;
}

BirthDate::BirthDate(const char *birthText) { strcpy(text, birthText); }

BirthDate::BirthDate() {
  cout << "Please enter your birthdate in the form yyyy/mm/dd\n";
  cin >> setw(dateLen + 1) >> text;
}

int Date::DaysSince(const char *text) {

  int year, month, day, totDays;
  char delim;
  int daysInYear = 0;
  int i;
  int leap = 0;

  int rc = sscanf(text, "%4d%c%2d%c%2d", &year, &delim, &month, &delim, &day);
  --month;
  if (rc != 5 || year < 0 || year > 9999 || month < 0 || month > 11 ||
      day < 1 || day > 31 || (day > numDays[month] && month != 1)) {
    return (-1);
  }

  if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0)
    leap = 1;

  if (month == 1 && day > numDays[month]) {
    if (day > 29)
      return (-1);
    else if (!leap)
      return (-1);
  }

  for (i = 0; i < month; ++i) {
    daysInYear += numDays[i];
  }
  daysInYear += day;

  // correct for leap year
  if (leap == 1 && (month > 1 || (month == 1 && day == 29)))
    ++daysInYear;

  totDays = (curDay - daysInYear) + (curYear - year) * 365;

  // now, correct for leap year
  for (i = year + 1; i < curYear; ++i) {
    if ((i % 4 == 0 && i % 100 != 0) || i % 400 == 0) {
      ++totDays;
    }
  }
  return (totDays);
}