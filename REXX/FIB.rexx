/**REXX*************************************************************************
* Licensed Materials - Property of IBM
* (C) Copyright IBM Corporation 2022. All Rights Reserved.
*
* Note to U.S. Government Users Restricted Rights:
* Use, duplication or disclosure restricted by GSA ADP Schedule
* Contract with IBM Corp.
********************************************************************************
* Fibonacci algorithm
*
* f[0] = 0
* f[1] = 1
* f[n] = f[n - 1] + f[n - 2] where 2 <= n <= infinity
*
* The following implementation uses a compound symbol to act an array, which
* contains the fibonacci sequence until a provided index.
*******************************************************************************/

fibonacci(6)

/*******************************************************************************
* Prints the fibonacci sequence up to a provided index to the output stream.
*******************************************************************************/
fibonacci:
    arg n
    say "Fibonacci sequence up to" n
    say format_fib(0, 0)
    say format_fib(1, 1)
    fibonacci.0 = 0
    fibonacci.1 = 1
    do i = 2 to n by 1
        j = i - 1
        k = i - 2
        fibonacci.i = fibonacci.j + fibonacci.k
        say format_fib(i, fibonacci.i)
    end
    exit

/*%INCLUDE FIBFORM */
