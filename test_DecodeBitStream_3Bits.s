
		include	"DecodeBitStream_3Bits.i"

OUTPUT_BUFFER_ENTRIES	= 16+1

;-----------------------------------------------------------------------------------

		section code,code

;-----------------------------------------------------------------------------------
; Validate that lookup initialization doesn't crash horribly, and doesn't write past
; the end of its buffer

test_initializeLookup
		lea	testLookup,a0
		move.w	#$1234,DecodeBitStream_3Bits_Lookup_SIZEOF(a0)
		lea	testTranslationTable,a1
		bsr	DecodeBitStream_3Bits_Words_CreateLookup

		cmp.w	#$1234,testLookup+DecodeBitStream_3Bits_Lookup_SIZEOF
		bne.s	.sentinelOverwritten
		moveq	#1,d0
		rts

.sentinelOverwritten
		moveq	#0,d0
		rts

;-----------------------------------------------------------------------------------
; Validate that state initialization doesn't crash horribly, and doesn't write past
; the end of its buffer

test_initializeState
		lea	testState,a0
		move.w	#$1234,DecodeBitStream_3Bits_SIZEOF(a0)
		lea	testInput,a1
		lea	testTranslationTable,a2
		bsr	DecodeBitStream_3Bits_Words_InitState

		cmp.w	#$1234,testState+DecodeBitStream_3Bits_SIZEOF
		bne.s	.sentinelOverwritten
		moveq	#1,d0
		rts

.sentinelOverwritten
		moveq	#0,d0
		rts

;-----------------------------------------------------------------------------------
; Decoding 0 elements is allowed yet produces no output
;

test_decodeZeroElements
		bsr	initDecoder
		bsr	initOutputStream

		lea	testOutput,a1
		lea	testState,a0
		moveq	#0,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		cmp.l	#testOutput,a1			; Validate output ptr did not move
		bne.s	.outputPtrChanged

		cmp.w	#$1234,testOutput		; Validate output buffer did not
		bne.s	.sentinelOverwritten		;  get written to
		moveq	#1,d0
		rts

.outputPtrChanged
.sentinelOverwritten
		moveq	#0,d0
		rts

;-----------------------------------------------------------------------------------
; Decoding 3 elements produces output
;

test_decodeThreeElements
		bsr	initDecoder
		bsr	initOutputStream

		lea	testOutput,a1
		lea	testState,a0
		moveq	#3,d0
		bsr	DecodeBitStream_3Bits_Words_Decode


		cmp.l	#testOutput+3*2,a1		; Validate output ptr moved the right amount
		bne.s	.outputPtrMovedIncorrectly

		cmp.w	#$0000,testOutput+0*2		; Validate output buffer contents
		bne.s	.mismatch
		cmp.w	#$1111,testOutput+1*2
		bne.s	.mismatch
		cmp.w	#$2222,testOutput+2*2
		bne.s	.mismatch

		cmp.w	#$1234,testOutput+3*2		; Validate output buffer was not written too far
		bne.s	.sentinelOverwritten

		moveq	#1,d0
		rts

.outputPtrMovedIncorrectly
.mismatch
.sentinelOverwritten
		moveq	#0,d0
		rts

;-----------------------------------------------------------------------------------
; Decoding 16 elements produces output
;

test_decodeSixteenElements
		bsr	initDecoder
		bsr	initOutputStream

		lea	testOutput,a1
		lea	testState,a0
		moveq	#16,d0
		bsr	DecodeBitStream_3Bits_Words_Decode


		cmp.l	#testOutput+16*2,a1		; Validate output ptr moved the right amount
		bne	.outputPtrMovedIncorrectly

		cmp.w	#$0000,testOutput+0*2		; Validate output buffer contents
		bne	.mismatch
		cmp.w	#$1111,testOutput+1*2
		bne	.mismatch
		cmp.w	#$2222,testOutput+2*2
		bne	.mismatch
		cmp.w	#$3333,testOutput+3*2
		bne	.mismatch
		cmp.w	#$4444,testOutput+4*2
		bne	.mismatch
		cmp.w	#$5555,testOutput+5*2
		bne.s	.mismatch
		cmp.w	#$6666,testOutput+6*2
		bne.s	.mismatch
		cmp.w	#$7777,testOutput+7*2
		bne.s	.mismatch
		cmp.w	#$7777,testOutput+8*2
		bne.s	.mismatch
		cmp.w	#$6666,testOutput+9*2
		bne.s	.mismatch
		cmp.w	#$5555,testOutput+10*2
		bne.s	.mismatch
		cmp.w	#$4444,testOutput+11*2
		bne.s	.mismatch
		cmp.w	#$3333,testOutput+12*2
		bne.s	.mismatch
		cmp.w	#$2222,testOutput+13*2
		bne.s	.mismatch
		cmp.w	#$1111,testOutput+14*2
		bne.s	.mismatch
		cmp.w	#$0000,testOutput+15*2
		bne.s	.mismatch

		cmp.w	#$1234,testOutput+16*2		; Validate output buffer was not written too far
		bne.s	.sentinelOverwritten

		moveq	#1,d0
		rts

