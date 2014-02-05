;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; PICAXE, DS1307 based "GPO Master Clock" (Clock36 + GMT34)
;
; Paul Seward - http://paulseward.com 2014-02-5
;
; The aim is to provice an accurate source of 1sec, 2sec, 6sec and 30sec pulses
; to drive old slave clock dials.
;
; The 08M2+ doesn't have enough output pins to provide all of the required
; outputs, so we use the SQ pin on the DS1307 for 1S to provide the 1sec pulse
; stream, and provide the 2sec and 30sec from the PICAXE.
;
; The code for generating the 6sec pulse is included, but it's commented out
; due to lack of output pins
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

symbol seconds   = b0
symbol mins      = b1
symbol hour      = b2
symbol day       = b3
symbol date      = b4
symbol month     = b5
symbol year      = b6
symbol control   = b7
symbol last_tick = b8
symbol sec_mod   = b9
symbol dec_seconds = b10

; set DS1307 slave address 
hi2csetup i2cmaster, %11010000, i2cslow, i2cbyte 

; Initialise the clock - "Thu 2003-12-25 11:59:28"
let day     = $03       ; 03 Note BCD format 
let year    = $03       ; 03 Note BCD format 
let month   = $12       ; 12 Note BCD format 
let date    = $25       ; 25 Note BCD format 
let hour    = $11       ; 11 Note BCD format 
let mins    = $59       ; 59 Note BCD format 
let seconds = $28       ; 00 Note BCD format
let control = %00010000 ; Enable SQ output at 1Hz

; Initialise our control variable
let last_tick = $0;

; Bootstrap the DS1307
hi2cout 0,(seconds,mins,hour,day,date,month,year,control)

main: 
  ; Read the clock time 
  hi2cin 0,(seconds,mins,hour,day,date,month,year) 
  
  ; If we are in a new second
  if last_tick != seconds then
  
    ; seconds is BCD, we need to convert to decimal
    dec_seconds = seconds / 16 * 10
    dec_seconds = seconds & $F + dec_seconds
    
    ; 2 sec output
    let sec_mod = dec_seconds % 2
    if sec_mod = 0 then
      high c.0
    endif

;    ; 6 sec output
;    let sec_mod = dec_seconds % 6
;    if sec_mod = 0 then
;      high c.3
;    endif

    ; 30 Sec output
    let sec_mod = dec_seconds % 30
    if sec_mod = 0 then
      high c.4
    endif

    ; pause for 250ms and then reset output pins
    nap 4     ; low power "nap" for approx 288ms - saves battery compared to pause
    low c.0   ; 2 sec output
;    low c.3   ; 6 sec output
    low c.4   ; 30 sec output
    nap 3     ; low power "nap" for approx 144ms - save a bit more battery
    
    ; Update last_tick
    let last_tick = seconds
  endif

  goto main 
  