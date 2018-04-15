;
; 3-bit stream decoder, optimized for 68000
;
; These routines will decode a stream of 3-bit entries into 16-bit word entries using a user-provided lookup table.
; The stream can be decoded incrementally.
;
; When decoding long runs, the performance will tend toward about 24c/entry on 68000.


		include	"DecodeBitStream_3Bits.i"

		section	code,code

;-------------------------------------------------------------------------------------
; Setup 3-bit decoder
;
; Provide eight values. These are the values which each 3-bit entry in the stream will
;   be decoded into. This function builds the lookup tables that are used for quick translation.
;
; in:
;	a0	DecodeBitStream_3Bits_Lookup*	lookup
;	a1	uint16_t[8]			bit-to-word translation table

		XDEF	DecodeBitStream_3Bits_Words_CreateLookup

DecodeBitStream_3Bits_Words_CreateLookup

		movem.l	d2-d4/a2,-(sp)

		; Generate A: a2a1a0******----
		
		lea	DecodeBitStream_3Bits_Lookup_AB(a0),a2
		move.w	#(1<<3)-1,d0
.genA	
		move.w	(a1)+,d1
CNTR	SET	0
		REPT	(1<<3)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<3)*4,a2
		dbf	d0,.genA
		sub.w	#(1<<3)*2,a1

		; Generate B: ******b2b1b0----
	
		lea	DecodeBitStream_3Bits_Lookup_AB+2(a0),a2
		move.w	#(1<<3)-1,d0
.genB
CNTR	SET	0
		REPT	(1<<3)
		move.w	(a1)+,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		sub.w	#(1<<3)*2,a1
		add.w	#(1<<3)*4,a2
		dbf	d0,.genB

		; Generate C: c2c1c0--

		lea	DecodeBitStream_3Bits_Lookup_C(a0),a2
		REPT	(1<<3)/2
		move.l	(a1)+,(a2)+
		ENDR
		sub.w	#(1<<3)*2,a1
	
		; Generate D: d2d1d0******----
		
		lea	DecodeBitStream_3Bits_Lookup_DE(a0),a2
		move.w	#(1<<3)-1,d0
.genD	
		move.w	(a1)+,d1
CNTR	SET	0
		REPT	(1<<3)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<3)*4,a2
		dbf	d0,.genD
		sub.w	#(1<<3)*2,a1

		; Generate E: ******e2e1e0----
	
		lea	DecodeBitStream_3Bits_Lookup_DE+2(a0),a2
		move.w	#(1<<3)-1,d0
.genE
CNTR	SET	0
		REPT	(1<<3)
		move.w	(a1)+,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		sub.w	#(1<<3)*2,a1
		add.w	#(1<<3)*4,a2
		dbf	d0,.genE

		; Generate F: f1f0************f2--

		lea	DecodeBitStream_3Bits_Lookup_F(a0),a2
		move.w	#(1<<2)-1,d0
.genFOuter
		swap	d0
		move.w	(a1),d1
		move.w	(1<<2)*2(a1),d2
		move.w	#(1<<6)-1,d0
.genFInner
		move.w	d1,(a2)+
		move.w	d2,(a2)+
		dbf	d0,.genFInner
		addq.w	#2,a1
		swap	d0
		dbf	d0,.genFOuter
		subq.w	#(1<<2)*2,a1

		; Generate G: ****g2g1g0******----

		lea	DecodeBitStream_3Bits_Lookup_GH(a0),a2
		moveq	#(1<<2)-1,d0
.genGOuter
		swap	d0
		move.w	#(1<<3)-1,d0
.genGInner
		move.w	(a1)+,d1

CNTR	SET	0
		REPT	(1<<3)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<3)*4,a2
		dbf	d0,.genGInner
		sub.w	#(1<<3)*2,a1
		swap	d0
		dbf	d0,.genGOuter

		; Generate H: **********h2h1h0---

		lea	DecodeBitStream_3Bits_Lookup_GH+2(a0),a2
		move.w	#(1<<5)-1,d0
.genH
CNTR	SET	0
		REPT	(1<<3)
		move.w	(a1)+,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		sub.w	#(1<<3)*2,a1
		add.w	#(1<<3)*4,a2
		dbf	d0,.genH

		movem.l	(sp)+,d2-d4/a2

		rts

;-------------------------------------------------------------------------------------
; Setup 3-bit decoder
;
; in:
;	a0	DecodeBitStream_3Bits_State*	decoder state
;	a1	uint8*				input stream
;	a2	DecodeBitStream_3Bits_Lookup*	lookup tables

		XDEF	DecodeBitStream_3Bits_Words_InitState

DecodeBitStream_3Bits_Words_InitState
		move.l	a1,DecodeBitStream_3Bits_ReadPtr(a0)
		move.l	a2,DecodeBitStream_3Bits_Lookup(a0)
		clr.w	DecodeBitStream_3Bits_Decoded8Entries_NumRemaining(a0)
		rts

;-------------------------------------------------------------------------------------
; Decode 3-bit data stream to words
;
; in:
;	d0.w	uint16_t			number of 3-bit entries to decode
;	a0	DecodeBitStream_3Bits_State*	decoder state
;	a1	uint16_t*			output buffer write ptr
; out:
;	a1	uint16_t*			output buffer write ptr after writes

		XDEF	DecodeBitStream_3Bits_Words_Decode

