
; Test program for 3-bit stream decoder

		include	"DecodeBitStream_3Bits.i"

		section	code,code

start
		bsr	Initialize

		bsr	Decode

		bsr	Validate
		rts

Initialize
		lea	Decode_Lookup,a0
		lea	Decode_TranslationTable,a1
		bsr	DecodeBitStream_3Bits_Words_CreateLookup

		lea	Decode_State,a0
		lea	BitStreamInput,a1
		lea	Decode_Lookup,a2
		bsr	DecodeBitStream_3Bits_Words_InitState

		rts

Decode
		lea	BitStreamOutput,a1
		lea	Decode_State,a0
		move.w	#2,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		lea	Decode_State,a0
		move.w	#0,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		lea	Decode_State,a0
		move.w	#6,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		lea	Decode_State,a0
		move.w	#18,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		move.l	a1,d0
		sub.l	a0,d0
		rts

Validate
		sub.l	#BitStreamOutput,a1
		move.l	a1,d1
		lea	BitStreamOutput,a1
		lea	ExpectedOutput,a0
		move.l	#ExpectedOutputEnd-ExpectedOutput,d0

		cmp.l	d0,d1
		bne.s	.differentLengths

.compareContent
		cmpm.b	(a0)+,(a1)+
		bne.s	.differentContent
		subq.l	#1,d0
		bne.s	.compareContent

		moveq	#0,d0			; Exit code 0: decoded buffer matches expected
		rts
		
.differentLengths
		moveq	#21,d0			; Exit code 21: decoded buffer length does not match expected length
		rts

.differentContent
		moveq	#22,d0			; Exit code 22: decoded buffer length matches expected length, but content differs
		rts
		
		section	data,data

BitStreamInput
		dc.b	%00000101
		dc.b	%00111001
		dc.b	%01110111

		dc.b	%11111010
		dc.b	%11000110
		dc.b	%10001000
		
		dc.b	%00000101
		dc.b	%00111001
		dc.b	%01110111

		dc.b	%11111010
		dc.b	%11000010
		dc.b	%10001000
		
		even
		
Decode_TranslationTable
		dc.w	$0f00
		dc.w	$1e11
		dc.w	$2d22
		dc.w	$3c33
		dc.w	$4b44
		dc.w	$5a55
		dc.w	$6966
		dc.w	$7877
		
ExpectedOutput
		dc.w	$0f00
		dc.w	$1e11
		dc.w	$2d22
		dc.w	$3c33
		dc.w	$4b44
		dc.w	$5a55
		dc.w	$6966
		dc.w	$7877

		dc.w	$7877
		dc.w	$6966
		dc.w	$5a55
		dc.w	$4b44
		dc.w	$3c33
		dc.w	$2d22
		dc.w	$1e11
		dc.w	$0f00

		dc.w	$0f00
		dc.w	$1e11
		dc.w	$2d22
		dc.w	$3c33
		dc.w	$4b44
		dc.w	$5a55
		dc.w	$6966
		dc.w	$7877

		dc.w	$7877
		dc.w	$6966
ExpectedOutputEnd

		section	bss,bss
	
Decode_Lookup	ds.b 	DecodeBitStream_3Bits_Lookup_SIZEOF
Decode_State	ds.b	DecodeBitStream_3Bits_SIZEOF

BitStreamOutput
		ds.w	1000
