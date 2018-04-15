
		IFND	DECODEBITSTREAM_3BITS_I
DECODEBITSTREAM_3BITS_I	SET	1

							rsreset
DecodeBitStream_3Bits_Lookup				rs.l	1
DecodeBitStream_3Bits_ReadPtr				rs.l	1
DecodeBitStream_3Bits_Decoded8Entries_Buf		rs.w	8
DecodeBitStream_3Bits_Decoded8Entries_NumRemaining	rs.w	1
DecodeBitStream_3Bits_SIZEOF				rs.b	0

					rsreset
DecodeBitStream_3Bits_Lookup_C		rs.w	(1<<3)
DecodeBitStream_3Bits_Lookup_AB		rs.l	(1<<6)
DecodeBitStream_3Bits_Lookup_DE		rs.l	1<<6
DecodeBitStream_3Bits_Lookup_F		rs.w	1<<9
DecodeBitStream_3Bits_Lookup_GH		rs.l	1<<8
DecodeBitStream_3Bits_Lookup_SIZEOF	rs.b	0


		XREF	DecodeBitStream_3Bits_Words_CreateLookup
		XREF	DecodeBitStream_3Bits_Words_InitState
		XREF	DecodeBitStream_3Bits_Words_Decode

		ENDC