DecodeBitStream_3Bits_Words_Decode

		movem.l	d2/a2,-(sp)

		move.w	DecodeBitStream_3Bits_Decoded8Entries_NumRemaining(a0),d1
		beq.s	.nCopyLeadingEntries

		lea	DecodeBitStream_3Bits_Decoded8Entries_Buf+8*2(a0),a2
		sub.w	d1,a2
		sub.w	d1,a2

		; copy a portion of previously-decoded buffer contents to output buffer,
		;   up until the next even 8-entry group

		move.w	d1,d2
		cmp.w	d0,d2
		bls.s	.nClamp
		move.w	d0,d2
.nClamp
		sub.w	d2,d0

		sub.w	d2,d1
		move.w	d1,DecodeBitStream_3Bits_Decoded8Entries_NumRemaining(a0)

		neg.w	d2
		add.w	d2,d2
		jmp	.copyLeadingEntriesEnd(pc,d2.w)
.copyLeadingEntries
		REPT	7
		move.w	(a2)+,(a1)+
		ENDR
.copyLeadingEntriesEnd
		
		
.nCopyLeadingEntries

		tst.w	d0
		beq	.decodeDoneWithoutStreamReads

		moveq	#-4,d1
		moveq	#0,d2
		
DECODE8		MACRO	fc_mask,temp0_cleared_upperbytes,temp1,temp2

		; fc_mask - contains $fc in lowest bytes
		; temp0_cleared_upperbytes - contains $000000 in top 3 bytes

		; Read 3 bytes, output 8 entries

		; a2    - input stream
		; a3+16 - lookup table for     a2a1a0b2b1b0---- -> word with a, word with b
		; a3    - lookup table for             c2c1c0-- -> word with c
		; a4    - lookup table for     d2d1d0e2e1e0---- -> word with d, word with e
		; a5    - lookup table for f1f0g2g1g0h2h1h0f2-- -> word with f
		; a6    - lookup table for f1f0g2g1g0h2h1h0---- -> word with g, word with h

		moveq	#0,\3
		move.b	(a2)+,\3		; Fetch %a2a1a0b2b1b0c2c1
		move.l	\3,\4
		and.b	\1,\3			; %a2a1a0b2b1b0----
		move.l	DecodeBitStream_3Bits_Lookup_AB-DecodeBitStream_3Bits_Lookup_C(a3,\3.l),(a1)+	; Lookup a,b
		eor.b	\3,\4
		move.b	(a2)+,\2		; Fetch %c0d2d1d0e2e1e0f2
		add.b	\2,\2			; %d2d1d0e2e1e0f2--
		addx.b	\4,\4			; %c2c1c0
		add.b	\4,\4			; %c2c1c0--
		move.w	(a3,\4.l),(a1)+		; Lookup c
		moveq	#0,\3
		move.b	(a2)+,\3		; Fetch %f1f0g2g1g0h2h1h0
		move.l	\2,\4			; %d2d1d0e2e1e0f2--
		and.b	\1,\2			; %d2d1d0e2e1e0----
		eor.b	\2,\4			; %f2--
		move.l	(a4,\2.l),(a1)+		; Lookup d,e
		add.w	\3,\3			; %f1f0g2g1g0h2h1h0--
		add.w	\3,\3			; %f1f0g2g1g0h2h1h0----
		or.w	\3,\4			; %f1f0g2g1g0h2h1h0f2--
		move.w	(a5,\4.l),(a1)+		; Lookup f
		move.l	(a6,\3.l),(a1)+		; Lookup g,h
		
		ENDM

		movem.l	d3-d4/a3-a6,-(sp)

		move.l	DecodeBitStream_3Bits_ReadPtr(a0),a2
		move.l	DecodeBitStream_3Bits_Lookup(a0),a6
		lea	DecodeBitStream_3Bits_Lookup_C(a6),a3	; Used as base ptr for both C and AB
		lea	DecodeBitStream_3Bits_Lookup_DE(a6),a4
		lea	DecodeBitStream_3Bits_Lookup_F(a6),a5
		lea	DecodeBitStream_3Bits_Lookup_GH(a6),a6

		subq.w	#8,d0
		bmi.s	.nDecode8Direct
		
		; Decode aligned groups of 8 entries and output directly to output buffer
		
.decode8Direct
		DECODE8	d1,d2,d3,d4

		subq.w	#8,d0
		bpl.s	.decode8Direct

.nDecode8Direct
		addq.w	#8,d0
		beq.s	.decodeDoneWithStreamReads

		; Decode group of 8 entries into temp buffer, and copy a portion thereof to output buffer
		
		move.l	a1,-(sp)
		lea	DecodeBitStream_3Bits_Decoded8Entries_Buf(a0),a1
		DECODE8	d1,d2,d3,d4
		lea	-8*2(a1),a3

		moveq	#8,d1
		sub.w	d0,d1
		move.w	d1,DecodeBitStream_3Bits_Decoded8Entries_NumRemaining(a0)
		
		move.l	(sp)+,a1
		add.w	d1,d1
		
		jmp	.copyTrailingEntries(pc,d1.w)
		
.copyTrailingEntries
		REPT	8
		move.w	(a3)+,(a1)+
		ENDR

.decodeDoneWithStreamReads
		move.l	a2,DecodeBitStream_3Bits_ReadPtr(a0)

		movem.l	(sp)+,d3-d4/a3-a6
		
.decodeDoneWithoutStreamReads

		movem.l	(sp)+,d2/a2

		rts
