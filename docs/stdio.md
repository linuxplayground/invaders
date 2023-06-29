# STDIO API Documentation

## getk

```
;===============================================================================
; CP/M Get Key press
; INPUT: void
; OUTPUT: ascii of pressed key in A
; CLOBBERS: BC, DE
;===============================================================================
```


## puts

```
;===============================================================================
; CP/M Write char
; INPUT: ascii value to write in A
; OUTPUT: void
; CLOBBERS: BC, DE
;===============================================================================
```

## f_make

```
;===============================================================================
; Create a new file, set the CR bit of the FCB to zero so that read or writes
; continue from the beginning of the file.  Deletes any existing file of the
; same name.  Changes to specified user area and sets the disk number provided
; in B.
; XXX No error handling.
; INPUT: HL = pointer to filename
;        B  = uuuudddd uuuu=user area; dddd=disk
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
```

## f_open

```
;===============================================================================
; Open an existing file.  Sets up FCB with details of file.
; INPUT: HL = pointer to filename.
;        B  = uuuudddd uuuu=user area; dddd=disk
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
```

## f_close

```
;===============================================================================
; Close an alrady open file using the previously set FCB.
; INPUT: void
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
```

## f_write

```
;===============================================================================
; Write a buffer to the already open file.  Copies data in 128 byte chunks from
; data pointed to by HL.  It does this via an internal 128byte buffer that's
; always initialised to zero.  It inserts a CTRL+Z char at the end of the file.
; INPUT: HL = pointer to data buffer to write.
;        BC = length of buffer
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
```

## f_read

```
;===============================================================================
; Read DE number of bytes from a file into a file into buffer pointed to by HL
; INPUT: HL = pointer to data buffer to read into.
;        BC = length of data to read. Should be <= sizeofbuffer
; OUTPUT: void
; CLOBBERS: AF, BC, DE, HL
;===============================================================================
```
