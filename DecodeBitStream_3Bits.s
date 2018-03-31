
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

DecodeBitStream_3Bits_Words_CreateLookup

		movem.l	d2-d4/a2,-(sp)

		; Generate A: **********a2a1a0

		lea	DecodeBitStream_3Bits_Lookup_AB(a0),a2
		move.w	#(1<<5)-1,d0
.genA	
CNTR	SET	0
		REPT	(1<<3)
		move.w	(a1)+,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<3)*4,a2
		sub.w	#(1<<3)*2,a1
		dbf	d0,.genA

		; Generate B: ****b2b1b0******
	
		lea	DecodeBitStream_3Bits_Lookup_AB+2(a0),a2
		moveq	#(1<<2)-1,d0
.genBOuter
		swap	d0
		move.w	#(1<<3)-1,d0
.genBInner
		move.w	(a1)+,d1

CNTR	SET	0
		REPT	(1<<3)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<3)*4,a2
		dbf	d0,.genBInner
		sub.w	#(1<<3)*2,a1
		swap	d0
		dbf	d0,.genBOuter

		; Generate C: c1c0**************c2

		lea	DecodeBitStream_3Bits_Lookup_CF(a0),a2
		move.w	#(1<<2)-1,d0
.genCOuter
		swap	d0
		move.w	(a1),d1
		move.w	(1<<2)*2(a1),d2
		move.w	#(1<<7)-1,d0
.genCInner
		move.w	d1,(a2)
		move.w	d2,4(a2)
		addq.w	#(1<<1)*4,a2
		dbf	d0,.genCInner
		addq.w	#2,a1
		swap	d0
		dbf	d0,.genCOuter
		subq.w	#(1<<2)*2,a1
	
		; Generate F: f0************f2f1

		lea	DecodeBitStream_3Bits_Lookup_CF+2(a0),a2
		move.w	#(1<<1)-1,d0
.genFOuter
		swap	d0
		move.w	(a1),d1
		move.w	1*4(a1),d2
		move.w	2*4(a1),d3
		move.w	3*4(a1),d4
		move.w	#(1<<6)-1,d0
.genFInner
		move.w	d1,(a2)
		move.w	d2,1*4(a2)
		move.w	d3,2*4(a2)
		move.w	d4,3*4(a2)
		add.w	#(1<<2)*4,a2
		dbf	d0,.genFInner
		addq.w	#2,a1
		swap	d0
		dbf	d0,.genFOuter
		subq.w	#(1<<1)*2,a1

		; Generate D: ************d2d1d0**

		lea	DecodeBitStream_3Bits_Lookup_DE(a0),a2
		moveq	#(1<<6)-1,d0
.genDOuter
		swap	d0
		move.w	#(1<<3)-1,d0
.genDInner
		move.w	(a1)+,d1

CNTR	SET	0
		REPT	(1<<1)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		addq.w	#(1<<1)*4,a2
		dbf	d0,.genDInner
		sub.w	#(1<<3)*2,a1
		swap	d0
		dbf	d0,.genDOuter

		; Generate E: ******e2e1e0********

		lea	DecodeBitStream_3Bits_Lookup_DE+2(a0),a2
		moveq	#(1<<3)-1,d0
.genEOuter
		swap	d0
		move.w	#(1<<3)-1,d0
.genEInner
		move.w	(a1)+,d1

CNTR	SET	0
		REPT	(1<<4)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<4)*4,a2
		dbf	d0,.genEInner
		sub.w	#(1<<3)*2,a1
		swap	d0
		dbf	d0,.genEOuter

		; Generate G: ********g2g1g0****

		lea	DecodeBitStream_3Bits_Lookup_GH(a0),a2
		moveq	#(1<<4)-1,d0
.genGOuter
		swap	d0
		move.w	#(1<<3)-1,d0
.genGInner
		move.w	(a1)+,d1

CNTR	SET	0
		REPT	(1<<2)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<2)*4,a2
		dbf	d0,.genGInner
		sub.w	#(1<<3)*2,a1
		swap	d0
		dbf	d0,.genGOuter

		; Generate H: **h2h1h0**********

		lea	DecodeBitStream_3Bits_Lookup_GH+2(a0),a2
		moveq	#(1<<1)-1,d0
.genHOuter
		swap	d0
		move.w	#(1<<3)-1,d0
.genHInner
		move.w	(a1)+,d1

CNTR	SET	0
		REPT	(1<<5)
		move.w	d1,CNTR(a2)
CNTR	SET	CNTR+4
		ENDR
		add.w	#(1<<5)*4,a2
		dbf	d0,.genHInner
		sub.w	#(1<<3)*2,a1
		swap	d0
		dbf	d0,.genHOuter

		movem.l	(sp)+,d2-d4/a2

		rts

;-------------------------------------------------------------------------------------
; Setup 3-bit decoder
;
; in:
;	a0	DecodeBitStream_3Bits_State*	decoder state
;	a1	uint8*				input stream
;	a2	DecodeBitStream_3Bits_Lookup*	lookup tables

DecodeBitStream_3Bits_Words_InitState
		move.l	a1,DecodeBitStream_3Bits_ReadPtr(a0)
		move.l	a2,DecodeBitStream_3Bits_Lookup(a0)
		rts

;-------------------------------------------------------------------------------------
; Decode 3-bit data stream to words
;
; in:
;	d0.w	uint16_t			number of 3-bit entries to decode
;	a0	DecodeBitStream_3Bits_State*	decoder state
;	a1	uint16_t*			output buffer

DecodeBitStream_3Bits_Words_Decode

		move.l	DecodeBitStream_3Bits_ReadPtr(a0),a2
		move.l	DecodeBitStream_3Bits_Lookup(a0),a6
		lea	DecodeBitStream_3Bits_Lookup_AB(a6),a3
		lea	DecodeBitStream_3Bits_Lookup_CF(a6),a4
		lea	DecodeBitStream_3Bits_Lookup_DE(a6),a5
		lea	DecodeBitStream_3Bits_Lookup_GH(a6),a6
		
; Read 3 bytes, output 8 entries

.decode8

; a3 - lookup table for     ****b2b1b0a2a1a0 -> word with a, word with b
; a4 - lookup table for c1c0f0e2e1e0d2d1d0c2 -> word with c, <unused>
; a4 - lookup table for   f0h2h1h0g2g1g0f2f1 -> <unused>, word with f
; a5 - lookup table for c1c0f0e2e1e0d2d1d0c2 -> word with d, word with e
; a6 - lookup table for   f0h2h1h0g2g1g0f2f1 -> word with g, word with h

		moveq	#0,d0
		move.b	(a2)+,d0		; fetch c[1..0], b, a
		add.w	d0,d0
		add.w	d0,d0
		move.l	(a3,d0.l),(a6)+		; extract b, a

		moveq	#0,d1
		move.b	(a2)+,d0		; fetch f[0], e, d, c[2]
		move.b	d0,d1
		add.w	d0,d0
		add.w	d0,d0
		move.w	(a4,d0.l),(a6)+		; extract c
		move.l	(a5,d0.l),(a6)+		; extract e, d

		add.w	d1,d1
		move.b	(a2)+,d1		; fetch h, g, f[2..1]
		add.w	d1,d1
		add.w	d1,d1
		move.w	2(a4,d1.l),(a6)+	; extract f
		move.l	(a6,d1.l),(a6)+		; extract h, g

