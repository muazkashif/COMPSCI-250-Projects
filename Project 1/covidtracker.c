#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

typedef struct infection {
    char infector[30];
    char infected1[30];
    char infected2[30];
    int numberInfected;
    struct infection* next;
} Infection;

void sortList(Infection* head, Infection* tail);
void printInfections(Infection* head);

int main(int argc, char *argv[]) {

    Infection* head = NULL;
    Infection* tail = NULL;
    char str[60] = "";
    char Infector[30] = "";
    char Infectee[30] = "";
    int num = 0;
    Infection* ptr = NULL;
    bool InfectorExists = false;
    FILE *fp = fopen(argv[1], "r");

    if(fp == NULL) {
        perror("Error opening file");
        return(-1); 
     }
    // get user input
    while (strcmp(fgets(str, 60, fp), "DONE\n") != 0) {

        char* ptrToNewLine = strchr(str, '\n');
        if (ptrToNewLine) {
            *ptrToNewLine = 0;
        }
        strcpy(Infectee, strtok(str, " "));
        strcpy(Infector, strtok(NULL, " "));

        // store data in the Infection list
        if (head == NULL) {

        Infection* temp_node = (Infection*)malloc(sizeof(Infection));
        strcpy(temp_node -> infector, Infector);
        strcpy(temp_node -> infected1, Infectee);
        strcpy(temp_node -> infected2, "");
        temp_node -> numberInfected = 1;
        temp_node -> next = NULL;
        head = temp_node;
        tail = temp_node;

        Infection* temp_node2 = (Infection*)malloc(sizeof(Infection));
        strcpy(temp_node2 -> infector, Infectee);
        strcpy(temp_node2 -> infected1, "");
        strcpy(temp_node2 -> infected2, "");
        temp_node2 -> numberInfected = 0;
        temp_node2 -> next = NULL;
        tail -> next = temp_node2;
        tail = tail -> next;

        }
        else {
            Infection* temp_node3 = (Infection*)malloc(sizeof(Infection));
            strcpy(temp_node3 -> infector, Infectee);
            strcpy(temp_node3 -> infected1, "");
            strcpy(temp_node3 -> infected2, "");
            temp_node3 -> numberInfected = 0;
            temp_node3 -> next = NULL;
            tail -> next = temp_node3;
            tail = tail -> next;

            InfectorExists = false;
            //InfecteeExists = false;
            ptr = head;
            while(ptr != NULL) {
                if (strcmp(ptr -> infector, Infector) == 0) {
                    InfectorExists = true;
                    num = ptr -> numberInfected;
                    if (num == 0) {
                        strcpy(ptr -> infected1, Infectee);
                    }
                    if (num == 1) {
                        strcpy(ptr -> infected2, Infectee);
                    }
                    ptr -> numberInfected = num + 1;
                }
                /*if (strcmp(ptr -> infector, Infectee) == 0) { 
                    InfecteeExists = true;
                }*/
                ptr = ptr -> next;
            }
            if (!InfectorExists) {
                Infection* temp_node4 = (Infection*)malloc(sizeof(Infection));
                strcpy(temp_node4 -> infector, Infector);
                strcpy(temp_node4 -> infected1, Infectee);
                strcpy(temp_node4 -> infected2, "");
                temp_node4 -> next = NULL;
                temp_node4 -> numberInfected = 1;
                tail -> next = temp_node4;
                tail = tail -> next;
            }
        }
    }
    // sort list of players
    sortList(head, tail);

    // print out the sorted list
    printInfections(head);

    // now free players
    while (head != NULL) {
        ptr = head;
        head = head -> next;
        free(ptr);
    }
    fclose(fp);
    return 0;
}
void sortList(Infection* head, Infection* tail) {
    char temp_name[30];
    char temp_infected1[30];
    char temp_infected2[30];
    int temp_number;
    // bubble sort

    // Approach: each iteration, set the element at the tail
    while (head != tail) {
        Infection* prev = NULL;
        Infection* temp = head;

        while (temp != tail) {
            if (strcmp(temp -> infector, temp -> next -> infector) > 0) {

                strcpy(temp_name, temp -> infector);
                strcpy(temp -> infector, temp -> next -> infector);
                strcpy(temp -> next -> infector, temp_name);

                strcpy(temp_infected1, temp -> infected1);
                strcpy(temp -> infected1, temp -> next -> infected1);
                strcpy(temp -> next -> infected1, temp_infected1);

                strcpy(temp_infected2, temp -> infected2);
                strcpy(temp -> infected2, temp -> next -> infected2);
                strcpy(temp -> next -> infected2, temp_infected2);

                temp_number = temp -> numberInfected;
                temp -> numberInfected = temp -> next -> numberInfected;
                temp -> next -> numberInfected = temp_number;
            }
            prev = temp;
            temp = temp -> next;
            }
            tail = prev;
        }
    }

void printInfections(Infection* head) {
    while (head != NULL) {
        if (head -> numberInfected == 0) {
            printf("%s\n", head -> infector);
        }
        else if (head -> numberInfected == 1) {
            printf("%s %s\n", head -> infector, head -> infected1);
        }
        else {
            if (strcmp(head -> infected1, head -> infected2) > 0) {
                printf("%s %s %s\n", head -> infector, head -> infected2, head -> infected1);
            }
            else {
                printf("%s %s %s\n", head -> infector, head -> infected1, head -> infected2);
            }
        }
        head = head -> next;
    }
}