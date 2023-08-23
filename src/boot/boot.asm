ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

 times 33 db 0

start:
    jmp 0:step2

step2:
    cli ; clear interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; enables interrupts

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32


gdt_start:
gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0
    db 0
    db 0x9a
    db 11001111b
    db 0

gdt_data:
    dw 0xffff
    dw 0
    db 0
    db 0x92
    db 11001111b
    db 0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start

[BITS 32]
load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000
    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax ; backup for lba
    ; send highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or eax, 0xE0 ; select the master drive
    mov dx, 0x1F6
    out dx, al
    ; finished sending the highest 8 bits of the lba

    ;send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; finished sending the total sectors to read

    ; send more bit of the lba
    mov eax, ebx
    mov dx, 0x1F3
    out dx, al
    ; finished sending more bits of the lba

    ; send more bit of the lba
    mov dx, 0x1F4
    mov eax, ebx
    shr eax, 8
    out dx, al
    ; finished sending more bits of the lba

    ; send upper 16 bits of the lba
    mov dx, 0x1F5
    mov eax, ebx
    shr eax, 16
    out dx, al
    ; finished

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; read all sectors in memory 
.next_sector:
    push ecx

; checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, 8
    jz .try_again

; we nead to read 256 words at a time which is 512 bytes / one sector
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; end of reading sectors to memory
    ret

times 510-($ - $$) db 0
dw 0xAA55