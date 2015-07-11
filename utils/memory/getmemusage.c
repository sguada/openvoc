#include <sys/types.h>
#include <unistd.h>
#include "mex.h"
#include "memory.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int* data;
	long vmrss;
	long vmsize;

	if (nrhs > 0)
	{
		mexErrMsgTxt("Too many input arguments.");
	}

	get_memory_usage_kb(&vmrss, &vmsize);
    if (nlhs > 0)
    {
	plhs[0] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
	data = mxGetData(plhs[0]);
	data[0] = vmrss;

	plhs[1] = mxCreateNumericMatrix(1, 1, mxUINT32_CLASS, mxREAL);
	data = mxGetData(plhs[1]);
	data[0] = vmsize;
    } else
    {
     mexPrintf("VM (%dMB,%dMB)\n",vmrss/1000,vmsize/1000);   
    }
    
}
 
