//  Created by Philip Han on 8/10/22.
// https://github.com/gluonhq/substrate/blob/master/src/main/resources/native/ios/dummy.c
//

#import <Foundation/Foundation.h>
#import <stdlib.h>
#import <stdio.h>

typedef struct {
  char fCX8;
  char fCMOV;
  char fFXSR;
  char fHT;
  char fMMX;
  char fAMD3DNOWPREFETCH;
  char fSSE;
  char fSSE2;
  char fSSE3;
  char fSSSE3;
  char fSSE4A;
  char fSSE41;
  char fSSE42;
  char fPOPCNT;
  char fLZCNT;
  char fTSC;
  char fTSCINV;
  char fAVX;
  char fAVX2;
  char fAES;
  char fERMS;
  char fCLMUL;
  char fBMI1;
  char fBMI2;
  char fRTM;
  char fADX;
  char fAVX512F;
  char fAVX512DQ;
  char fAVX512PF;
  char fAVX512ER;
  char fAVX512CD;
  char fAVX512BW;
  char fAVX512VL;
  char fSHA;
  char fFMA;
    
    /*
  char fFP;
  char fASIMD;
  char fEVTSTRM;
  char fAES;
  char fPMULL;
  char fSHA1;
  char fSHA2;
  char fCRC32;
  char fLSE;
  char fSTXRPREFETCH;
  char fA53MAC;
  char fDMBATOMICS; */
} CPUFeatures;

void determineCPUFeatures(CPUFeatures* features)
{
    fprintf(stderr, "\n\n\ndetermineCpuFeaures\n");
    features->fSSE = 1;
    features->fSSE2 = 1;
    /*
    features->fFP = 1;
    features->fASIMD = 1;
     */
}

void Java_java_net_AbstractPlainDatagramSocketImpl_isReusePortAvailable0(void) {}
void JVM_Halt(void) {}
void JVM_FindLibraryEntry(void) {}
void jio_snprintf(void) {}
void systemVersionPlatform(void) {}
void SVM_FindJavaTZmd(void) {}
void operatingSystemVersion(void) {}
void JVM_ActiveProcessorCount(void) {}
void systemVersionPlatformFallback(void) {}
void Java_java_net_DatagramPacket_init(void) {}
void initialize(void) {}
