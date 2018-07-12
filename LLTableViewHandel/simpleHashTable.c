//
//  simpleHashTable.c
//  LearnFace
//
//  Created by lcus on 2018/7/9.
//  Copyright © 2018年 lcus. All rights reserved.
//

#include <stdio.h>
#include <string.h>
#include <mm_malloc.h>

#define M_FALSE 0
#define M_TRUE  1

typedef int STATUS;


typedef struct _NODE{
    int data;
    struct _NODE* nest;
    
}NODE;

typedef struct _HASH_TABLE{
    NODE * vlaue[10];
    
}HASH_TABLE;


HASH_TABLE* create_hash_table(){
   
    HASH_TABLE* pHashTbl =(HASH_TABLE*) malloc(sizeof(HASH_TABLE));
    
    memset(pHashTbl, 0, sizeof(HASH_TABLE));
    
    
    return pHashTbl;
    
}

NODE * find_data_inHash(HASH_TABLE*pHashTable,int data){
    
    NODE *pNode;
    if (pHashTable ==NULL) {
        return NULL;
    }
    if ((pNode=pHashTable->vlaue[data%10])==NULL) {
        
        return NULL;
    }
    
    while (pNode) {
        
        if (data == pNode->data) {
            return pNode;
        }
        pNode = pNode->nest;
    }
    
    return pNode;
}

STATUS insert_data_info_hash(HASH_TABLE*pHashTable,int data){
    
    NODE *pNode;
    
    if (pHashTable == NULL) {
        return M_FALSE;
    }
    
    if (pHashTable->vlaue[data%10] == NULL) {
        
        pNode = (NODE*)malloc(sizeof(NODE));
        memset(pNode, 0, sizeof(NODE));
        
        pNode->data = data;
        pHashTable->vlaue[data%10] = pNode;
        
        return M_TRUE;
        
    }
    
    if (find_data_inHash(pHashTable, data)==NULL) {
        
        return M_FALSE;
    }
    
    pNode = pHashTable->vlaue[data%10];
    
    while (pNode->nest!=NULL) {
        pNode= pNode->nest;
    }
    
    pNode->nest = (NODE*)malloc(sizeof(NODE));
    memset(pNode->nest, 0, sizeof(NODE));
    
    pNode->nest->data = data;
    
    return M_TRUE;
}

STATUS delete_data_form_hash(HASH_TABLE *pHashTable,int data){
    
    NODE *pHead;
    NODE *pNode;
    
    if ((pNode = find_data_inHash(pHashTable, data))==NULL) {
        
        return M_FALSE;
    }
    if (pNode == pHashTable->vlaue[data%10]) {
        
        pHashTable->vlaue[data%10] =pNode->nest;
        
        free(pNode);
        
        return M_TRUE;
    }
    
    pHead = pHashTable->vlaue[data%10];
    while (pNode!=pHead->nest) {
        pHead = pHead->nest;
    }
    pHead->nest = pNode->nest;
    
    free(pNode);
    return M_TRUE;
}








