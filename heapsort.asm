;--------------------------;
;      heapsort.asm        ;
;--------------------------;
;                          ;
;   ubuntu 20.04 LTS       ;
;   NASM version 2.14.02   ;
;                          ;
;--------------------------+----------------------------------------------;
; Compile and link with:                                                  ;
;  `nasm -f elf heapsort.asm && ld -m elf_i386 -s -o heapsort heapsort.o` ;
; Run with:                                                               ;
;  `./heapsort`	                                                          ;
;-------------------------------------------------------------------------;

%include 'functions_external.asm'		; printing functions

; macros
%macro print_array 3					; param [array, array_size, beginfrom]
push ecx
push eax
mov  ecx, %3

mov  eax, arrayheader
call sprint

%%loop:
mov  eax, [%1 + 4 * ecx]
alignment eax
call iprint

add  ecx, 1
mov  eax, delimiter
call sprint

cmp  ecx, %2
jne  %%loop

mov  eax, [%1 + 4 * ecx]
alignment eax
call iprint

mov  eax, arrayfooter
call sprintLF

pop  eax
pop  ecx
%endmacro
%macro alignment 1						; add space if less than 10
cmp  %1, 10
jge  %%ge

push eax
mov  eax, space
call sprint
pop  eax

%%ge:
%endmacro
%macro swap 3 							; param [array, i, j]
push eax						; store previous rgxs
push ebx
push ecx
push edx

mov  ecx, %2
mov  edx, %3

mov  eax, [%1 + 4 * ecx]
mov  ebx, [%1 + 4 * edx]

mov  [%1 + 4 * ecx], ebx
mov  [%1 + 4 * edx], eax

pop  edx
pop  ecx
pop  ebx
pop  eax						; rollback rgxs
%endmacro
%macro push_element 3 					; param [array, index, element]
push eax
mov  eax, %3
mov  [%1 + 4 * %2], eax
pop  eax
%endmacro
%macro get_element 2					; param [array, index]
mov  eax, [%1 + 4 * %2]			; store in eax
%endmacro

; defines
%define D_size 9
%define T_size 10

SECTION .data

heapsort	db '**  heapsort.asm  **', 0h
arrayheader db '[', 0h
delimiter   db ', ', 0h
arrayfooter db ']', 0h
space  		db ' ', 0h

D			dd	58, 12, 39, 90, 49, 26, 68, 47, 15, 39
n			dd	10
T  times 11 dd 0
size 		dd 0

i			dd 0
k			dd 0
T_o			dd 0

SECTION .text
global _start

_start:
mov  eax, heapsort					; printing file name
call sprintLF

jmp  entry_point

; param => ( edx x )
push_heap:
mov  eax, [size]
add  eax, 1							; size++
mov  [size], eax

mov  ecx, [size]

push_element T, ecx, edx			; T[size] = x
; k = size => eax

beforeswap:
push eax							; store k
push eax							; for future

get_element T, eax
mov  ecx, eax						; store T[k] at ecx

xor  edx, edx						; setup for division

pop  eax							; get previous k
mov  ebx, 2
div  ebx							; k / 2

mov  ebx, eax						; backup for doswap

get_element T, eax					; store T[k/2] at eax

cmp  ecx, eax						; T[k] > T[k/2]
jg   nexta

jmp  done_push

nexta:
pop  eax							; get previous k
cmp  eax, 1
jg   doswap

jmp  done_push

doswap:
swap T, ebx, eax					; swap([k/2], [k])
mov  eax, ebx						; k = k/2

jmp  beforeswap

entry_point:							; start from here
mov  eax, [i]

push_elements:
mov  edx, [n]
cmp  eax, edx
jl	 do_push

mov  eax, space
call sprintLF

mov  eax, [n]						; setup for delete maximum
mov  [i], eax

delete_maximum:
get_element T, 1
mov  [T_o], eax
mov  ecx, [size]
push ecx
get_element T, ecx
mov  ecx, eax
push_element T, 1, ecx
pop  ecx
push_element T, ecx, 0

mov  eax, [i]
sub  eax, 1
mov  [i], eax
cmp  eax, 0
jge  delete_max_val

jmp  done

do_push:
mov  [i], eax
push eax
get_element D, eax					; get D[i]
mov  edx, eax						; use edx as parameter x

pop  ebx							; i
push_element D, ebx, 0				; D[i] = 0

jmp  push_heap

done_push:
mov  eax, [i]
print_array T, T_size, 1

add  eax, 1

jmp  push_elements

delete_max_val:
mov  ebx, [size]					; size--
sub  ebx, 1
mov  [size], ebx

mov  eax, 1							; k = 1
mov  [k], eax

deleting_while_check:
mov  eax, [k]
shl  eax, 1							; 2 * k

mov  ebx, [size]

cmp  eax, ebx
jle  inside_while

jmp  ending_delete_max				; break while

inside_while:
cmp  eax, ebx
je   ready_to_swap

jmp  else_inside_while				; else

ready_to_swap:							; if ( T[k] < T[2*k] )
get_element T, eax					; get T[2*k]
mov  edx, eax
mov  eax, [k]						; get k
get_element T, eax					; get T[k]

cmp  eax, edx						; compare
jl   doswap_r

mov  [k], eax
jmp  ending_delete_max
doswap_r:
mov  edx, [k]						; reget k
mov  eax, edx
shl  eax, 1							; k * 2
; k = 2 * k
mov  [k], eax
swap T, eax, edx

jmp  deleting_while_check

else_inside_while:
mov  eax, [k]
shl  eax, 1
push eax
push eax
get_element T, eax					; get T[2*k]
mov  ecx, eax

pop  eax
add  eax, 1
mov  edx, eax
get_element T, eax					; get T[2*K+1]

cmp  ecx, eax
jg   eiif

mov  ecx, edx						; ecx -> 2*k+1
pop  edx
xor  edx, edx

jmp  eiifn

eiif:
pop  edx
mov  ecx, edx						; ecx -> 2*k

eiifn:
mov  eax, [k]						; get k
push eax
push ecx							; big
get_element T, eax					; T[k]
mov  edx, eax
get_element T, ecx					; T[big]

cmp  edx, eax
jl   eiifnii

pop  edx
pop  edx							; this will be return value, store in eax
xor  edx, edx
jmp  ending_delete_max				; break while

eiifnii:
pop  ebx
pop  eax

mov  [k], ebx
swap T, eax, ebx

jmp  deleting_while_check

ending_delete_max:						; store k before jmp here
mov  eax, [T_o]
mov  ecx, [i]
push_element D, ecx, eax

print_array D, D_size, 0

jmp  delete_maximum

done:
call quit
