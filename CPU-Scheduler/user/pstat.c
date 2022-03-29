#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/pstat.h"



int 
main(int argc, char *argv[])
{
    struct pstat p = {{0},{0},{0},{0}};
    struct pstat* p1 = &p;
    getpstat(p1);
    if(p.inuse[0]!=0){
        printf("pid  ticks  queue\n");
        printf("%d    ",p.pid[0]);
        printf("%d      ",p.ticks[0]);
        printf("%d\n",p.queue[0]);
    }
    
    exit(0);
}