.outputPtrMovedIncorrectly
.mismatch
.sentinelOverwritten
		moveq	#0,d0
		rts

;-----------------------------------------------------------------------------------
; Multiple sequential decode calls produces correct output
;

test_multipleDecodeCalls
		bsr	initDecoder
		bsr	initOutputStream

		lea	testOutput,a1
		lea	testState,a0
		moveq	#3,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		cmp.l	#testOutput+3*2,a1		; Validate output ptr moved the right amount
		bne	.outputPtrMovedIncorrectly

		moveq	#4,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		cmp.l	#testOutput+7*2,a1		; Validate output ptr moved the right amount
		bne	.outputPtrMovedIncorrectly

		moveq	#3,d0
		bsr	DecodeBitStream_3Bits_Words_Decode

		cmp.l	#testOutput+10*2,a1		; Validate output ptr moved the right amount
		bne	.outputPtrMovedIncorrectly

		cmp.w	#$0000,testOutput+0*2		; Validate output buffer contents
		bne	.mismatch
		cmp.w	#$1111,testOutput+1*2
		bne	.mismatch
		cmp.w	#$2222,testOutput+2*2
		bne	.mismatch
		cmp.w	#$3333,testOutput+3*2
		bne	.mismatch
		cmp.w	#$4444,testOutput+4*2
		bne	.mismatch
		cmp.w	#$5555,testOutput+5*2
		bne.s	.mismatch
		cmp.w	#$6666,testOutput+6*2
		bne.s	.mismatch
		cmp.w	#$7777,testOutput+7*2
		bne.s	.mismatch
		cmp.w	#$7777,testOutput+8*2
		bne.s	.mismatch
		cmp.w	#$6666,testOutput+9*2
		bne.s	.mismatch

		cmp.w	#$1234,testOutput+10*2		; Validate output buffer was not written too far
		bne.s	.sentinelOverwritten

		moveq	#1,d0
		rts

.outputPtrMovedIncorrectly
.mismatch
.sentinelOverwritten
		moveq	#0,d0
		rts

;-----------------------------------------------------------------------------------
; Helpers
;

initDecoder
		lea	testLookup,a0
		lea	testTranslationTable,a1
		bsr	DecodeBitStream_3Bits_Words_CreateLookup

		lea	testState,a0
		lea	testInput,a1
		lea	testLookup,a2
		bsr	DecodeBitStream_3Bits_Words_InitState
		rts

initOutputStream
		lea	testOutput,a0
		moveq	#OUTPUT_BUFFER_ENTRIES-1,d0
.fillEntry	move.w	#$1234,(a0)+
		dbf	d0,.fillEntry
		rts

;-----------------------------------------------------------------------------------

		section	data,data

;-----------------------------------------------------------------------------------

testTranslationTable
		dc.w	$0000,$1111,$2222,$3333,$4444,$5555,$6666,$7777

testInput
		; Sequence: 0,1,2,3,4,5,6,7, 7,6,5,4,3,2,1,0
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

;-----------------------------------------------------------------------------------

		section	bss,bss

;-----------------------------------------------------------------------------------
	
testLookup	ds.b	DecodeBitStream_3Bits_Lookup_SIZEOF+2
testState	ds.b	DecodeBitStream_3Bits_SIZEOF
testOutput	ds.w	OUTPUT_BUFFER_ENTRIES
