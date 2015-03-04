/*
 * Author: Dan Spier
 * Date: March 1, 2015
 * Description: This program demonstrates the concept of multithreading.
 * Environment: FreeBSD 10.1, clang 3.4.1 
 * Notes: Adapted from "Bored Bankers" problem by Amos Confer.
 */
#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#define SIZE 26
#define WAIT 10000000 

const int TIMES = 100;

//function prototype
void *threadbase(void *letter);

int main(int argc, char *argv[])
{
    //creates array of 26 threads
    pthread_t thread_array[26];

    int i;
    char alph[SIZE];        

    //places A-Z in the array
    for(i=0;i<26;i++)
        alph[i] = 'A' + i;
    //invokes the thread with the "threadbase" start_routine 
    for(i=0;i<26;i++)
        pthread_create(&thread_array[i], NULL, threadbase, &alph[i]);
    //waits for the calling threads to finish before continuing.
    //prevents ending the function too early
    for(i=0;i<26;i++)
        pthread_join(thread_array[i], NULL);

    return EXIT_SUCCESS;
}

//return type and argument are passed void pointers.
//since no data type is assigned, will have to be 
//casted before use.
void* threadbase(void* letter) 
{
    int i;
    //assign the char value pointed to by "letter" to "let"
    char let = *(char *)letter;
    for(i = 0; i < TIMES; i++) 
    {
        printf("%c",let);
        //prints each letter to the screen rather than waiting
        fflush(stdout);
        //waste time to keep the process on the CPU
        for(int j=0;j <WAIT;j++); 
    }
    printf("\n");
    return NULL;
}
