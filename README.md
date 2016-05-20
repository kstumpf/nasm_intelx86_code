NASM, Intel x86 Code
==============

Computes Products Recursively, through Addition

<h3>Installation/Startup</h3>
<p>To compile and run the program, do the following from the command line.
<ul>
<li>nasm -f elf hwX.asm</li>
<li>ld -melf_i386 hwX.o 231Lib.o -o hwX</li>
<li>./hwX</li>
</ul>
</p>


<h3>Description</h3>
<p>
An assembly program called hwX.asm that computes the product of 2 integer numbers recursively, using only additions, as the algorithm below illustrates.
<br /><br />
Algorithm:
<ul>
<li>if a == 0, mult(a, b) = 0</li>
<li>if a == 1, mult(a, b) = b</li>
<li>otherwise mult(a, b) = mult(a-1, b) + b</li>
</ul>
</p>