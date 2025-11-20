.macro DEBUG_PRINT reg
csrw 0x800, \reg
.endm
	
.text
.global div              # Export the symbol 'div' so we can call it from other files
.type div, @function
div:
    addi sp, sp, -32     # Allocate stack space

    # store any callee-saved register you might overwrite
    sw   ra, 28(sp)      # Function calls would overwrite
    sw   s0, 24(sp)      # If t0-t6 is not enough, can use s0-s11 if I save and restore them
    # ...

    # do your work

    beq     a1, zero, div_by_zero

    li      t0, 0 # initialize quotient Q
    li      t1, 0 # initialize remainder R
    li      t2, 31 # loop variable

    loop:
        slli    t1, t1, 1        # left-shift R by 1 bit

        # Set t1[0] = a0[t2]
        srl     t4, a0, t2       # t4 = a0 >> i
        andi    t4, t4, 1        # t4 = bit i of a0 (0 or 1)
        andi    t1, t1, -2       # clear LSB of t1 (mask ...1110)
        or      t1, t1, t4       # write bit into LSB: t1[0] = t4

        bltu     t1, a1, endif
            # if R >= D
            sub     t1, t1, a1   # R := R - D

            # Q(i) := 1
            li      t5, 1
            sll     t5, t5, t2
            or      t0, t0, t5
        endif:

        addi    t2, t2, -1       # i--
        bge     t2, zero, loop   # while i >= 0
    endloop: 

    # copy quotient and remainder to output registers

    mv      a0, t0
    mv      a1, t1
    j       done

    div_by_zero:
        li      a1, 0
        li      a0, 0       # quotient = 0

    done:

        # load every register you stored above
        lw   ra, 28(sp)
        lw   s0, 24(sp)
        # ...
        addi sp, sp, 32      # Free up stack space
        ret

