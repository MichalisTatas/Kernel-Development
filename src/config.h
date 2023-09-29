#ifndef CONFIG_H
#define CONFIG_H

#define KERNEL_CODE_SELECTOR 0X08
#define KERNEL_DATA_SELECTOR 0X10

#define OS_TOTAL_INTERRUPTS 512

// 100 MB instead of figuring out how much ram the user has and adjusting the number 
#define OS_HEAP_SIZE_BYTES 104857600
#define OS_HEAP_BLOCK_SIZE 4096
#define OS_HEAP_ADDRESS    0x01000000
#define OS_HEAP_TABLE_ADDRESS 0x00007E00

#endif