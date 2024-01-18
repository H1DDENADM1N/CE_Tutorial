format ELF64    ;fasm伪代码
section '.data' ;fasm伪代码

Label_qword:    ;Label（标签）用于指代一个内存地址，当程序被汇编后，汇编器会将标签转换成具体的地址。Label_qword: 依附于它往上最近的一个绝对的内存地址 section '.data' ，等价于 0x403010
    dq 0xAAAAAAAA11111111   ;Declare a Qword=8Bytes （声明一个qword）

Label_byte db 254   ;Byte   标签简写    内存地址：0x403010+8
Lable_word dw 0xCC33    ;Word=2Bytes       内存地址：0x403010+8+1
Lable_dword dd 0xDDDD4444   ;Double Word=4Bytes        内存地址：0x403010+8+1+2


section '.bss'  ;fasm伪代码
    Single_3 dd 3.0
    Single_5 dd 5.5
    Double_6 dq 6.0
    Double_8 dq 8.0

section '.text' executable

public main ;Symbol(符号) 让main成为一个符号（静态内存地址）
main:
    mov rbp, rsp    ;for correct debugging
    
    Number_and_Base:    ;数字与进制
    mov rax, 0x1111111111111111 ;rax 0x1111111111111111
    mov al, 0x22    ;rax 0x1111111111111122
    mov ah, 0x33    ;rax 0x1111111111113322
    mov ax, 0x4444  ;rax 0x1111111111114444
    mov eax, 0x55555555 ;rax 0x0000000055555555 
    mov rax, 0x6666666666666666 ;rax 0x6666666666666666
    mov bl, 0xAA    ;rbx 0xAA
    ;mov rax, bl 会报错，但下面的不会
    movzx rax, bl   ;rax 0xAA
    
    ;位元运算
    mov rax, 1100b  ;=12=0xC
    mov rbx, 1010b  ;=10=0xA
    xor rax, rbx    ;异或加密（相同为零，相异为一） rax 0b0110=6=0x6
    xor rax, rax    ;异或自己，数值清零 rax 0x0
    
    mov rax, 10101100b  ;=172=0xAC
    mov rbx, 01011100b  ;=92=0x5C
    and rax, rbx    ;位与（全真才真，有假就假） rax 0b0001100=12=0xC
    ;or
    ;not
    
    ;其他指令
    xchg rax, [Label_qword] ;Exchange（数值互换） xchg的两个操作对象，可以是寄存器或内存地址,但是,不可以同时是内存地址 寄存器rax 0xaaaaaaaa11111111  内存0x403010 0xC
    mov rax, 0x1111111111111100
    lea rax, [rax+0xFF] ;Load Effective Address（加载有效地址） 将内存地址本身放到寄存器里   rax 0x11111111111111FF
    
    nop ;No Operation（无操作）  占1 Byte，可用于替换原操作码，避免程序出错
    
    Add_Subustract_and_Multiple:
    mov rax, 0x0    ;立即数0x0
    add rax, 0x1    ;rax 0x0000000000000001
    mov rbx, 0xA0
    add rax, rbx    ;rax 0x00000000000000A1
    
    sub rax, 0x1    ;Substract（减法）  rax 0x00000000000000A0
    
    inc rax ;Increment（加一）  rax 0x00000000000000A1
    dec qword [Label_qword] ;Decrement（减一）  内存0x403010 0xB
    
    mov dword [Label_qword], 0x80   ;128
    mov eax, 0x4
    imul eax, dword [Label_qword]   ;Integer Multiply（乘法）   eax 0x200   imul针对有符号整数，但是无符号也可以用；无符号的整数乘法指令是mul    SingedByte：-128~127, UnsingedByte:0~255
    ;imul 三种用法
    ;div / idiv
    
    Push_and_Pop:   ;将要用到的寄存器的数值暂存到堆栈中，避免数值被修改后，有别的操作码用到这些寄存器，导致游戏崩溃
    mov rax, 0x1111111111111111
    mov rbx, 0x2222222222222222
    push rax    ;Push（推入堆栈）   等价于 sub rsp, 8  mov [rsp], rax  8由rax有8个Bytes决定
    push rbx
    ;现在rax跟rbx可以用来做别的东西了，比如：
    mov rax, 0xAA
    mov rbx, 0xBB
    ;现在东西已经做完了,我们要把rax跟rbx的数值还原回去，注意顺序：
    pop rbx ;Pop（冒出堆栈）
    pop rax ;先入后出   等价于 mov rax, [rsp]  add rsp,8   8由rax有8个Bytes决定

    RFLAGS:
    ;第00位，CF，Carry Flag，进位标志
    xor rax, rax    ;清零
    mov al, 0xF0    ;rax 0xF0=240=   11110000b  eflags=[PF ZF IF]
    add al, 0xF0    ;rax 0x1E0=480=1 11100000b  当运算结果发生进位时，CF进位标志会被改为1 eflags=[CF SF IF]
    ;第06位，ZF，Zero Flag，零标志
    mov ax, 0x1111  ;rax 0x1111
    sub al, 0x11    ;rax 0x1100 虽然rax不为0，,但运算结果为0，ZF零标志会被改为1  eflags=[PF ZF IF]
    ;第11位，OF，Overflow Flag，溢出标志
    xor rax, rax    ;rax 0x0
    xor rbx, rbx    ;rbx 0x0
    mov al, 127 ;rax 0x7F
    mov bl, 10  ;rbx 0xA    eflags=[PF ZF IF]
    add al, bl  ;rax 0x89   137>127，无进位，CF=0，运算结果 有符号整数 二进制数字有溢出，OF=1  eflags=[AF SF IF OF]
    
    Jump_Compare_and_Test:  ;跳跃、对比、测试、调用
    jmp Compare_and_Conditional_Jump    ;Jump（无条件跳跃）  jmp改的是rip寄存器
    mov rax, 0xFFFFFFFF ;这条指令被跳过了
    Compare_and_Conditional_Jump:
    mov rax, 0xFF
    mov rbx, 0xFF
    cmp rax,rbx ;Compare（对比）    等价于 push rax  sub rax, rbx  pop rax  当运算结果为0时，ZF零标志会被改为1  eflags=[PF ZF IF]
    je RAX_EQUALS_TWO   ;等价于jz  Jump if Equal  cmp rax,rbx 运算结果为0, ZF=1 将执行跳跃
    mov rax, 1  ;被跳过
    RAX_EQUALS_TWO:
    mov rax, 2
    ;jne / jnz    Jump if Not Equal
    ;jg Jump if Greater Than    ZF=0且SF=OF，rax-rbx>rax
    ;jng ZF=1或SF!=OF,rax-rbx<rax
    
    
    xor rax, rax
    xor rbx, rbx
    mov rax, 1010b  ;rax 0xa
    mov rbx, 0101b  ;rbx 0x5
    test rax, rbx   ;Test（测试）   等价于push rax  and rax, rbx  pop rax  当运算结果为0时，ZF零标志会被改为1  eflags=[PF ZF IF]
    jz Jump_to_Here_If_Test_Zero    ;等价于je  Jump if Equal  test rax, rbx 运算结果为0, ZF=1 将执行跳跃
    mov rax, "Ignored1" ;ASCII  被跳过
    Jump_to_Here_If_Test_Zero:
    call Call_To    ;Call（调用）   一般来说，call 与 ret 会同时使用
    mov rax, "Second"   ;rax 0x646e6f636553
    jmp After_Call_To
    
    Call_To:
    mov rax, "First"    ;被跳过
    ret ;Return（返回） 被跳过

    After_Call_To:
    mov rax, "Third"    ;rax 0x6472696854
    
    ;浮点数字   专用寄存器  x87 FPU, Floating Point Unit x87 Coprocessor
    ;指令后加ss，针对单精度浮点，指令后加sd，针对双精度浮点
    ;寄存器以ymm或xmm开头，类似于rax跟eax
    
    ;单精度浮点的加减乘除：浮点的数值不能固定在操作码中，必须从一个内存地址中读取
    ;movss xmm0, 1.2    会报错
    movss xmm3, dword [Single_3]    ;xmm3 3.0 0x40400000
    movss xmm5, dword [Single_5]    ;xmm5 5.5
    addss xmm3, xmm5    ;xmm3 8.5
    subss xmm3, xmm5    ;xmm3 3.0
    mulss xmm3, xmm5    ;xmm3 16.5
    divss xmm3, xmm5    ;xmm3 3.0
    
    ;双精度浮点的加减乘除
    movsd xmm6, qword [Double_6]    ;6.0
    movsd xmm8, qword [Double_8]    ;8.0
    addsd xmm6, xmm8    ;xmm6 14.0
    subsd xmm6, xmm8    ;xmm6 6.0
    mulsd xmm6, xmm8    ;xmm6 48.0
    divsd xmm6, xmm8    ;xmm6 6.0
    
    ;双精度浮点的对比
    ucomisd xmm6, xmm8  ;单精度浮点的则是 ucomiss  eflags=[CF IF]
    jne Exit_Lable  ;等价于jnz Jump if Not Equal   ucomisd xmm6, xmm8 运算结果为1, ZF=0 将执行跳跃
    mov rax, "Ignored2" ;上面一行ucomisd的结果不等,被跳过
    
    Exit_Lable:
    ret
