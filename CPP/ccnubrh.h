//
// Sample Program: Biorhythm
// Description   : Calculates biorhythm based on the current
//                 system date and birth date entered
//
// File 1 of 2-other file is CCNUBRC
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
    int DaysOld() { return(DaysSince(text)); }

  private:
    char text[Date::dateLen+1];
};

class BioRhythm {
  public:
    BioRhythm(char *birthText) : birthDate(birthText) {
      age = birthDate.DaysOld();
    }
    BioRhythm() : birthDate() {
      age = birthDate.DaysOld();
    }
    ~BioRhythm() {}

    int AgeInDays() {
      return(age);
    }
    double Physical()  {
      return(Cycle(pCycle));
    }
    double Emotional() {
      return(Cycle(eCycle));
    }
    double Intellectual() {
      return(Cycle(iCycle));
    }
    int ok() {
      return(age >= 0);
    }

  private:
    int age;
    double Cycle(int phase) {
      return(sin(fmod((double)age, (double)phase) / phase * M_2PI));
    }
    BirthDate birthDate;
    static const int pCycle=23;     // Physical cycle - 23 days
    static const int eCycle=28;     // Emotional cycle - 28 days
    static const int iCycle=33;     // Intellectual cycle - 33 days
};