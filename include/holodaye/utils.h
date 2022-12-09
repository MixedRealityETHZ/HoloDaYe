// Convert LV95 format to GPS format
void LV952GPS(float E, float N, float H, float& lon_, float& lat_, float& alt_);
// Convert GPS format to LV95 format
void GPS2LV95(float lon, float lat, float alt, int& E, int& N, float& H);
