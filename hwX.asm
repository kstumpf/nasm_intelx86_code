;;; ;  hwX.asm
;;; ;  Kaitlyn Stumpf
;;; ;  12/8/2015
;;; ;  CSCXXX, Fall 2015
;;; ;
;;; ; ; ---------------------------------------------------------
;;; ; ;  ASSEMBLE AND RUN AS FOLLOWS
;;; ; ; ---------------------------------------------------------
;;; ;  nasm -f elf hwX.asm
;;; ;  ld -melf_i386 hwX.o 231Lib.o -o hwX
;;; ;  ./hwX
;;; ;
;;; ; ; ---------------------------------------------------------
;;; ; ;  PROGRAM FUNCTIONALITY
;;; ; ; ---------------------------------------------------------
;;; ;  An assembly program called hwX.asm that computes the product of 2 integer
;;; ;  numbers recursively, using only additions, as the algorithm below illustrates.
;;; ;     Algorithm:
;;; ;           if a == 0, mult(a, b) = 0
;;; ;           if a == 1, mult(a, b) = b
;;; ;           otherwise mult(a, b) = mult(a-1, b) + b
;;; ;
;;; ; ; ---------------------------------------------------------
;;; ; ;  QUESTION AND ANSWER PORTION
;;; ; ; ---------------------------------------------------------
;;; ;  QUESTION 1:
;;; ;  In the header of the program, indicate how much stack space
;;; ;  will be used as a function of a and b. Express your answer in bytes.
;;; ;
;;; ;  ANSWER 1:
;;; ;	    To compute the stack space used by my entire program,
;;; ;	I recorded the total number of pushes (each of which constitutes 4 bytes)
;;; ; 	to the stack made my the entirety of my program.
;;; ;	    No matter the outcome of the multiplication, _start completes 3 pushes.
;;; ;	    If a = 0, only one more push is made.
;;; ;	    If, however, a > 0, we must calculate how many pushes are made by each
;;; ;   base case check and recursive step run by the program. We calculate how many
;;; ;	pushes are made by mult and multiply this total by a. Then we calculate the
;;; ;   # of calls to recurse and multiply this total by a - 1 (the last call to mult
;;; ;   will not need to recurse because a will equal 1 (our base case is met). Thus,
;;; ;	recurse runs a - 1 times).
;;; ;	    In my case, mult pushes to the stack once (ebp) and recurse pushes 6 times.
;;; ;  	Therefore, if a = 0 the program uses (3 + 1)*4 = 16 bytes.
;;; ;   If, however, a > 0, the program uses (3 + 6(a - 1) + a)*4 = 28a - 12 bytes.
;;; ;
;;; ;
;;; ;  QUESTION 2:
;;; ;	In the header of the program, indicate as well, how much faster or
;;; ;   slower the recursive method implemented by your function is, relative to:
;;; ;     a) The mul instruction:
;;; ;     b) A A for-loop that would accumulate the product of a and b by adding a to
;;; ;        some sum variable, b times, or by adding b to some sum variable a times.
;;; ;
;;; ;  ANSWER 2:
;;; ;  NOTE: Print statements & other things unnecessary to the algorithm were not counted.
;;; ;
;;; ;     To compare the speed of my program to a) & b), I will first calculate the speed
;;; ;  of my program itself. Assuming each instruction takes 1 cycle & a=0, my program runs
;;; ;  5 instructions once, 0 instructions a times, and 0 instructions a - 1 times
;;; ;  for a total of 5 instructions.
;;; ;	 If a > 0, my program runs 9 instructions once (all of _start, ins in mult after recurse call),
;;; ;  4 instructions a times (ins in mult before recurse call),
;;; ;  and 20 instructions a - 1 times (full recurse func),
;;; ;  for a total of 9 + 4a + 20(a-1) = 24a - 11 instructions.
;;; ;
;;; ;	  a) The mul instruction clearly takes one cycle.
;;; ;  If the best case scenario (a = 0) is met for my program, then mul
;;; ;  is 5/1 = 5 times faster. Otherwise, the mul instruction is 24a - 11 times faster.
;;; ;
;;; ;     b) A for-loop that would accumulate the product of a and b by adding a to some
;;; ;  sum variable, b times, or by adding b to some sum variable a times would have a
;;; ;  total of 2a + 2 instructions (or 2 ins if a=0). If the best case (a = 0) happens,
;;; ;  then the for-loop would be 5/2 = 2.5 times faster.
;;; ;  Otherwise, the for-loop is (24a - 11)/(2a + 2) times faster.
;;; ;         ex)
;;; ;            product: mov	ecx, a ; loop a times
;;; ;            	  mov	eax, 0 ; store sum in eax
;;; ;		 for:	  add	eax, dword[b]
;;; ;			  loop	for

	extern	_printDec
	extern	_printString
	extern	_println
	extern	_getInput
	extern	_printRegs
;;; ; ; ---------------------------------------------------------
;;; ; ;  DATA SECTION
;;; ; ; ---------------------------------------------------------
			section .data
		a		dd      0
		b		dd	0
		inputPrompt	dw	"> "
		MSGLEN		equ	$ - inputPrompt

