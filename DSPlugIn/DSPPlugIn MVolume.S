
	MC68020

SST_SYS_GetMem			EQU	0
SST_SYS_FreeMem			EQU	4

SST_FILE_RequestFileName	EQU	100
SST_FILE_SetReqPattern		EQU	104
SST_FILE_SetReqDir		EQU	108
SST_FILE_GetFileName		EQU	112
SST_FILE_GetFileLen		EQU	116

SST_GFX_AssistText		EQU	200
SST_GFX_AssistDecLong		EQU	204
SST_GFX_AssistDecByte		EQU	208
SST_GFX_AssistHexLong		EQU	212

SST_AUDIO_GetChunkLen		EQU	400

SST_PTR_EXECBASE		EQU	1600
SST_PTR_INTBASE			EQU	1604
SST_PTR_DOSBASE			EQU	1608
SST_PTR_ASLBASE			EQU	1612
SST_PTR_REQTOOLSBASE		EQU	1616
SST_PTR_GFXBASE			EQU	1620

SST_PTR_Screen			EQU	1650

SST_ADR_ProcessorFlags		EQU	1800
SST_ADR_SystemFrequency		EQU	1804
SST_ADR_SystemBpm		EQU	1808
SST_ADR_ChunkLen		EQU	1812
SST_ADR_OversampleFlag		EQU	1816


	dc.b	"Symphonie DSP Plugin"	;MAGIC String    (PRIVATE)
	dc.w	1,0			;Version,Release (PRIVATE,DO NOT CHANGE)

	;- DSPLIB -------------------------------------------------

	jmp	InitDSP(PC)		;Allocate Mem, Build your Tables
	jmp	CleanUpDSP(PC)		;Free Mem

	jmp	ProcDsp(PC)		;Process DSP algorithm (interrupt)

	jmp	GetDspTitle(PC)		;Get DSP algorithm Title
	jmp	ModifyValue(PC)		;notify changed Value

	jmp	GraphSizeModify(PC)	;notify graph size has changed
	jmp	RefreshGraph(PC)	;notify its time for a GFX update

	jmp	StartDSP(PC)		;notify start
	jmp	StopDSP(PC)		;notify stop
	dc.l	-1

	;- CODE --------------------------------------------------


StartDSP
	rts

StopDSP
	rts

GraphSizeModify
	rts

RefreshGraph
	rts

ModifyValue	;INPUT (D0L,D1L)(VALUE, PARAMETER ID)
	lea.l	Volume(PC),a0
	move.l	d0,(a0)

	move.l	#SST_GFX_AssistHexLong,d7
	bsr	GoSST

	move.l	#SST_GFX_AssistDecLong,d7
	bsr	GoSST

	rts

Volume	dc.l	256

GoSST	move.l	a6,-(sp)
	move.l	SUPERSTBASE(PC),a6
	move.l	(a6,d7.w),a6
	jsr	(a6)
	move.l	(sp)+,a6
	rts


InitDSP		;I(A0L)(SUPERSUPPORTTABLE_PTR)
		;O(A0L)(DSPGUI_PTR)

	lea.l	SUPERSTBASE(PC),a1
	move.l	a0,(a1)

	lea.l	Welcome_TXT(PC),a0
	move.l	#SST_GFX_AssistText,d7
	bsr	GoSST




	lea.l	Parameter_DEF(PC),a0
	rts

CleanUpDSP	rts

GetDspTitle	;OUTPUT (A0L)(DSPTitle_TXT)
	lea.l	DSPTitle(PC),a0
	rts

ProcDsp		;INPUT (D0W,A1L)(SAMPLE_NUMB,SAMPLECHUNK_PTR)
	movem.l	d0-a6,-(sp)

	move.l	Volume(PC),d3
	andi.l	#$fff,d3

	subq.w	#1,d0

.loop
	move.l	(a1),d1

	move.l	d1,d2
	swap	d1

	muls	d3,d2
	asr.l	#8,d2

	muls	d3,d1
	asr.l	#8,d1

	swap	d1

	move.w	d2,d1

	move.l	d1,(a1)+
	dbf	d0,.loop


	movem.l	(sp)+,d0-a6
	rts



	;- GUI ------------------------------------------------------

	even
Parameter_DEF
	dc.b	"Volume",0	;PARAMETER TITLE (C STRING)
	dc.b	0,0,1,0		;Init (LONG)
	dc.b	0,0,0,0		;Min (LONG)
	dc.b	0,0,1,0		;Max (LONG)


	dc.b	0		;END OF GUI DEF

	;- TITLE ----------------------------------------------------


		dc.b	"$VER: "
DSPTitle	dc.b	"Test Dsp Plugin v1.0",0
Welcome_TXT	dc.b	"Welcome to DSP test",0

		even
SUPERSTBASE	dc.l	0
test		dc.l	0
	END
