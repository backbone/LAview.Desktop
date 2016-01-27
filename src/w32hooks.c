#if defined(_WIN32) || defined(_WIN64)
#include <time.h>
struct tm *localtime_r(const time_t *timep, struct tm *result)
{
  localtime_s(result, timep);
  return result;
}
#endif