;;; ; ; ---------------------------------------------------------
;;; ; ;  CODE SECTION
;;; ; ; ---------------------------------------------------------
			section .text
	                global  _start
;;; ; ; ---------------------------------------------------------
;;; ; ; _start: Gets two int values from user, and then
;;; ; ; 	computes the product of these 2 ints recursively
;;; ; ;		by calling mult.
;;; ; ;		Returns the end product.
;;; ; ; ---------------------------------------------------------
_start:
;;; ; Start by asking user for two values, storing in global vars a & b.
			mov	ecx, inputPrompt
			mov	edx, MSGLEN
			call	_printString
			call	_getInput
			mov	dword[a], eax ; put first int in a

			mov	ecx, inputPrompt
			mov	edx, MSGLEN
			call	_printString
			call	_getInput
			mov	dword[b], eax ; put second int in b
			call	_println      ; print line to separate input from output

;;; ; First, check if a==0. If this is the case, we needn't enter recursive func.
;;; ; Simply need to print zero and end.
                        cmp     dword[a], 0 ; cmp a to 0
                        je      equaltozero      ; if a == 0, ret 0

;;; ; Push eax to make room for ret val.
;;; ; Push a & b to stack as parameters.
;;; ; Call mult to begin recursion.
			push 	eax
			push	dword[a]
			push	dword[b]

			call	mult

;;; ; Pop end result into eax and call _printDec.
			pop	ebx ; get a out of the way
			pop	eax ; put final ret val here

			call	_printDec
			call	_println
exit:
			mov	ebx, 0
			mov	eax, 1
			int	0x80



;;; ; ; ---------------------------------------------------------
;;; ; ; mult:        computes the product of 2 int #s recursively
;;; ; ;		     using only additon.
;;; ; ;	Algorithm:
;;; ; ;		if a == 0, mult(a, b) = 0
;;; ; ;		if a == 1, mult(a, b) = b
;;; ; ;		otherwise mult(a, b) = mult(a-1, b) + b
;;; ; ;
;;; ; ;              +--------------+
;;; ; ;              |(place for n!)| ebp+16
;;; ; ;              +--------------+
;;; ; ;              +--------------+
;;; ; ;              |       a      | ebp+12
;;; ; ;              +--------------+
;;; ; ;              |       b      | ebp+8
;;; ; ;              +--------------+
;;; ; ;              | ret addr. *  | ebp+4
;;; ; ;              +--------------+
;;; ; ;              |    old ebp   |<-- esp <-- ebp
;;; ; ;              +--------------+
;;; ; ;
;;; ; ; ---------------------------------------------------------
mult:
			push	ebp ; save old ebp for when we're clearing stack.
			mov	ebp, esp ; save esp in ebp for referencing param.

;;; ; Check if a==1. If not, recurse.
;;; PRINT TEST BEFORE BASE CASE COMP OF A TO 1
;;; 			pushad
;;;                     mov     eax, dword[ebp+12]
;;; 			call	_printDec
;;; 			call	_println
;;; 			popad

			cmp	dword[ebp+12], 1
 			jne	recurse
;;; ; If a == 1, continue through mult.
;;; PRINT TEST IF A == 1
;;; 			pushad
;;; 			call	_printDec
;;; 			call	_println
;;; 			popad

 			pop	ebp
			ret	4 ; used to be 8
recurse:
			push	eax
			push	ebx
			push	ecx
;;; PRINT TEST WITHIN RECURSION
;;; 			pushad
;;; 			call	_printDec
;;; 			call	_println
;;; 			popad

			mov	eax, dword[ebp+12] ; eax gets a
			mov	ebx, dword[ebp+8]  ; ebx <-- b
			dec	eax		   ; eax <-- a - 1
;;; PRINT A AFTER DECREMENTATION
;;; 			pushad
;;; 			call	_printDec
;;; 			call	_println
;;; 			popad

			push	ebx ; push space for ret val
			push	eax ; push a = a - 1
			push	ebx ; to keep ebp spacing constant for each call to mult
			call	mult

			pop	eax ; pop a into ebx
 			pop	ecx ; pop ret val into ecx

 			mov	eax, dword[b] ; time to add b to mult(a-1, b)
			add	eax, ecx	  ; eax <-- mult(a-1, b)
			mov	dword[ebp+16], eax ; move (a - 1)*b into ret val area

;;; PRINT TEST AFTER ADDITION OF EBX & ECX
;;; 			pushad
;;; 			call	_printDec
;;; 			call	_println
;;; 			popad

			pop	ecx
			pop	ebx
			pop	eax

			pop	ebp
			ret	4	  ; pop b


;;; ; ; ; ;------------------------------------------------------
;;; ; ; ; ; Print the value zero.
;;; ; ; ; ;------------------------------------------------------
equaltozero:
			push	eax
			mov	eax, 0
			call    _printDec
			call	_println
			pop	eax
;;; That's all to do, so we exit everything afterwards.
			mov     ebx, 0
			mov     eax, 1
			int     0x80
