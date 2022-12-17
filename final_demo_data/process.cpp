#include <holodaye/elevation.h>
#include <holodaye/utils.h>
#include <iostream>

int main(){
    FILE *in_file = fopen("../../../final_demo_data/result_ml.txt", "r");
    if(in_file == NULL){
        printf("Error! Input file not found!\n");   
        exit(1);             
    }
    std::cout << "Input file found" << std::endl;
    FILE *out_file = fopen("../../../final_demo_data/grid.csv", "w");
    std::cout << "Output file 1 found" << std::endl;
    int x[360],y[360];
    double h[360];
    for(int i=0; i<360; i++){
        double N,E;
        LV95 lv95;
        fscanf(in_file,"%lf,%lf,%lf,",&N,&E,h+i);
        lv95 = GPS2LV95(E,N);
        x[i] = lv95.E;
        y[i] = lv95.N;
    }
    std::cout << "Input file read" << std::endl;
    int max_x=INT_MIN, min_x=INT_MAX, max_y=INT_MIN, min_y=INT_MAX;
    for(int i=0; i<360; i++){
        if (x[i]>max_x)
            max_x = x[i];
        else if (x[i]<min_x)
            min_x = x[i];
        if (y[i]>max_y)
            max_y = y[i];
        else if (y[i]<min_y)
            min_y = y[i];
    }
    int diff_x = max_x - min_x;
    int diff_y = max_y - min_y;
    std::cout<<max_x<<" "<<min_x<<" "<<diff_x<<" "<<max_y<<" "<<min_y<<" "<<diff_y<<std::endl;
    int mid_x = (max_x + min_x)/2;
    int mid_y = (max_y + min_y)/2;
    int side_len = std::max(diff_x, diff_y)*8/7;
    int half_side_len = side_len/2;
    int mat_side_len = 500;
    float** grid = new float*[mat_side_len];
    for (int i=0; i<mat_side_len; i++){
        grid[i] = new float[mat_side_len];
    }
    ElevationData data("../../../data/zipped.dat");
    std::cout<< "Data read" << std::endl;
    for (int i=0; i<mat_side_len; i++)
        for (int j=0; j<mat_side_len; j++){
            grid[i][j] = data.get_elevation(mid_x - half_side_len + side_len*i/mat_side_len, mid_y - half_side_len + side_len*j/mat_side_len);
        }
    for(int i=0; i<mat_side_len; i++){
        for(int j=0; j<mat_side_len-1; j++){
            fprintf(out_file, "%lf,",grid[i][j]);
        }
        fprintf(out_file, "%lf\n",grid[i][mat_side_len-1]);
    }
    fclose(out_file);
    out_file = fopen("../../../final_demo_data/peek.csv", "w");
    for(int i=0; i<360; i++){
            fprintf(out_file, "%lf,%lf,%lf\n",
                double(x[i] - mid_x + half_side_len)/side_len*mat_side_len,
                double(y[i] - mid_y + half_side_len)/side_len*mat_side_len,
                h[i]
                );
        }
    for (int i=0; i<mat_side_len; i++){
        delete[] grid[i];
    }
    delete[] grid;
    fclose(out_file);
    fclose(in_file);
    return 0;
}