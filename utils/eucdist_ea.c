#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <signal.h>
#include <matrix.h>
#include <mex.h>

#define INF        999999999999.0
#define min(x,y) ((x)<(y)?(x):(y))
#define max(x,y) ((x)>(y)?(x):(y))
#define dist(x,y) ((x-y)*(x-y))


int abandon = 1;

double distance(double *x, double *y, int length , double best_so_far){
    int i;
    double sum = 0, bsf2 = best_so_far*best_so_far;
    
    if( abandon == 1 )
    {
        for ( i = 0 ; i < length && sum < bsf2 ; i++ )
            sum += dist(x[i],y[i]);
        return sqrt(sum);
    }
    else
    {
        for ( i = 0 ; i < length  ; i++ )
            sum += dist(x[i],y[i]);
        return sqrt(sum);
    }

}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
    if(nrhs<2 || nrhs > 3)
        mexErrMsgIdAndTxt( "MATLAB:main:invalidNumInputs", "usage : FILE [A | A V] \n example : input 0 1");
    
    double *input1,*input2, BSF;
    input1 = mxGetPr(prhs[0]);    
    input2 = mxGetPr(prhs[1]);
    if (nrhs > 2)
        BSF = (double) (mxGetPr(prhs[2]))[0];
    else
        BSF = INF;
    
    /* assuming inputs contains horizontal data */
    long LENGTH1,LENGTH2;    
    LENGTH1 = max(mxGetN(prhs[0]),mxGetM(prhs[0]));
    LENGTH2 = max(mxGetN(prhs[1]),mxGetM(prhs[1]));
    if (LENGTH1 != LENGTH2)
         mexErrMsgIdAndTxt("MATLAB:main:invalidNumInputs","Inputs should have the same length");
    double *outputP;
    double dist = distance(input1,input2,LENGTH1,BSF);
    if(nlhs==1){
        plhs[0] = mxCreateDoubleMatrix( 1, 1, mxREAL);
        outputP = mxGetPr(plhs[0]);
        outputP[0] = dist;
    } else
        printf("Distance = %f\n",dist);
}