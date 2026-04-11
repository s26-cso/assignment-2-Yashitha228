#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<dlfcn.h>//linux library for dynamic loading
int main(){
    char op[10];
    int num1,num2;
    //infinite loop that keeps taking input
    while(1){
        //taking input
        if(scanf("%s %d %d",op,&num1,&num2)!=3){
            break;
        }
        //constructing library name
        char libname[50];
        sprintf(libname,"./lib%s.so",op);
        //load the shared library
        void*handle=dlopen(libname,RTLD_LAZY);
        if(!handle){
            printf("Error:Cannot Load %s\n",libname);
            continue;
        }
        //function pointer
        int (*func)(int,int);
        //find the function inside te library
        func=(int(*)(int,int))dlsym(handle,op);
        if(!func){
            printf("Error:Function not found\n",op);
            dlclose(handle);
            continue;
        }
        //calling the function
        int result=func(num1,num2);
        //print result
        printf("%d\n",result);
        //close the library
        dlclose(handle);

    }
    return 0;
}

