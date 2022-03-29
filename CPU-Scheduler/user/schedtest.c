#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int 
main(int argc, char *argv[])
{
    int nsleep = atoi(argv[1]);
    int nwork = atoi(argv[2]);
    if(nsleep>0){
        sleep(nsleep);
    }
    uint64 acc = 0;
    for(uint64 i=0;i<nwork;i++){
        acc += i;
    }
    exit(0);
}