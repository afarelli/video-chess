LogicVbl:
        jp L_F00F
LogicOver:
        jp L_F27B
L_F00F:
        ld a,$FF
L_F011:
L_F013:
L_F015:
L_F017:
        ld hl,Z_D3
        inc (hl)
L_F019:
        jp nz,L_F021
L_F01B:
        ld hl,Z_F1
        inc (hl)
L_F01D:
        jp nz,L_F021
L_F01F:
        ld (Z_F0),a
L_F021:
        ld hl,Z_F0
        xor (hl)
L_F023:
        or $F7
L_F025:
        ld (Z_E9),a
L_F027:
        ld a,(inSWCHB)
L_F02A:
        and $08
L_F02C:
        srl a
L_F02D:
        ld iyl,a
L_F02E:
        ld ixl,$04
L_F030:
        ld a,(Z_F1)
L_F032:
        ld hl,Z_F0
        and (hl)
L_F034:
        push af
        ld a,iyl
        add a,$6E
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        xor (hl)
L_F037:
        ld hl,Z_E9
        and (hl)
L_F039:
        ld (ix-35),a
L_F03B:
        ld e,a
        ld a,ixl
        add a,$05
        ld l,a
        ld h,$FA
        ld (hl),e
        ld a,e
L_F03D:
        inc iyl
L_F03E:
        dec ixl
L_F03F:
        jp nz,L_F030
L_F041:
L_F043:
        ld hl,inSWCHB
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F046:
        ld hl,Z_ED
        ld e,iyl
        ld (hl),e
L_F048:
        jp p,L_F050
L_F04A:
        ld hl,Z_DF
        ld e,(hl)
        ld iyl,e
L_F04C:
        ld (Z_DF),a
L_F04E:
        ld hl,Z_DE
        ld e,iyl
        ld (hl),e
L_F050:
        ld iyl,$24
L_F052:
L_F054:
L_F056:
L_F059:
        call L_F2AA
L_F05C:
        ld a,(Z_D3)
L_F05E:
        and $0C
L_F060:
        cp $04
        ccf
L_F062:
        call L_F53C
L_F065:
        ld hl,Z_D9
        ld e,(hl)
        ld ixl,e
L_F067:
        jp nc,L_F075
L_F069:
        ld hl,Z_F3
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F06B:
        jp m,L_F075
L_F06D:
        ld hl,Z_DB
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F06F:
        jp nz,L_F079
L_F071:
        ld hl,Z_F3
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F073:
        jp nz,L_F079
L_F075:
        ld a,$08
        inc a
        dec a
L_F077:
        jp nz,L_F07B
L_F079:
        ld a,(Z_DB)
L_F07B:
        call L_FE64
L_F07E:
        ld hl,Z_DA
        ld e,(hl)
        ld ixl,e
L_F080:
        ld a,(ix-128)
L_F082:
        jr nc,LC_F082_0
        and $F0
        scf
        jr LC_F082_1
LC_F082_0:
        and $F0
LC_F082_1:
L_F084:
        ld hl,Z_E7
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F086:
        jp m,L_F094
L_F088:
        ld hl,Z_F3
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F08A:
        jp z,L_F09A
L_F08C:
        jp p,L_F090
L_F08E:
        jp c,L_F098
L_F090:
        jp nc,L_F096
L_F092:
        ld hl,Z_DC
        jr nc,LC_F092_0
        or (hl)
        scf
        jr LC_F092_1
LC_F092_0:
        or (hl)
LC_F092_1:
L_F094:
        jp c,L_F098
L_F096:
        ld hl,Z_DB
        jr nc,LC_F096_0
        or (hl)
        scf
        jr LC_F096_1
LC_F096_0:
        or (hl)
LC_F096_1:
L_F098:
        ld (ix-128),a
L_F09A:
        ld a,(Z_E7)
        inc a
        dec a
L_F09C:
        jp z,L_F0A8
L_F09E:
        jp m,L_F0A8
L_F0A0:
        ld hl,Z_E6
        jr nc,LC_F0A0_0
        or (hl)
        scf
        jr LC_F0A0_1
LC_F0A0_0:
        or (hl)
LC_F0A0_1:
L_F0A2:
        jp p,L_F0A8
L_F0A4:
        ld a,$00
L_F0A6:
        ld (Z_E7),a
L_F0A8:
        ld iyl,a
        inc iyl
        dec iyl
L_F0A9:
        jp z,L_F0C8
L_F0AB:
        ld hl,Z_F7
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_F0AD:
        jp m,L_F0BD
L_F0AF:
        ld a,(Z_F6)
        inc a
        dec a
L_F0B1:
        jp z,L_F0BD
L_F0B3:
        ld a,$0F
L_F0B5:
        jp c,L_F0BA
L_F0B7:
        ld a,$09
L_F0B9:
        ld iyl,a
L_F0BA:
        call L_FE64
L_F0BD:
        ld a,(Z_EE)
L_F0BF:
        rla
L_F0C0:
        cp $04
        ccf
L_F0C2:
        jp c,L_F0C8
L_F0C4:
        ld ixl,a
L_F0C5:
        push af
        ld a,ixl
        add a,$E9
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        ld e,(hl)
        ld iyl,e
L_F0C8:
        ld e,iyl
        ld hl,T_AUDC0
        ld (hl),e
L_F0CA:
        ld a,(inINTIM)
        inc a
        dec a
L_F0CD:
        jp nz,L_F0CA
L_F0CF:
L_F0D1:
        ld hl,Z_D0
        dec (hl)
L_F0D3:
        jp p,L_F0D9
L_F0D5:
        ld hl,Z_D0
        inc (hl)
L_F0D7:
L_F0D9:
        ld ixl,$0F
L_F0DB:
        ld e,ixl
        ld hl,T_AUDV0
        ld (hl),e
L_F0DD:
        ld e,ixl
        ld hl,T_AUDF0
        ld (hl),e
L_F0DF:
        ld iyl,$FF
L_F0E1:
        ld e,iyl
        ld (ix-64),e
L_F0E3:
        dec ixl
L_F0E4:
        ld (ix-64),a
L_F0E6:
        dec ixl
L_F0E7:
        jp p,L_F0E1
L_F0E9:
        ld iyl,$1F
L_F0EB:
        call L_F545
L_F0EE:
L_F0F0:
        ld a,(Z_EA)
        ret
L_F13E:
        ld a,(Z_D6)
L_F140:
        ld hl,Z_D5
        ld e,(hl)
        ld ixl,e
L_F142:
        and $07
L_F144:
        cp $06
L_F146:
        jp nz,L_F163
L_F148:
        ld a,(Z_E5)
L_F14A:
        xor $10
L_F14C:
        ld iyl,a
L_F14D:
        xor $08
L_F14F:
        ld hl,Z_D5
        cp (hl)
        ccf
L_F151:
        jp z,L_F17F
L_F153:
        ld b,a
        ld a,ixl
        cp $08
        ld a,b
        ccf
L_F155:
        jp nc,L_F15B
L_F157:
        ld b,a
        ld a,ixl
        cp $38
        ld a,b
        ccf
L_F159:
        jp nc,L_F182
L_F15B:
        ld a,(Z_D6)
L_F15D:
        jr nc,LC_F15D_0
        xor $04
        scf
        jr LC_F15D_1
LC_F15D_0:
        xor $04
LC_F15D_1:
L_F15F:
        ld (Z_D6),a
L_F161:
        jp c,L_F182
L_F163:
        cp $01
        ccf
L_F165:
        jp nz,L_F182
L_F167:
        ld a,(Z_D4)
L_F169:
        jr nc,LC_F169_0
        and $38
        scf
        jr LC_F169_1
LC_F169_0:
        and $38
LC_F169_1:
L_F16B:
        ld iyl,a
L_F16C:
        ld a,ixl
L_F16D:
        ld hl,Z_D4
        ccf
        sbc a,(hl)
        ccf
        jp pe,LV_F16D_1
        res 6,d
        jr LV_F16D_2
LV_F16D_1:
        set 6,d
LV_F16D_2:
L_F16F:
        cp $FE
        ccf
L_F171:
        jp nz,L_F176
L_F173:
        inc ixl
L_F174:
        jp c,L_F17F
L_F176:
        cp $02
        ccf
L_F178:
        jp nz,L_F182
L_F17A:
        dec ixl
L_F17B:
        ld a,iyl
L_F17C:
        jr nc,LC_F17C_0
        or $07
        scf
        jr LC_F17C_1
LC_F17C_0:
        or $07
LC_F17C_1:
L_F17E:
        ld iyl,a
L_F17F:
        call L_FD37
L_F182:
        ret
L_F1DC:
        ld ixl,$04
L_F1DE:
        ld a,(ix-39)
L_F1E0:
        ld (ix-44),a
L_F1E2:
        dec ixl
L_F1E3:
        jp p,L_F1DE
L_F1E5:
        ret
L_F1E6:
        ld (T_AUDC0),a
L_F1E8:
        ld a,(Z_E7)
        inc a
        dec a
L_F1EA:
        jp p,L_F1FB
L_F1EC:
        ld hl,Z_F3
        ld e,iyl
        ld (hl),e
L_F1EE:
        ld a,(Z_EE)
        inc a
        dec a
L_F1F0:
        jp z,L_F1FB
L_F1F2:
        ld hl,Z_DA
        ld e,(hl)
        ld ixl,e
L_F1F4:
        ld a,(Z_D6)
L_F1F6:
        call L_FE64
L_F1F9:
        ld hl,Z_D6
        ld e,iyl
        ld (hl),e
L_F1FB:
        ld hl,Z_E7
        ld e,iyl
        ld (hl),e
L_F1FD:
        ret
L_F27B:
        ld iyl,$3F
L_F27D:
L_F27F:
L_F281:
L_F283:
        call L_F545
L_F286:
        call L_F3E7
L_F289:
        ld a,$09
L_F28B:
        ld (Z_CC),a
L_F28D:
        call L_FE7D
L_F290:
        ld hl,Z_D9
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F292:
        jp nz,L_F29A
L_F294:
        ld a,(Z_F3)
        inc a
        dec a
L_F296:
        jp z,L_F29A
L_F298:
        ld hl,Z_DD
        ld e,(hl)
        ld ixl,e
L_F29A:
        ld hl,Z_F7
        ld e,ixl
        ld (hl),e
L_F29C:
        ld a,(Z_E2)
        inc a
        dec a
L_F29E:
        call GetP        ; PHP+PLA: A = P do 6502 (N V 1 B D I Z C)
L_F29F:
L_F2A0:
        ld (Z_E2),a
        ret
L_F2AA:
        ld a,(inSWCHB)
L_F2AD:
        ld iyl,$00
L_F2AF:
        srl a
L_F2B0:
        jp c,L_F2FF
L_F2B2:
        ld hl,Z_E4
        ld e,iyl
        ld (hl),e
L_F2B4:
        ld ixl,$07
L_F2B6:
        ld a,ixl
        add a,$F2
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        ld a,(hl)
L_F2B9:
        ld (ix-128),a
L_F2BB:
        xor $08
L_F2BD:
        ld (ix-72),a
L_F2BF:
        ld a,$8E
L_F2C1:
        ld (ix-80),a
L_F2C3:
        ld a,$46
L_F2C5:
        ld (ix-120),a
L_F2C7:
        ld e,iyl
        ld (ix-112),e
L_F2C9:
        ld e,iyl
        ld (ix-104),e
L_F2CB:
        ld e,iyl
        ld (ix-96),e
L_F2CD:
        ld e,iyl
        ld (ix-88),e
L_F2CF:
        dec ixl
L_F2D0:
        jp p,L_F2B6
L_F2D2:
        ld hl,Z_E2
        ld e,ixl
        ld (hl),e
L_F2D4:
        ld hl,Z_F7
        ld e,ixl
        ld (hl),e
L_F2D6:
        ld hl,Z_E5
        ld e,ixl
        ld (hl),e
L_F2D8:
        ld hl,Z_ED
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F2DA:
        jp p,L_F2EC
L_F2DC:
        ld hl,Z_D3
        ld d,(hl)
L_F2DE:
        bit 6,d
        jp nz,L_F2E1
L_F2E0:
        inc ixl
L_F2E1:
        ld e,iyl
        ld (ix-116),e
L_F2E3:
        ld (ix-100),a
L_F2E5:
        ld hl,Z_B9
        sla (hl)
L_F2E7:
        scf
L_F2E8:
        ld hl,Z_B9
        rr (hl)
L_F2EA:
        ld hl,Z_E4
        inc (hl)
L_F2EC:
        ld hl,Z_F3
        ld e,iyl
        ld (hl),e
L_F2EE:
        ld hl,Z_E7
        ld e,iyl
        ld (hl),e
L_F2F0:
        ld ixl,$03
L_F2F2:
        ld hl,Z_EE
        ld e,ixl
        ld (hl),e
L_F2F4:
        srl a
L_F2F5:
        ld (Z_D5),a
L_F2F7:
        ld (Z_D4),a
L_F2F9:
        ld (Z_D8),a
L_F2FB:
        ld a,iyl
L_F2FC:
        jp L_F520
L_F2FF:
        srl a
L_F300:
        jp c,L_F315
L_F302:
        ld hl,Z_F2
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F304:
        jp nz,L_F30E
L_F306:
        ld hl,Z_EA
        ld e,(hl)
        ld ixl,e
L_F308:
        inc ixl
L_F309:
        ld a,ixl
L_F30A:
        and $07
L_F30C:
        ld (Z_EA),a
L_F30E:
        ld b,a
        ld a,iyl
        cp $1E
        ld a,b
        ccf
L_F310:
        jp nc,L_F314
L_F312:
        ld iyl,$FF
L_F314:
        inc iyl
L_F315:
        ld hl,Z_F2
        ld e,iyl
        ld (hl),e
L_F317:
        ld hl,Z_F3
        ld e,(hl)
        ld iyl,e
L_F319:
        dec iyl
L_F31A:
        jp m,L_F35C
L_F31C:
        ld hl,Z_F4
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F31E:
        jp z,L_F35C
L_F320:
        ld b,a
        ld a,iyl
        cp $20
        ld a,b
        ccf
L_F322:
        jp nc,L_F35D
L_F324:
        ld a,$20
L_F326:
        ld (Z_F4),a
L_F328:
        ld a,$FF
L_F32A:
        ld (Z_E3),a
L_F32C:
        ld iyl,$09
L_F32E:
        ld hl,Z_D6
        ld e,(hl)
        ld b,a
        ld a,iyl
        cp e
        ld a,b
L_F330:
        jp nz,L_F354
L_F332:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_F334:
        ld hl,Z_83
        ld d,(hl)
L_F336:
        bit 6,d
        jp nz,L_F354
L_F338:
        ld a,(Z_86)
L_F33A:
        ld hl,Z_8A
        or (hl)
L_F33C:
        sla a
L_F33D:
        jp m,L_F345
L_F33F:
        dec ixl
L_F340:
        dec ixl
L_F341:
        ld hl,Z_D5
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F343:
        jp z,L_F3B9
L_F345:
        ld a,(Z_87)
L_F347:
        ld hl,Z_8B
        or (hl)
L_F349:
        sla a
L_F34A:
        jp m,L_F354
L_F34C:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_F34E:
        inc ixl
L_F34F:
        inc ixl
L_F350:
        ld hl,Z_D5
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F352:
        jp z,L_F3B9
L_F354:
        ld hl,Z_D4
        inc (hl)
L_F356:
        ld iyl,$FE
L_F358:
        ld hl,Z_D8
        ld e,iyl
        ld (hl),e
L_F35A:
        ld hl,Z_D6
        ld e,iyl
        ld (hl),e
L_F35C:
        ret
L_F35D:
        ld a,(Z_D4)
        inc a
        dec a
L_F35F:
        jp m,L_F35C
L_F361:
        ld hl,Z_DA
        ld e,(hl)
        ld ixl,e
L_F363:
        ld hl,Z_D9
        ld e,(hl)
        ld iyl,e
L_F365:
        ld a,(Z_E3)
        inc a
        dec a
L_F367:
        jp m,L_F379
L_F369:
        ld hl,Z_F7
        ld e,(hl)
        ld ixl,e
L_F36B:
        ld a,ixl
        inc a
        dec a
L_F36C:
        jp m,L_F3BF
L_F36E:
        ld hl,Z_DA
        ld e,(hl)
        ld iyl,e
L_F370:
        call L_FE62
L_F373:
        ld hl,Z_D9
        ld e,(hl)
        ld ixl,e
L_F375:
        ld hl,Z_F7
        ld e,(hl)
        ld b,a
        ld a,iyl
        cp e
        ld a,b
        ccf
L_F377:
        jp z,L_F383
L_F379:
        ld a,(iy-128)
L_F37C:
        jr nc,LC_F37C_0
        and $F0
        scf
        jr LC_F37C_1
LC_F37C_0:
        and $F0
LC_F37C_1:
L_F37E:
        ld hl,Z_DB
        jr nc,LC_F37E_0
        or (hl)
        scf
        jr LC_F37E_1
LC_F37E_0:
        or (hl)
LC_F37E_1:
L_F380:
        ld (iy-128),a
L_F383:
        call L_FE62
L_F386:
        call L_FA95
L_F389:
        ld hl,Z_E3
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F38B:
        jp p,L_F3C3
L_F38D:
        ld a,(Z_D4)
L_F38F:
        ld hl,Z_D9
        cp (hl)
        ccf
L_F391:
        jp nz,L_F3B7
L_F393:
        ld a,(Z_D5)
L_F395:
        ld hl,Z_DA
        cp (hl)
L_F397:
        jp nz,L_F3E6
L_F399:
        ld hl,Z_D6
        ld e,(hl)
        ld ixl,e
L_F39B:
        ld b,a
        ld a,ixl
        cp $06
        ld a,b
L_F39D:
        jp nz,L_F3B1
L_F39F:
        ld hl,Z_D8
        ld e,(hl)
        ld ixl,e
L_F3A1:
        ld b,a
        ld a,ixl
        cp $08
        ld a,b
        ccf
L_F3A3:
        jp c,L_F3B9
L_F3A5:
        ld b,a
        ld a,ixl
        cp $04
        ld a,b
        ccf
L_F3A7:
        ld a,(Z_DC)
        inc a
        dec a
L_F3A9:
        jp c,L_F3AF
L_F3AB:
        jp nz,L_F3B7
L_F3AD:
        jp z,L_F3B9
L_F3AF:
        jp z,L_F3B7
L_F3B1:
        ld a,(Z_DC)
L_F3B3:
        cp $07
        ccf
L_F3B5:
        jp nc,L_F3B9
L_F3B7:
        ld hl,Z_F5
        ld e,iyl
        ld (hl),e
L_F3B9:
        ld iyl,$01
L_F3BB:
        ld hl,Z_E3
        ld e,iyl
        ld (hl),e
L_F3BD:
        ld a,$40
        inc a
        dec a
L_F3BF:
        ld (Z_D4),a
L_F3C1:
        jp nz,L_F356
L_F3C3:
        ld hl,Z_F7
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_F3C5:
        jp m,L_F3CC
L_F3C7:
        ld a,$09
L_F3C9:
        call L_FE64
L_F3CC:
        ld hl,Z_D5
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
L_F3CE:
        jp nz,L_F3E6
L_F3D0:
        ld hl,Z_D8
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F3D2:
        jp m,L_F3E6
L_F3D4:
        ld a,$06
L_F3D6:
        ld hl,Z_D6
        cp (hl)
L_F3D8:
        jp nz,L_F3DE
L_F3DA:
        ld b,a
        ld a,iyl
        cp $04
        ld a,b
        ccf
L_F3DC:
        jp nc,L_F3E6
L_F3DE:
        ld iyl,$FE
L_F3E0:
        ld hl,Z_F5
        ld e,iyl
        ld (hl),e
L_F3E2:
        ld hl,Z_F6
        ld e,iyl
        ld (hl),e
L_F3E4:
        ld hl,Z_D4
        ld e,iyl
        ld (hl),e
L_F3E6:
        ret
L_F3E7:
        call L_F53C
L_F3EA:
        ld a,(Z_F3)
        inc a
        dec a
L_F3EC:
        jp z,L_F3F5
L_F3EE:
        ld hl,Z_DA
        ld e,(hl)
        ld ixl,e
L_F3F0:
        ld a,(Z_DC)
L_F3F2:
        call L_FE64
L_F3F5:
        ld hl,Z_D9
        ld e,(hl)
        ld ixl,e
L_F3F7:
        ld a,(Z_DB)
L_F3F9:
        call L_FE64
L_F3FC:
        ld hl,Z_F7
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_F3FE:
        jp m,L_F405
L_F400:
        ld a,$09
L_F402:
        call L_FE64
L_F405:
        ld hl,Z_F4
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F407:
        jp z,L_F41C
L_F409:
        ld hl,Z_F4
        dec (hl)
L_F40B:
        jp nz,L_F41B
L_F40D:
        ld hl,Z_F3
        ld e,(hl)
        ld ixl,e
L_F40F:
        dec ixl
L_F410:
        jp m,L_F3E6
L_F412:
        ld a,(Z_D4)
        inc a
        dec a
L_F414:
        jp p,L_F419
L_F416:
        jp L_F1DC
L_F419:
        ld hl,Z_F4
        ld e,iyl
        ld (hl),e
L_F41B:
        ret
L_F41C:
        ld hl,Z_F3
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F41E:
        jp p,L_F46C
L_F420:
        push af
        bit 6,d
        jr nz,LB_F420
        pop af
        jp L_F468
LB_F420:
        pop af
L_F422:
        call L_F1DC
L_F425:
        ld ixl,a
L_F426:
        ld a,(Z_D6)
L_F428:
        call L_FE64
L_F42B:
        call L_FD91
L_F42E:
        ld hl,Z_EA
        ld e,(hl)
        ld iyl,e
L_F430:
        ld a,(Z_CC)
L_F432:
        ld hl,Z_E2
        ld d,(hl)
L_F434:
        cp $55
        ccf
L_F436:
        jp c,L_F439
L_F438:
        res 6,d          ; V do 6502 mora no bit 6 de D
L_F439:
        ld hl,Z_E2
        jr nc,LC_F439_0
        and (hl)
        scf
        jr LC_F439_1
LC_F439_0:
        and (hl)
LC_F439_1:
L_F43B:
        ld hl,Z_CA
        jr nc,LC_F43B_0
        and (hl)
        scf
        jr LC_F43B_1
LC_F43B_0:
        and (hl)
LC_F43B_1:
L_F43D:
        call GetP        ; PHP+PLA: A = P do 6502 (N V 1 B D I Z C)
L_F43E:
L_F43F:
        ld (Z_E2),a
L_F441:
        push af
        ld a,iyl
        add a,$F5
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        ld a,(hl)
L_F444:
        jp c,L_F448
L_F446:
        adc a,$12
L_F448:
        ld hl,Z_E2
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F44A:
        push af
        bit 6,d
        jr nz,LB_F44A
        pop af
        jp L_F44E
LB_F44A:
        pop af
L_F44C:
        ld a,$12
        inc a
        dec a
L_F44E:
        jp m,L_F452
L_F450:
        adc a,$10
        jp pe,LV_F450_1
        res 6,d
        jr LV_F450_2
LV_F450_1:
        set 6,d
LV_F450_2:
L_F452:
        ld iyl,a
L_F453:
        and $0F
L_F455:
        ld (Z_D2),a
L_F457:
        ld a,iyl
L_F458:
        srl a
L_F459:
        srl a
L_F45A:
        srl a
L_F45B:
        srl a
L_F45C:
        ld (Z_D9),a
L_F45E:
        pop hl           ; PLA PLA: descarta o endereco de retorno (sai da sub-rotina)
L_F45F:
L_F460:
        ld hl,Z_B7
        rl (hl)
L_F462:
        or a
L_F463:
        ld hl,Z_B7
        rr (hl)
L_F465:
        jp L_F574
L_F468:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_F46A:
        ld hl,Z_D8
        ld e,ixl
        ld (hl),e
L_F46C:
        ld a,(inINPT4)
L_F46E:
        ld ixl,a
L_F46F:
        ld hl,Z_E6
        jr nc,LC_F46F_0
        xor (hl)
        scf
        jr LC_F46F_1
LC_F46F_0:
        xor (hl)
LC_F46F_1:
L_F471:
        ld hl,Z_E6
        jr nc,LC_F471_0
        and (hl)
        scf
        jr LC_F471_1
LC_F471_0:
        and (hl)
LC_F471_1:
L_F473:
        ld hl,Z_E6
        ld e,ixl
        ld (hl),e
L_F475:
        jp p,L_F4D6
L_F477:
        ld a,$04
L_F479:
        call L_F1E6
L_F47C:
        ld hl,inSWCHB
        ld d,(hl)
L_F47F:
        ld a,(Z_D6)
L_F481:
        bit 6,d
        jp nz,L_F497
L_F483:
        ld ixl,a
L_F484:
        ld a,(Z_F3)
        or a
L_F486:
        jp nz,L_F4BE
L_F488:
        ld b,a
        ld a,ixl
        cp $09
        ld a,b
        ccf
L_F48A:
        jp nc,L_F4D6
L_F48C:
        ld (Z_D7),a
L_F48E:
        ld a,(Z_D8)
L_F490:
        ld (Z_D5),a
L_F492:
        ld hl,Z_F3
        inc (hl)
L_F494:
        ret
L_F495:
        ld hl,Z_E4
        inc (hl)
L_F497:
        or a
L_F498:
        adc a,$01
        jp pe,LV_F498_1
        res 6,d
        jr LV_F498_2
LV_F498_1:
        set 6,d
LV_F498_2:
L_F49A:
        cp $08
L_F49C:
        jp z,L_F497
L_F49E:
        cp $07
L_F4A0:
        jp z,L_F497
L_F4A2:
        cp $0F
L_F4A4:
        jp z,L_F495
L_F4A6:
        and $0F
L_F4A8:
        ld (Z_D6),a
L_F4AA:
        ld ixl,$C0
L_F4AC:
        ld hl,Z_E2
        ld e,ixl
        ld (hl),e
L_F4AE:
        ld hl,Z_E5
        ld e,ixl
        ld (hl),e
L_F4B0:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_F4B2:
        ld hl,Z_D5
        ld e,ixl
        ld (hl),e
L_F4B4:
        ld hl,Z_D8
        ld e,ixl
        ld (hl),e
L_F4B6:
        call L_FE4B
L_F4B9:
        ld a,$00
L_F4BB:
        ld (Z_F3),a
L_F4BD:
        ret
L_F4BE:
        ld a,(Z_D4)
L_F4C0:
        ld hl,Z_D5
        cp (hl)
L_F4C2:
        jp z,L_F4B9
L_F4C4:
        ld a,(Z_F5)
        or a
L_F4C6:
        jp z,L_F4CD
L_F4C8:
        ld a,$0F
L_F4CA:
        ld (Z_E7),a
L_F4CC:
        ret
L_F4CD:
        ld a,$C0
L_F4CF:
        ld (Z_F3),a
L_F4D1:
        ld (Z_F4),a
L_F4D3:
        jp L_F13E
L_F4D6:
        ld a,(inSWCHA)
L_F4D9:
        cp $F0
        ccf
L_F4DB:
        jp c,L_F53B
L_F4DD:
        ld hl,Z_ED
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F4DF:
        jp p,L_F4E3
L_F4E1:
        jr nc,LC_F4E1_0
        xor $C0
        scf
        jr LC_F4E1_1
LC_F4E1_0:
        xor $C0
LC_F4E1_1:
L_F4E3:
        ld (Z_E9),a
L_F4E5:
        call L_F1E6
L_F4E8:
        ld a,(Z_D8)
L_F4EA:
        ld ixl,$03
L_F4EC:
        ld hl,Z_E9
        sla (hl)
L_F4EE:
        jp c,L_F4F3
L_F4F0:
        push af
        ld a,ixl
        add a,$7E
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        adc a,(hl)
        jp pe,LV_F4F0_1
        res 6,d
        jr LV_F4F0_2
LV_F4F0_1:
        set 6,d
LV_F4F0_2:
L_F4F3:
        dec ixl
L_F4F4:
        jp p,L_F4EC
L_F4F6:
        and $3F
L_F4F8:
        ld hl,Z_D8
        ld e,(hl)
        ld ixl,e
L_F4FA:
        ld (Z_D8),a
L_F4FC:
        ld iyl,a
L_F4FD:
        ld a,(Z_F3)
L_F4FF:
        srl a
L_F500:
        ld a,(ix-128)
L_F502:
        jr nc,LC_F502_0
        and $F0
        scf
        jr LC_F502_1
LC_F502_0:
        and $F0
LC_F502_1:
L_F504:
        jp c,L_F50E
L_F506:
        ld hl,Z_D4
        ld e,iyl
        ld (hl),e
L_F508:
        ld hl,Z_D6
        jr nc,LC_F508_0
        or (hl)
        scf
        jr LC_F508_1
LC_F508_0:
        or (hl)
LC_F508_1:
L_F50A:
        ld (ix-128),a
L_F50C:
        jp nc,L_F519
L_F50E:
        ld hl,Z_D7
        jr nc,LC_F50E_0
        or (hl)
        scf
        jr LC_F50E_1
LC_F50E_0:
        or (hl)
LC_F50E_1:
L_F510:
        ld hl,Z_D5
        ld e,iyl
        ld (hl),e
L_F512:
        ld (ix-128),a
L_F514:
        ld a,iyl
L_F515:
        ld hl,Z_D4
        jr nc,LC_F515_0
        xor (hl)
        scf
        jr LC_F515_1
LC_F515_0:
        xor (hl)
LC_F515_1:
L_F517:
        jp z,L_F522
L_F519:
        ld a,(iy-128)
L_F51C:
        jr nc,LC_F51C_0
        and $0F
        scf
        jr LC_F51C_1
LC_F51C_0:
        and $0F
LC_F51C_1:
L_F51E:
        jp c,L_F522
L_F520:
        ld (Z_D6),a
L_F522:
        ld (Z_D7),a
L_F524:
        ld ixl,$00
L_F526:
        ld hl,Z_F1
        ld e,ixl
        ld (hl),e
L_F528:
        ld hl,Z_F0
        ld e,ixl
        ld (hl),e
L_F52A:
        ld a,$20
L_F52C:
        ld (Z_F4),a
L_F52E:
        ld hl,Z_F5
        ld e,ixl
        ld (hl),e
L_F530:
        ld hl,Z_F6
        ld e,ixl
        ld (hl),e
L_F532:
        ld ixl,$05
L_F534:
        ld a,(ix-45)
L_F536:
        ld (ix-40),a
L_F538:
        dec ixl
L_F539:
        jp nz,L_F534
L_F53B:
        ret
L_F53C:
        ld hl,Z_F4
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_F53E:
        jp nz,L_F544
L_F540:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_F542:
        jp p,L_F532
L_F544:
        ret
L_F545:
        ld hl,Z_ED
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F547:
L_F54A:
        jp p,L_F573
L_F54C:
        ld ixl,$3F
L_F54E:
        ld a,ixl
L_F54F:
        jr nc,LC_F54F_0
        xor $07
        scf
        jr LC_F54F_1
LC_F54F_0:
        xor $07
LC_F54F_1:
L_F551:
        ld iyl,a
L_F552:
        ld a,(iy-128)
L_F555:
        jr nc,LC_F555_0
        and $0F
        scf
        jr LC_F555_1
LC_F555_0:
        and $0F
LC_F555_1:
L_F557:
        ld (Z_F8),a
L_F559:
        ld a,(ix-128)
L_F55B:
        jr nc,LC_F55B_0
        and $0F
        scf
        jr LC_F55B_1
LC_F55B_0:
        and $0F
LC_F55B_1:
L_F55D:
        ld (Z_F9),a
L_F55F:
        jr nc,LC_F55F_0
        xor (ix-128)
        scf
        jr LC_F55F_1
LC_F55F_0:
        xor (ix-128)
LC_F55F_1:
L_F561:
        ld hl,Z_F8
        jr nc,LC_F561_0
        or (hl)
        scf
        jr LC_F561_1
LC_F561_0:
        or (hl)
LC_F561_1:
L_F563:
        ld (ix-128),a
L_F565:
        ld a,(iy-128)
L_F568:
        jr nc,LC_F568_0
        and $F0
        scf
        jr LC_F568_1
LC_F568_0:
        and $F0
LC_F568_1:
L_F56A:
        ld hl,Z_F9
        jr nc,LC_F56A_0
        or (hl)
        scf
        jr LC_F56A_1
LC_F56A_0:
        or (hl)
LC_F56A_1:
L_F56C:
        ld (iy-128),a
L_F56F:
        dec ixl
L_F570:
        dec ixl
L_F571:
        jp p,L_F54E
L_F573:
        ret
L_F574:
        ld a,$00
L_F576:
L_F578:
        ld (Z_DC),a
L_F57A:
        ld (Z_E1),a
L_F57C:
        ld (Z_E0),a
L_F57E:
        ld (Z_D1),a
L_F580:
        ld (Z_D0),a
L_F582:
        ld ixl,$01
L_F584:
        ld hl,Z_DE
        ld e,ixl
        ld (hl),e
L_F586:
        ld hl,Z_C0
        ld e,ixl
        ld (hl),e
L_F588:
        ld a,$FF
L_F58A:
        ld hl,Z_E3
        ld e,ixl
        ld (hl),e
L_F58C:
        dec ixl
L_F58D:
        ld hl,Z_DA
        ld e,ixl
        ld (hl),e
L_F58F:
        ld (Z_DD),a
L_F591:
        ld (Z_DF),a
L_F593:
        ld (Z_CE),a
L_F595:
        ld (Z_CF),a
L_F597:
        ld a,$BF
L_F599:
        ld hl,Z_80
        jr nc,LC_F599_0
        and (hl)
        scf
        jr LC_F599_1
LC_F599_0:
        and (hl)
LC_F599_1:
L_F59B:
        ld (Z_80),a
L_F59D:
        ld a,$3F
L_F59F:
        ld hl,Z_B8
        jr nc,LC_F59F_0
        and (hl)
        scf
        jr LC_F59F_1
LC_F59F_0:
        and (hl)
LC_F59F_1:
L_F5A1:
        ld (Z_B8),a
L_F5A3:
        ld hl,Z_D0
        ld e,ixl
        ld (hl),e
L_F5A5:
        ld a,(Z_D1)
        inc a
        dec a
L_F5A7:
        jp z,L_F5D5
L_F5A9:
        jp L_F64E
L_F5AC:
        ld hl,Z_D0
        inc (hl)
L_F5AE:
        ld hl,Z_B8
        ld d,(hl)
L_F5B0:
        push af
        bit 6,d
        jr z,LB_F5B0
        pop af
        jp L_F5CF
LB_F5B0:
        pop af
L_F5B2:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F5B4:
        dec ixl
L_F5B5:
        jp z,L_F5BB
L_F5B7:
        ld hl,Z_D1
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F5B9:
        jp nz,L_F5CF
L_F5BB:
        ld a,(Z_B8)
L_F5BD:
        jr nc,LC_F5BD_0
        and $3F
        scf
        jr LC_F5BD_1
LC_F5BD_0:
        and $3F
LC_F5BD_1:
L_F5BF:
        jr nc,LC_F5BF_0
        or $80
        scf
        jr LC_F5BF_1
LC_F5BF_0:
        or $80
LC_F5BF_1:
L_F5C1:
        ld (Z_B8),a
L_F5C3:
        ld a,(Z_E3)
L_F5C5:
        jr nc,LC_F5C5_0
        xor $7C
        scf
        jr LC_F5C5_1
LC_F5C5_0:
        xor $7C
LC_F5C5_1:
L_F5C7:
        ld (Z_E7),a
L_F5C9:
        ld a,$00
        inc a
        dec a
L_F5CB:
        ld (Z_E6),a
L_F5CD:
        jp z,L_F5D5
L_F5CF:
        ld a,(Z_E3)
L_F5D1:
        jr nc,LC_F5D1_0
        xor $FE
        scf
        jr LC_F5D1_1
LC_F5D1_0:
        xor $FE
LC_F5D1_1:
L_F5D3:
        ld (Z_E3),a
L_F5D5:
        ld a,(Z_B4)
L_F5D7:
        jr nc,LC_F5D7_0
        and $7F
        scf
        jr LC_F5D7_1
LC_F5D7_0:
        and $7F
LC_F5D7_1:
L_F5D9:
        ld (Z_B4),a
L_F5DB:
        ld a,$40
L_F5DD:
        ld (Z_D4),a
L_F5DF:
        call L_FA66
L_F5E2:
        ld a,(Z_D4)
        inc a
        dec a
L_F5E4:
        jp m,L_F5E9
L_F5E6:
        jp L_F691
L_F5E9:
        ld a,$40
L_F5EB:
        ld (Z_D4),a
L_F5ED:
        ld hl,Z_B8
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F5EF:
        push af
        bit 6,d
        jr z,LB_F5EF
        pop af
        jp L_F664
LB_F5EF:
        pop af
L_F5F1:
        jp m,L_F657
L_F5F3:
        ld a,(Z_D0)
        or a
L_F5F5:
        jp z,L_F606
L_F5F7:
        ld hl,Z_D1
        cp (hl)
        ccf
L_F5F9:
        jp z,L_F600
L_F5FB:
        jp nc,L_F600
L_F5FD:
        jp L_F8C6
L_F600:
        ld hl,Z_B4
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F602:
        jp p,L_F66D
L_F604:
        jp m,L_F5FD
L_F606:
        ld hl,Z_B4
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F608:
        jp p,L_F66D
L_F60A:
        ld hl,Z_80
        ld d,(hl)
L_F60C:
        bit 6,d
        jp nz,L_F611
L_F60E:
        jp L_F9F5
L_F611:
        ld a,(Z_ED)
L_F613:
        ld (Z_CE),a
L_F615:
        and $3F
L_F617:
        ld (Z_D4),a
L_F619:
        ld ixl,a
L_F61A:
        ld a,(Z_EE)
L_F61C:
        ld (Z_CF),a
L_F61E:
        ld (Z_D8),a
L_F620:
        ld a,(Z_DE)
L_F622:
        ld (Z_DF),a
L_F624:
        ld a,(ix-128)
L_F626:
        and $0F
L_F628:
        ld (Z_D6),a
L_F62A:
        call L_FB91
L_F62D:
        ld a,ixl
L_F62E:
        or a
L_F62F:
        jr nc,LC_F62F_0
        and $3C
        scf
        jr LC_F62F_1
LC_F62F_0:
        and $3C
LC_F62F_1:
L_F631:
        ld hl,Z_D5
        adc a,(hl)
L_F633:
        add a,a
L_F634:
L_F636:
        ld a,(ix-128)
L_F638:
        and $0F
L_F63A:
        ld hl,Z_D6
        ld e,(hl)
        ld ixl,e
L_F63C:
        ld b,a
        ld a,ixl
        cp $06
        ld a,b
L_F63E:
        jp nz,L_F64C
L_F640:
        ld hl,Z_D8
        ld e,(hl)
        ld ixl,e
L_F642:
        ld b,a
        ld a,ixl
        cp $08
        ld a,b
        ccf
L_F644:
        jp nc,L_F64C
L_F646:
        ld b,a
        ld a,ixl
        cp $0C
        ld a,b
        ccf
L_F648:
        jp c,L_F64C
L_F64A:
        ld a,$0E
L_F64C:
        ld (Z_D7),a
L_F64E:
        ld a,$BF
L_F650:
        ld hl,Z_81
        and (hl)
L_F652:
        ld (Z_81),a
L_F654:
        jp L_F6EA
L_F657:
        ld a,(Z_E3)
L_F659:
        jr nc,LC_F659_0
        xor $FE
        scf
        jr LC_F659_1
LC_F659_0:
        xor $FE
LC_F659_1:
L_F65B:
        ld (Z_E3),a
L_F65D:
        ld a,(Z_B8)
L_F65F:
        jr nc,LC_F65F_0
        or $C0
        scf
        jr LC_F65F_1
LC_F65F_0:
        or $C0
LC_F65F_1:
L_F661:
        jp L_F5C1
L_F664:
        ld a,(Z_B8)
L_F666:
        jr nc,LC_F666_0
        and $3F
        scf
        jr LC_F666_1
LC_F666_0:
        and $3F
LC_F666_1:
L_F668:
        ld (Z_B8),a
L_F66A:
        jp L_F5D5
L_F66D:
        ld hl,Z_B4
        sla (hl)
L_F66F:
        scf
L_F670:
        ld hl,Z_B4
        rr (hl)
L_F672:
        ld a,(Z_D0)
        inc a
        dec a
L_F674:
        jp nz,L_F67F
L_F676:
        ld a,(Z_82)
L_F678:
        ld hl,Z_85
        or (hl)
L_F67A:
        ld hl,Z_89
        or (hl)
L_F67C:
        sla a
L_F67D:
        jp p,L_F687
L_F67F:
        jp L_F5DB
L_F687:
        ld ixl,$04
L_F689:
        push af
        ld a,ixl
        add a,$82
        ld l,a
        adc a,$E6
        sub l
        ld h,a
        pop af
        ld a,(hl)
L_F68C:
        ld (ix-44),a
L_F68E:
        dec ixl
L_F68F:
        jp p,L_F689
L_F691:
        ld a,(Z_D0)
        or a
L_F693:
        jp nz,L_F6EA
L_F695:
        ld a,(Z_E0)
L_F697:
        ld hl,Z_D4
        cp (hl)
L_F699:
        jp nz,L_F6A1
L_F69B:
        ld a,(Z_E1)
L_F69D:
        ld hl,Z_D8
        cp (hl)
L_F69F:
        jp z,L_F6D1
L_F6A1:
        call L_FBB6
L_F6A4:
        ld hl,Z_DE
        ld e,(hl)
        ld ixl,e
L_F6A6:
        ld hl,Z_F0
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F6A8:
        jp c,L_F6D1
L_F6AA:
        ld ixl,a
L_F6AB:
        ld a,(Z_B4)
L_F6AD:
        xor $80
L_F6AF:
        and $80
L_F6B1:
        ld hl,Z_D4
        or (hl)
L_F6B3:
        ld hl,Z_D8
        ld e,(hl)
        ld iyl,e
L_F6B5:
        ld hl,Z_DF
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F6B7:
        jp nc,L_F6C5
L_F6B9:
        jp nz,L_F6D1
L_F6BB:
        ld hl,Z_CE
        cp (hl)
        ccf
L_F6BD:
        jp nc,L_F6C5
L_F6BF:
        jp nz,L_F6D1
L_F6C1:
        ld hl,Z_CF
        ld e,(hl)
        ld b,a
        ld a,iyl
        cp e
        ld a,b
        ccf
L_F6C3:
        jp c,L_F6D1
L_F6C5:
        ld hl,Z_DE
        ld e,ixl
        ld (hl),e
L_F6C7:
        ld (Z_ED),a
L_F6C9:
        ld hl,Z_EE
        ld e,iyl
        ld (hl),e
L_F6CB:
        ld a,(Z_80)
L_F6CD:
        or $40
L_F6CF:
        ld (Z_80),a
L_F6D1:
        ld a,(Z_D6)
L_F6D3:
        cp $01
L_F6D5:
        jp nz,L_F6DD
L_F6D7:
        ld a,(Z_D8)
L_F6D9:
        cp $08
        ccf
L_F6DB:
        jp c,L_F67F
L_F6DD:
        ld hl,Z_B4
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F6DF:
        jp m,L_F6E4
L_F6E1:
        call L_FD4D
L_F6E4:
        call L_FA95
L_F6E7:
        jp L_F5E2
L_F6EA:
        ld a,(Z_8C)
L_F6EC:
        and $BF
L_F6EE:
        ld hl,Z_D6
        ld e,(hl)
        ld iyl,e
L_F6F0:
        ld b,a
        ld a,iyl
        cp $06
        ld a,b
L_F6F2:
        jp nz,L_F6FC
L_F6F4:
        ld hl,Z_D8
        ld e,(hl)
        ld iyl,e
L_F6F6:
        ld b,a
        ld a,iyl
        cp $0C
        ld a,b
        ccf
L_F6F8:
        jp nc,L_F6FC
L_F6FA:
        or $40
L_F6FC:
        ld (Z_8C),a
L_F6FE:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_F700:
        ld a,(ix-128)
L_F702:
        and $0F
L_F704:
        ld (Z_EB),a
L_F706:
        ld hl,Z_B8
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F708:
        jp p,L_F782
L_F70A:
        ld hl,Z_D7
        ld e,(hl)
        ld iyl,e
L_F70C:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F70E:
        ld b,a
        ld a,iyl
        cp $09
        ld a,b
L_F710:
        jp nz,L_F71C
L_F712:
        ld b,a
        ld a,ixl
        cp $01
        ld a,b
L_F714:
        jp nz,L_F71C
L_F716:
        ld a,$40
L_F718:
        ld hl,Z_81
        or (hl)
L_F71A:
        ld (Z_81),a
L_F71C:
        dec ixl
L_F71D:
        ld hl,Z_D1
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F71F:
        jp nz,L_F775
L_F721:
        inc ixl
L_F722:
        ld b,a
        ld a,iyl
        cp $01
        ld a,b
        ccf
L_F724:
        jp nz,L_F72E
L_F726:
        ld a,(Z_DA)
L_F728:
        ccf
        sbc a,$01
        ccf
L_F72A:
        xor $80
L_F72C:
        ld (ix-64),a
L_F72E:
        ld hl,Z_D7
        ld e,(hl)
        ld ixl,e
L_F730:
        ld hl,Z_EB
        ld e,(hl)
        ld iyl,e
L_F732:
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        ld a,(hl)
L_F735:
        or a
L_F736:
        push af
        ld a,ixl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        adc a,(hl)
        jp pe,LV_F736_1
        res 6,d
        jr LV_F736_2
LV_F736_1:
        set 6,d
LV_F736_2:
L_F739:
        jp z,L_F768
L_F73B:
        ld iyl,a
L_F73C:
        ld ixl,a
L_F73D:
        call L_FD81
L_F740:
        rl a
L_F741:
        jp m,L_F768
L_F743:
        jp c,L_F747
L_F745:
        ld hl,Z_E6
        inc (hl)
L_F747:
        ld (Z_EC),a
L_F749:
        ld hl,Z_E7
        ld e,(hl)
        ld iyl,e
L_F74B:
        call L_FD81
L_F74E:
        rla
L_F74F:
        ld hl,Z_EC
        cp (hl)
        ccf
L_F751:
        jp c,L_F755
L_F753:
        ld hl,Z_E7
        ld e,ixl
        ld (hl),e
L_F755:
        ld a,$01
L_F757:
        ld hl,Z_E6
        cp (hl)
        ccf
L_F759:
        jp nc,L_F76B
L_F75B:
        ld a,(Z_D6)
L_F75D:
        cp $03
L_F75F:
        jp nz,L_F764
L_F761:
        jp L_F6E4
L_F764:
        cp $05
L_F766:
        jp z,L_F761
L_F768:
        jp L_F6E1
L_F76B:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F76D:
        ld a,(Z_DA)
L_F76F:
        ld hl,Z_E7
        adc a,(hl)
L_F771:
        jr nc,LC_F771_0
        xor $80
        scf
        jr LC_F771_1
LC_F771_0:
        xor $80
LC_F771_1:
L_F773:
        ld (ix-64),a
L_F775:
        ld hl,Z_B8
        ld d,(hl)
L_F777:
        push af
        bit 6,d
        jr z,LB_F777
        pop af
        jp L_F77F
LB_F777:
        pop af
L_F779:
        ld a,(Z_E3)
L_F77B:
        jr nc,LC_F77B_0
        xor $FE
        scf
        jr LC_F77B_1
LC_F77B_0:
        xor $FE
LC_F77B_1:
L_F77D:
        ld (Z_E3),a
L_F77F:
        jp L_F664
L_F782:
        ld hl,Z_D7
        ld e,(hl)
        ld iyl,e
L_F784:
        ld a,(Z_DA)
L_F786:
        or a
L_F787:
        push af
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        adc a,(hl)
L_F78A:
        ld (Z_DB),a
L_F78C:
        ld hl,Z_8C
        ld d,(hl)
L_F78E:
        bit 6,d
        jp z,L_F7A9
L_F790:
        ld a,(Z_E3)
L_F792:
        add a,a
L_F793:
        jr nc,LC_F793_0
        and $08
        scf
        jr LC_F793_1
LC_F793_0:
        and $08
LC_F793_1:
L_F795:
        jr nc,LC_F795_0
        xor $0A
        scf
        jr LC_F795_1
LC_F795_0:
        xor $0A
LC_F795_1:
L_F797:
        ld iyl,a
L_F798:
        ld a,$05
L_F79A:
        jp c,L_F79E
L_F79C:
        ld a,$FA
L_F79E:
        ld hl,Z_DB
        adc a,(hl)
L_F7A0:
        or a
L_F7A1:
        ld hl,Z_D0
        ccf
        sbc a,(hl)
        ccf
L_F7A3:
        or a
L_F7A4:
        push af
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        adc a,(hl)
L_F7A7:
        ld (Z_DB),a
L_F7A9:
        ld a,(Z_D7)
L_F7AB:
        and $07
L_F7AD:
        cp $01
L_F7AF:
        jp nz,L_F7C1
L_F7B1:
        ld a,(Z_E3)
L_F7B3:
        add a,a
L_F7B4:
        ld a,(Z_D0)
L_F7B6:
        jp c,L_F7BA
L_F7B8:
        jr nc,LC_F7B8_0
        xor $FF
        scf
        jr LC_F7B8_1
LC_F7B8_0:
        xor $FF
LC_F7B8_1:
L_F7BA:
        adc a,$00
L_F7BC:
        ld (Z_E9),a
L_F7BE:
        jp L_F9EC
L_F7C1:
        ld hl,Z_E2
        ld d,(hl)
L_F7C3:
        bit 6,d
        jp z,L_F7DF
L_F7C5:
        ld a,$01
L_F7C7:
        call L_FE71
L_F7CA:
        ld a,ixl
L_F7CB:
        ld iyl,a
L_F7CC:
        call L_FE6F
L_F7CF:
        ld a,iyl
L_F7D0:
        call L_FE9C
L_F7D3:
        ld (Z_DC),a
L_F7D5:
        ld a,$1B
L_F7D7:
        call L_FE9C
L_F7DA:
        add a,a
L_F7DB:
        ld hl,Z_DC
        ccf
        sbc a,(hl)
        ccf
L_F7DD:
        ld (Z_DC),a
L_F7DF:
        ld a,(Z_E3)
L_F7E1:
        xor $FE
L_F7E3:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F7E5:
        ld (ix-63),a
L_F7E7:
        ld hl,Z_D1
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F7E9:
        jp nc,L_F7F4
L_F7EB:
        ld a,(Z_DB)
L_F7ED:
        or a
L_F7EE:
        ld hl,Z_DC
        adc a,(hl)
L_F7F0:
        xor $80
L_F7F2:
        ld (ix-63),a
L_F7F4:
        ld hl,Z_D1
        ld e,(hl)
        ld ixl,e
L_F7F6:
        ld hl,Z_D0
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F7F8:
        jp c,L_F821
L_F7FA:
        ld hl,Z_D2
        ld e,(hl)
        ld ixl,e
L_F7FC:
        ld hl,Z_D0
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_F7FE:
        jp c,L_F817
L_F800:
        ld a,(Z_D5)
L_F802:
        ld hl,Z_DD
        cp (hl)
L_F804:
        jp z,L_F817
L_F806:
        ld hl,Z_EB
        ld e,(hl)
        ld iyl,e
L_F808:
        call L_FD65
L_F80B:
        jp p,L_F817
L_F80D:
        ld a,(Z_D7)
        or a
L_F80F:
        jp z,L_F817
L_F811:
        jp L_F6E1
L_F814:
        jp L_F97A
L_F817:
        ld a,(Z_D0)
L_F819:
        cp $0C
L_F81B:
        jp z,L_F814
L_F81D:
        ld a,(Z_D5)
L_F81F:
        ld (Z_DD),a
L_F821:
        ld a,(Z_D0)
L_F823:
        or a
L_F824:
        adc a,$1A
L_F826:
        ld ixl,a
L_F827:
        ld a,(Z_D4)
L_F829:
        ld iyl,a
        inc iyl
        dec iyl
L_F82A:
        jp p,L_F836
L_F82C:
        ld ixl,a
L_F82D:
        ld a,(Z_D7)
L_F82F:
        ld hl,Z_D0
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
L_F831:
        jp nz,L_F836
L_F833:
        ld a,(iy-128)
L_F836:
        add a,a
L_F837:
        add a,a
L_F838:
        add a,a
L_F839:
        add a,a
L_F83A:
        ld (Z_FB),a
L_F83C:
        ld a,(ix-115)
L_F83E:
        and $0F
L_F840:
        ld hl,Z_FB
        or (hl)
L_F842:
        ld (ix-115),a
L_F844:
        ld a,ixl
L_F845:
        scf
L_F846:
        ccf
        sbc a,$0D
        ccf
        jp pe,LV_F846_1
        res 6,d
        jr LV_F846_2
LV_F846_1:
        set 6,d
LV_F846_2:
L_F848:
        jp p,L_F82C
L_F84A:
        ld a,(Z_D8)
L_F84C:
        ld (ix-17),a
L_F84E:
        ld a,(ix-128)
L_F850:
        and $4F
L_F852:
        ld (ix-128),a
L_F854:
        ld a,(Z_B4)
L_F856:
        and $80
L_F858:
        ld hl,Z_D4
        or (hl)
L_F85A:
        and $B0
L_F85C:
        or (ix-128)
L_F85E:
        ld (ix-128),a
L_F860:
        ld a,ixl
        or a
L_F861:
        jp nz,L_F877
L_F863:
        ld a,(iy-128)
L_F866:
        and $0F
L_F868:
        ld (Z_D6),a
L_F86A:
        srl a
L_F86B:
        jp nz,L_F877
L_F86D:
        ld a,(Z_D8)
L_F86F:
        ld iyl,$07
L_F871:
        ld ixl,$05
L_F873:
        cp $08
        ccf
L_F875:
        jp z,L_F88B
L_F877:
        ld a,(Z_D6)
L_F879:
        cp $06
        ccf
L_F87B:
        jp nz,L_F88E
L_F87D:
        ld a,(Z_D8)
L_F87F:
        cp $08
        ccf
L_F881:
        jp nc,L_F88E
L_F883:
        cp $0C
        ccf
L_F885:
        jp c,L_F88E
L_F887:
        ld hl,Z_D5
        ld e,(hl)
        ld ixl,e
L_F889:
        ld hl,Z_E5
        ld e,(hl)
        ld iyl,e
L_F88B:
        call L_FD37
L_F88E:
        call L_FD33
L_F891:
        ld hl,Z_D7
        ld e,(hl)
        ld iyl,e
L_F893:
        ld a,(Z_DA)
L_F895:
        or a
L_F896:
        push af
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        adc a,(hl)
L_F899:
        ld (Z_DA),a
L_F89B:
        ld hl,Z_8C
        ld d,(hl)
L_F89D:
        push af
        bit 6,d
        jr nz,LB_F89D
        pop af
        jp L_F8C3
LB_F89D:
        pop af
L_F89F:
        ld a,(Z_E3)
L_F8A1:
        jr nc,LC_F8A1_0
        and $08
        scf
        jr LC_F8A1_1
LC_F8A1_0:
        and $08
LC_F8A1_1:
L_F8A3:
        jr nc,LC_F8A3_0
        or $02
        scf
        jr LC_F8A3_1
LC_F8A3_0:
        or $02
LC_F8A3_1:
L_F8A5:
        ld (Z_E9),a
L_F8A7:
        jr nc,LC_F8A7_0
        xor $08
        scf
        jr LC_F8A7_1
LC_F8A7_0:
        xor $08
LC_F8A7_1:
L_F8A9:
        ld iyl,a
L_F8AA:
        ld hl,Z_D5
        ld e,(hl)
        ld ixl,e
L_F8AC:
        call L_FD44
L_F8AF:
        ld a,$06
L_F8B1:
        ld hl,Z_E3
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F8B3:
        jp m,L_F8B7
L_F8B5:
        ld a,$FA
L_F8B7:
        or a
L_F8B8:
        ld hl,Z_DA
        adc a,(hl)
L_F8BA:
        or a
L_F8BB:
        ld hl,Z_D0
        ccf
        sbc a,(hl)
        ccf
L_F8BD:
        or a
L_F8BE:
        push af
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        adc a,(hl)
L_F8C1:
        ld (Z_DA),a
L_F8C3:
        jp L_F5AC
L_F8C6:
        ld hl,Z_D0
        dec (hl)
L_F8C8:
        ld a,(Z_E3)
L_F8CA:
        xor $FE
L_F8CC:
        ld (Z_E3),a
L_F8CE:
        ld a,$FF
L_F8D0:
        ld (Z_DD),a
L_F8D2:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F8D4:
        ld a,(ix-89)
L_F8D6:
        srl a
L_F8D7:
        srl a
L_F8D8:
        srl a
L_F8D9:
        srl a
L_F8DA:
        ld (Z_E9),a
L_F8DC:
        ld a,(ix-128)
L_F8DE:
        and $B0
L_F8E0:
        ld hl,Z_E9
        or (hl)
L_F8E2:
        ld hl,Z_B4
        sla (hl)
L_F8E4:
        add a,a
L_F8E5:
        ld hl,Z_B4
        rr (hl)
L_F8E7:
        srl a
L_F8E8:
        ld (Z_D4),a
L_F8EA:
        ld a,(ix-102)
L_F8EC:
        srl a
L_F8ED:
        srl a
L_F8EE:
        srl a
L_F8EF:
        srl a
L_F8F0:
        ld (Z_D7),a
L_F8F2:
        ld a,(ix-115)
L_F8F4:
        srl a
L_F8F5:
        srl a
L_F8F6:
        srl a
L_F8F7:
        srl a
L_F8F8:
        ld (Z_E9),a
L_F8FA:
        and $07
L_F8FC:
        ld (Z_D6),a
L_F8FE:
        ld e,(ix-17)
        ld iyl,e
L_F900:
        ld hl,Z_D8
        ld e,iyl
        ld (hl),e
L_F902:
        call L_FB91
L_F905:
        ld a,(ix-128)
L_F907:
        jr nc,LC_F907_0
        and $F0
        scf
        jr LC_F907_1
LC_F907_0:
        and $F0
LC_F907_1:
L_F909:
        ld hl,Z_D7
        jr nc,LC_F909_0
        or (hl)
        scf
        jr LC_F909_1
LC_F909_0:
        or (hl)
LC_F909_1:
L_F90B:
        ld (ix-128),a
L_F90D:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_F90F:
        call L_FD44
L_F912:
        ld hl,Z_D8
        ld e,(hl)
        ld ixl,e
L_F914:
        ld a,(Z_D6)
L_F916:
        ld b,a
        ld a,ixl
        cp $08
        ld a,b
        ccf
L_F918:
        jp nc,L_F940
L_F91A:
        jp nz,L_F928
L_F91C:
        ld hl,Z_D0
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_F91E:
        jp nz,L_F928
L_F920:
        ld iyl,$05
L_F922:
        dec ixl
L_F923:
        cp $01
        ccf
L_F925:
        jp z,L_F93D
L_F927:
        inc ixl
L_F928:
        cp $06
L_F92A:
        jp nz,L_F940
L_F92C:
        ld b,a
        ld a,ixl
        cp $0C
        ld a,b
        ccf
L_F92E:
        jp c,L_F940
L_F930:
        ld a,(Z_E3)
L_F932:
        add a,a
L_F933:
        add a,a
L_F934:
        add a,a
L_F935:
        xor $FF
L_F937:
        scf
L_F938:
        ld hl,Z_D5
        adc a,(hl)
        jp pe,LV_F938_1
        res 6,d
        jr LV_F938_2
LV_F938_1:
        set 6,d
LV_F938_2:
L_F93A:
        ld ixl,a
L_F93B:
        ld hl,Z_D5
        ld e,(hl)
        ld iyl,e
L_F93D:
        call L_FD37
L_F940:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F942:
        ld a,(ix-63)
L_F944:
        ld (Z_E9),a
L_F946:
        ld hl,Z_D7
        ld e,(hl)
        ld iyl,e
L_F948:
        ld a,(Z_DA)
L_F94A:
        scf
L_F94B:
        push af
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        ccf
        sbc a,(hl)
        ccf
        jp pe,LV_F94B_1
        res 6,d
        jr LV_F94B_2
LV_F94B_1:
        set 6,d
LV_F94B_2:
L_F94E:
        ld (Z_DA),a
L_F950:
        ld a,(Z_D6)
L_F952:
        cp $06
L_F954:
        jp nz,L_F983
L_F956:
        ld a,(Z_D8)
L_F958:
        cp $0C
        ccf
L_F95A:
        jp nc,L_F983
L_F95C:
        ld a,(Z_E3)
L_F95E:
        and $08
L_F960:
        xor $0A
L_F962:
        ld iyl,a
L_F963:
        ld a,$06
L_F965:
        ld hl,Z_E3
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_F967:
        jp p,L_F96B
L_F969:
        ld a,$FA
L_F96B:
        or a
L_F96C:
        ld hl,Z_DA
        adc a,(hl)
L_F96E:
        scf
L_F96F:
        ld hl,Z_D0
        adc a,(hl)
L_F971:
        scf
L_F972:
        push af
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        ccf
        sbc a,(hl)
        ccf
        jp pe,LV_F972_1
        res 6,d
        jr LV_F972_2
LV_F972_1:
        set 6,d
LV_F972_2:
L_F975:
        ld (Z_DA),a
L_F977:
        jp L_F983
L_F97A:
        ld a,(Z_DB)
L_F97C:
        or a
L_F97D:
        ld hl,Z_DC
        adc a,(hl)
        jp pe,LV_F97D_1
        res 6,d
        jr LV_F97D_2
LV_F97D_1:
        set 6,d
LV_F97D_2:
L_F97F:
        xor $80
L_F981:
        ld (Z_E9),a
L_F983:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F985:
        ld a,(Z_E3)
        or a
L_F987:
        jp m,L_F9B9
L_F989:
        ld a,ixl
        or a
L_F98A:
        jp nz,L_F9A1
L_F98C:
        ld a,(Z_E9)
L_F98E:
        cp $FD
        ccf
L_F990:
        jp nc,L_F99E
L_F992:
        ld hl,Z_E2
        ld d,(hl)
L_F994:
        bit 6,d
        jp z,L_F99E
L_F996:
        ld hl,Z_81
        ld d,(hl)
L_F998:
        bit 6,d
        jp nz,L_F99E
L_F99A:
        ld a,$03
L_F99C:
        ld (Z_E9),a
L_F99E:
        jp L_F9B1
L_F9A1:
        ld a,(ix-65)
L_F9A3:
        ld hl,Z_C1
        cp (hl)
        ccf
L_F9A5:
        jp z,L_F9AB
L_F9A7:
        jp nc,L_F9AB
L_F9A9:
        ld a,(Z_C1)
L_F9AB:
        ld hl,Z_E9
        cp (hl)
        ccf
L_F9AD:
        jp z,L_F9EC
L_F9AF:
        jp nc,L_F9EC
L_F9B1:
        ld a,(ix-64)
L_F9B3:
        ld hl,Z_E9
        cp (hl)
        ccf
L_F9B5:
        jp nc,L_F9CB
L_F9B7:
        jp c,L_F9DA
L_F9B9:
        ld a,(ix-65)
L_F9BB:
        ld hl,Z_C0
        cp (hl)
        ccf
L_F9BD:
        jp c,L_F9C1
L_F9BF:
        ld a,(Z_C0)
L_F9C1:
        ld hl,Z_E9
        cp (hl)
        ccf
L_F9C3:
        jp c,L_F9EC
L_F9C5:
        ld a,(Z_E9)
L_F9C7:
        cp (ix-64)
        ccf
L_F9C9:
        jp c,L_F9DA
L_F9CB:
        ld a,(Z_E9)
L_F9CD:
        ld (ix-64),a
L_F9CF:
        ld a,ixl
        inc a
        dec a
L_F9D0:
        jp nz,L_F9DA
L_F9D2:
        ld a,(Z_D4)
L_F9D4:
        ld (Z_E0),a
L_F9D6:
        ld a,(Z_D8)
L_F9D8:
        ld (Z_E1),a
L_F9DA:
        ld a,ixl
        inc a
        dec a
L_F9DB:
        jp z,L_F9E0
L_F9DD:
        jp L_F6DD
L_F9E0:
        ld a,(Z_80)
L_F9E2:
        jr nc,LC_F9E2_0
        and $BF
        scf
        jr LC_F9E2_1
LC_F9E2_0:
        and $BF
LC_F9E2_1:
L_F9E4:
        ld (Z_80),a
L_F9E6:
        inc ixl
L_F9E7:
        ld hl,Z_DE
        ld e,ixl
        ld (hl),e
L_F9E9:
        jp L_F5D5
L_F9EC:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
L_F9EE:
        ld a,(Z_E9)
L_F9F0:
        ld (ix-64),a
L_F9F2:
        jp L_F8C6
L_F9F5:
        ld hl,Z_E0
        ld e,(hl)
        ld ixl,e
L_F9F7:
        ld hl,Z_D4
        ld e,ixl
        ld (hl),e
L_F9F9:
        ld a,(Z_E1)
L_F9FB:
        ld (Z_D8),a
L_F9FD:
        ld a,(ix-128)
L_F9FF:
        and $07
L_FA01:
        ld (Z_D6),a
L_FA03:
        call L_FB91
L_FA06:
        ld hl,Z_B4
        sla (hl)
L_FA08:
        scf
L_FA09:
        ld hl,Z_B4
        rr (hl)
L_FA0B:
        ld a,(ix-128)
L_FA0D:
        and $0F
L_FA0F:
        ld hl,Z_D6
        ld e,(hl)
        ld ixl,e
L_FA11:
        ld b,a
        ld a,ixl
        cp $06
        ld a,b
        ccf
L_FA13:
        jp nz,L_FA21
L_FA15:
        ld hl,Z_D8
        ld e,(hl)
        ld ixl,e
L_FA17:
        ld b,a
        ld a,ixl
        cp $08
        ld a,b
        ccf
L_FA19:
        jp nc,L_FA21
L_FA1B:
        ld b,a
        ld a,ixl
        cp $0C
        ld a,b
        ccf
L_FA1D:
        jp c,L_FA21
L_FA1F:
        ld a,$0E
L_FA21:
        ld (Z_D7),a
L_FA23:
        ld hl,Z_D9
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_FA25:
        jp z,L_FA30
L_FA27:
        ld a,(Z_D1)
        inc a
        dec a
L_FA29:
        jp nz,L_FA30
L_FA2B:
        ld hl,Z_D1
        ld e,iyl
        ld (hl),e
L_FA2D:
        jp L_F582
L_FA30:
        ld hl,Z_E4
        inc (hl)
L_FA32:
        ld ixl,$1F
L_FA34:
        ld hl,Z_D0
        ld e,ixl
        ld (hl),e
L_FA36:
        ld e,ixl
        ld hl,T_AUDC0
        ld (hl),e
L_FA38:
        ld hl,Z_D4
        ld e,(hl)
        ld iyl,e
L_FA3A:
        ld ixl,$00
L_FA3C:
        ld a,(Z_C0)
L_FA3E:
        cp $03
        ccf
L_FA40:
        jp nc,L_FA4B
L_FA42:
        inc ixl
L_FA43:
        cp $FD
        ccf
L_FA45:
        jp c,L_FA4D
L_FA47:
        inc ixl
L_FA48:
        inc ixl
L_FA49:
        jp nz,L_FA4D
L_FA4B:
        ld hl,Z_D5
        ld e,iyl
        ld (hl),e
L_FA4D:
        ld hl,Z_EE
        ld e,ixl
        ld (hl),e
L_FA4F:
        ld hl,Z_D8
        ld e,iyl
        ld (hl),e
L_FA51:
        call L_F13E
L_FA54:
        call L_F524
L_FA57:
        ld a,$80
L_FA59:
        ld (Z_F3),a
L_FA5B:
        ld (Z_E7),a
L_FA5D:
        call L_FD91
L_FA60:
        call L_F3B9
L_FA63:
        ret
L_FA66:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_FA68:
        dec ixl
L_FA69:
        jp m,L_FAC8
L_FA6B:
        ld a,(ix-128)
L_FA6D:
        jr nc,LC_FA6D_0
        and $0F
        scf
        jr LC_FA6D_1
LC_FA6D_0:
        and $0F
LC_FA6D_1:
L_FA6F:
        jp z,L_FA68
L_FA71:
        ld hl,Z_E3
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_FA73:
        jp p,L_FA77
L_FA75:
        xor $08
L_FA77:
        cp $07
        ccf
L_FA79:
        jp c,L_FA68
L_FA7B:
        ld hl,Z_D4
        ld e,ixl
        ld (hl),e
L_FA7D:
        ld (Z_D6),a
L_FA7F:
        ld iyl,a
L_FA80:
        push af
        ld a,iyl
        add a,$EE
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        ld a,(hl)
L_FA83:
        ld b,a
        ld a,iyl
        cp $06
        ld a,b
        ccf
L_FA85:
        jp nz,L_FA8D
L_FA87:
        ld hl,Z_E3
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_FA89:
        jp p,L_FA8D
L_FA8B:
        adc a,$00
        jp pe,LV_FA8B_1
        res 6,d
        jr LV_FA8B_2
LV_FA8B_1:
        set 6,d
LV_FA8B_2:
L_FA8D:
        ld (Z_D8),a
L_FA8F:
        ld a,(Z_B7)
        inc a
        dec a
L_FA91:
        ld (Z_D5),a
L_FA93:
        jp m,L_FACA
L_FA95:
        ld a,(Z_D6)
L_FA97:
        cp $06
        ccf
L_FA99:
        jp z,L_FAD2
L_FA9B:
        ld hl,Z_D8
        dec (hl)
L_FA9D:
        jp m,L_FA66
L_FA9F:
        call L_FB91
L_FAA2:
        jp m,L_FACB
L_FAA4:
        ld a,(Z_B4)
L_FAA6:
        add a,a
L_FAA7:
        ld hl,Z_D6
        ld e,(hl)
        ld iyl,e
L_FAA9:
        ld a,(ix-128)
L_FAAB:
        jr nc,LC_FAAB_0
        and $0F
        scf
        jr LC_FAAB_1
LC_FAAB_0:
        and $0F
LC_FAAB_1:
L_FAAD:
        ld (Z_D7),a
L_FAAF:
        jp nz,L_FAB9
L_FAB1:
        jp c,L_FACA
L_FAB3:
        ld b,a
        ld a,iyl
        cp $06
        ld a,b
        ccf
L_FAB5:
        jp nz,L_FA9B
L_FAB7:
        jp z,L_FB19
L_FAB9:
        ld hl,Z_E3
        jr nc,LC_FAB9_0
        xor (hl)
        scf
        jr LC_FAB9_1
LC_FAB9_0:
        xor (hl)
LC_FAB9_1:
L_FABB:
        jr nc,LC_FABB_0
        and $08
        scf
        jr LC_FABB_1
LC_FABB_0:
        and $08
LC_FABB_1:
L_FABD:
        jp z,L_FACB
L_FABF:
        jp c,L_FACB
L_FAC1:
        ld b,a
        ld a,iyl
        cp $06
        ld a,b
        ccf
L_FAC3:
        jp nz,L_FACA
L_FAC5:
        jp L_FB75
L_FAC8:
        ld hl,Z_D4
        ld e,ixl
        ld (hl),e
L_FACA:
        ret
L_FACB:
        call L_FD4D
L_FACE:
        jp nc,L_FA9B
L_FAD0:
        jp c,L_FB19
L_FAD2:
        ld a,(Z_D4)
L_FAD4:
        srl a
L_FAD5:
        srl a
L_FAD6:
        srl a
L_FAD7:
        ld hl,Z_E3
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_FAD9:
        jp p,L_FADD
L_FADB:
        xor $07
L_FADD:
        ld (Z_EC),a
L_FADF:
        ld a,(Z_D8)
L_FAE1:
        cp $0E
        ccf
L_FAE3:
        jp nc,L_FAE9
L_FAE5:
        ccf
        sbc a,$0C
        ccf
        jp pe,LV_FAE5_1
        res 6,d
        jr LV_FAE5_2
LV_FAE5_1:
        set 6,d
LV_FAE5_2:
L_FAE7:
        ld (Z_D8),a
L_FAE9:
        ld a,$80
L_FAEB:
        ld (Z_EB),a
L_FAED:
        ld hl,Z_B7
        jr nc,LC_FAED_0
        xor (hl)
        scf
        jr LC_FAED_1
LC_FAED_0:
        xor (hl)
LC_FAED_1:
L_FAEF:
        ld hl,Z_E3
        jr nc,LC_FAEF_0
        and (hl)
        scf
        jr LC_FAEF_1
LC_FAEF_0:
        and (hl)
LC_FAEF_1:
L_FAF1:
        jp m,L_FAF5
L_FAF3:
        ld a,(Z_E5)
L_FAF5:
        ld hl,Z_D0
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_FAF7:
        jp z,L_FB15
L_FAF9:
        ld a,(ix-18)
L_FAFB:
        cp $02
        ccf
L_FAFD:
        jp c,L_FB19
L_FAFF:
        ld a,(ix-116)
L_FB01:
        and $70
L_FB03:
        cp $60
        ccf
L_FB05:
        jp nz,L_FB19
L_FB07:
        ld a,(ix-90)
L_FB09:
        srl a
L_FB0A:
        srl a
L_FB0B:
        srl a
L_FB0C:
        srl a
L_FB0D:
        ld (Z_EB),a
L_FB0F:
        push af
        ld a,ixl
        add a,$7F
        ld l,a
        ld h,$FA
        pop af
        ld a,(hl)
L_FB11:
        jr nc,LC_FB11_0
        and $30
        scf
        jr LC_FB11_1
LC_FB11_0:
        and $30
LC_FB11_1:
L_FB13:
        ld hl,Z_EB
        jr nc,LC_FB13_0
        or (hl)
        scf
        jr LC_FB13_1
LC_FB13_0:
        or (hl)
LC_FB13_1:
L_FB15:
        jr nc,LC_FB15_0
        xor $18
        scf
        jr LC_FB15_1
LC_FB15_0:
        xor $18
LC_FB15_1:
L_FB17:
        ld (Z_EB),a
L_FB19:
        ld hl,Z_D8
        dec (hl)
L_FB1B:
        ld hl,Z_D8
        dec (hl)
L_FB1D:
        jp p,L_FB22
L_FB1F:
        jp L_FA9D
L_FB22:
        ld a,(Z_D8)
L_FB24:
        srl a
L_FB25:
        ld ixl,a
L_FB26:
        dec ixl
L_FB27:
        jp m,L_FB85
L_FB29:
        jp z,L_FB5D
L_FB2B:
        dec ixl
L_FB2C:
        dec ixl
L_FB2D:
        dec ixl
L_FB2E:
        jp m,L_FB54
L_FB30:
        ld a,(Z_B7)
L_FB32:
        ld hl,Z_B4
        jr nc,LC_FB32_0
        xor (hl)
        scf
        jr LC_FB32_1
LC_FB32_0:
        xor (hl)
LC_FB32_1:
L_FB34:
        jp m,L_FB19
L_FB36:
        ld a,(Z_EB)
        inc a
        dec a
L_FB38:
        jp m,L_FB19
L_FB3A:
        ld hl,Z_B8
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_FB3C:
        jp m,L_FB19
L_FB3E:
        ld a,(Z_EC)
L_FB40:
        cp $04
        ccf
L_FB42:
        jp nz,L_FB19
L_FB44:
        call L_FB91
L_FB47:
        ld hl,Z_EB
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_FB49:
        jp nz,L_FB19
L_FB4B:
        ld a,(Z_E3)
L_FB4D:
        jr nc,LC_FB4D_0
        and $08
        scf
        jr LC_FB4D_1
LC_FB4D_0:
        and $08
LC_FB4D_1:
L_FB4F:
        jr nc,LC_FB4F_0
        xor $0E
        scf
        jr LC_FB4F_1
LC_FB4F_0:
        xor $0E
LC_FB4F_1:
L_FB51:
        ld (Z_D7),a
L_FB53:
        ret
L_FB54:
        ld a,(Z_B7)
L_FB56:
        ld hl,Z_B4
        jr nc,LC_FB56_0
        xor (hl)
        scf
        jr LC_FB56_1
LC_FB56_0:
        xor (hl)
LC_FB56_1:
L_FB58:
        jp m,L_FB19
L_FB5A:
        jp L_FA9F
L_FB5D:
        ld a,(Z_EC)
L_FB5F:
        cp $05
        ccf
L_FB61:
        rra
L_FB62:
        ld hl,Z_B4
        jr nc,LC_FB62_0
        xor (hl)
        scf
        jr LC_FB62_1
LC_FB62_0:
        xor (hl)
LC_FB62_1:
L_FB64:
        ld hl,Z_B7
        jr nc,LC_FB64_0
        or (hl)
        scf
        jr LC_FB64_1
LC_FB64_0:
        or (hl)
LC_FB64_1:
L_FB66:
        jp p,L_FB19
L_FB68:
        call L_FB91
L_FB6B:
        jp m,L_FB19
L_FB6D:
        ld a,(ix-128)
L_FB6F:
        jr nc,LC_FB6F_0
        and $0F
        scf
        jr LC_FB6F_1
LC_FB6F_0:
        and $0F
LC_FB6F_1:
L_FB71:
        ld (Z_D7),a
L_FB73:
        jp nz,L_FB8E
L_FB75:
        ld a,(Z_B7)
        inc a
        dec a
L_FB77:
        jp m,L_FB84
L_FB79:
        ld a,$06
L_FB7B:
        ld hl,Z_EC
        cp (hl)
        ccf
L_FB7D:
        jp nz,L_FB84
L_FB7F:
        add a,a
L_FB80:
        ld hl,Z_D8
        adc a,(hl)
        jp pe,LV_FB80_1
        res 6,d
        jr LV_FB80_2
LV_FB80_1:
        set 6,d
LV_FB80_2:
L_FB82:
        ld (Z_D8),a
L_FB84:
        ret
L_FB85:
        ld hl,Z_EC
        ld e,(hl)
        ld ixl,e
L_FB87:
        dec ixl
L_FB88:
        jp nz,L_FB8E
L_FB8A:
        ld hl,Z_B4
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_FB8C:
        jp m,L_FB68
L_FB8E:
        jp L_FA66
L_FB91:
        ld hl,Z_D6
        ld e,(hl)
        ld ixl,e
L_FB93:
        ld a,ixl
        add a,$E8
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        ld a,(hl)
L_FB96:
        or a
L_FB97:
        ld hl,Z_D8
        adc a,(hl)
L_FB99:
        ld iyl,a
L_FB9A:
        ld a,(Z_D4)
L_FB9C:
        jr nc,LC_FB9C_0
        and $38
        scf
        jr LC_FB9C_1
LC_FB9C_0:
        and $38
LC_FB9C_1:
L_FB9E:
        ld hl,Z_D4
        adc a,(hl)
L_FBA0:
L_FBA1:
        push af
        ld a,iyl
        add a,$82
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        adc a,(hl)
        daa
        jp pe,LV_FBA1_1
        res 6,d
        jr LV_FBA1_2
LV_FBA1_1:
        set 6,d
LV_FBA1_2:
L_FBA4:
L_FBA5:
        ld ixl,a
        inc ixl
        dec ixl
L_FBA6:
        jp m,L_FBB3
L_FBA8:
        ld (Z_D5),a
L_FBAA:
        jr nc,LC_FBAA_0
        and $0F
        scf
        jr LC_FBAA_1
LC_FBAA_0:
        and $0F
LC_FBAA_1:
L_FBAC:
        ld ixl,a
L_FBAD:
        ld hl,Z_D5
        adc a,(hl)
        jp pe,LV_FBAD_1
        res 6,d
        jr LV_FBAD_2
LV_FBAD_1:
        set 6,d
LV_FBAD_2:
L_FBAF:
        ld b,a
        ld a,ixl
        cp $08
        ld a,b
        ccf
L_FBB1:
        rra
L_FBB2:
        ld ixl,a
        inc ixl
        dec ixl
L_FBB3:
        ld hl,Z_D5
        ld e,ixl
        ld (hl),e
L_FBB5:
        ret
L_FBB6:
        ld hl,Z_E4
        ld e,(hl)
        ld ixl,e
L_FBB8:
        ld b,a
        ld a,ixl
        cp $08
        ld a,b
        ccf
L_FBBA:
        ld a,(Z_D6)
        inc a
        dec a
L_FBBC:
        push af          ; PHP (C, Z e N ficam no F do Z80)
L_FBBD:
        jp nc,L_FBC1
L_FBBF:
        adc a,$07
L_FBC1:
        ld iyl,a
L_FBC2:
        ld a,(Z_D3)
L_FBC4:
        jr nc,LC_FBC4_0
        and $1B
        scf
        jr LC_FBC4_1
LC_FBC4_0:
        and $1B
LC_FBC4_1:
L_FBC6:
        ld hl,Z_E2
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_FBC8:
        jp p,L_FBCE
L_FBCA:
        jr nc,LC_FBCA_0
        and $09
        scf
        jr LC_FBCA_1
LC_FBCA_0:
        and $09
LC_FBCA_1:
L_FBCC:
        adc a,$09
L_FBCE:
        adc a,$12
L_FBD0:
        ld ixl,a
L_FBD1:
        ld a,(Z_D5)
L_FBD3:
        call L_FE9C
L_FBD6:
        ld (Z_F4),a
L_FBD8:
        ld a,(Z_D4)
L_FBDA:
        call L_FE9C
L_FBDD:
        scf
L_FBDE:
        ld hl,Z_F4
        ccf
        sbc a,(hl)
        ccf
L_FBE0:
        ld (Z_F7),a
L_FBE2:
        push af
        ld a,iyl
        add a,$E3
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_FBE5:
        jp nz,L_FBEB
L_FBE7:
        ld a,ixl
L_FBE8:
        jp L_FBF9
L_FBEB:
        jp p,L_FBF6
L_FBED:
        ld hl,Z_E2
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_FBEF:
        jp m,L_FBE7
L_FBF1:
        ld ixl,$05
L_FBF3:
        or a
L_FBF4:
        ld hl,Z_F7
        adc a,(hl)
L_FBF6:
        dec ixl
L_FBF7:
        jp nz,L_FBF3
L_FBF9:
        ld e,a
        pop af           ; PLP
        ld a,e
L_FBFA:
        jp nc,L_FC12
L_FBFC:
        ld hl,Z_D3
        ld e,(hl)
        ld ixl,e
L_FBFE:
        ld b,a
        ld a,ixl
        cp $40
        ld a,b
        ccf
L_FC00:
        jp nc,L_FC08
L_FC02:
        ld hl,Z_D7
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_FC04:
        jp z,L_FC08
L_FC06:
        ccf
        sbc a,$32
        ccf
L_FC08:
        ld b,a
        ld a,iyl
        cp $0E
        ld a,b
        ccf
L_FC0A:
        jp nz,L_FC11
L_FC0C:
        ld hl,Z_CB
        ld e,(hl)
        ld iyl,e
L_FC0E:
        push af
        ld a,iyl
        add a,$F2
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        ccf
        sbc a,(hl)
        ccf
L_FC11:
        scf
L_FC12:
        ld (Z_F8),a
L_FC14:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_FC16:
        jp c,L_FC3F
L_FC18:
        ld b,a
        ld a,ixl
        cp $0D
        ld a,b
        ccf
L_FC1A:
        jp c,L_FC3F
L_FC1C:
        ld a,ixl
        add a,$C6
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        ld a,(hl)
L_FC1F:
        ld hl,Z_B9
        ld d,(hl)
        ld e,a
        ld a,d
        inc a
        dec a
        ld a,e
L_FC21:
        jp p,L_FC27
L_FC23:
        srl a
L_FC24:
        srl a
L_FC25:
        srl a
L_FC26:
        srl a
L_FC27:
        and $0F
L_FC29:
        ld hl,Z_D3
        ld d,(hl)
L_FC2B:
        ld hl,Z_D5
        ld e,(hl)
        ld iyl,e
L_FC2D:
        ld b,a
        ld a,iyl
        cp $1A
        ld a,b
        ccf
L_FC2F:
        jp nc,L_FC3D
L_FC31:
        jp z,L_FC34
L_FC33:
        res 6,d          ; V do 6502 mora no bit 6 de D
L_FC34:
        ld hl,Z_E4
        ld e,(hl)
        ld iyl,e
        inc iyl
        dec iyl
L_FC36:
        jp nz,L_FC3D
L_FC38:
        push af
        bit 6,d
        jr nz,LB_FC38
        pop af
        jp L_FC3C
LB_FC38:
        pop af
L_FC3A:
        adc a,$10
L_FC3C:
        add a,a
L_FC3D:
        ld hl,Z_F8
        adc a,(hl)
L_FC3F:
        ld hl,Z_D6
        ld e,(hl)
        ld iyl,e
L_FC41:
        ld b,a
        ld a,iyl
        cp $06
        ld a,b
L_FC43:
        jp nz,L_FC65
L_FC45:
        ld b,a
        ld a,ixl
        cp $10
        ld a,b
        ccf
L_FC47:
        jp c,L_FC65
L_FC49:
        ld b,a
        ld a,ixl
        cp $0D
        ld a,b
        ccf
L_FC4B:
        jp nc,L_FC65
L_FC4D:
        push af          ; PHA
L_FC4E:
        ld ixl,$03
L_FC50:
        ld a,(ix-124)
L_FC52:
        and $0F
L_FC54:
        jp nz,L_FC5A
L_FC56:
        dec ixl
L_FC57:
        ld a,ixl
        or a
L_FC58:
        jp p,L_FC50
L_FC5A:
        cp $02
        ccf
L_FC5C:
        pop hl           ; PLA
        ld a,h
L_FC5D:
        ld hl,Z_82
        ld d,(hl)
L_FC5F:
        push af
        bit 6,d
        jr nz,LB_FC5F
        pop af
        jp L_FC63
LB_FC5F:
        pop af
L_FC61:
        jp c,L_FC65
L_FC63:
        ccf
        sbc a,$0B
        ccf
L_FC65:
        ld hl,Z_D5
        ld e,(hl)
        ld ixl,e
L_FC67:
        ld hl,Z_F2
        ld e,ixl
        ld (hl),e
L_FC69:
        ld (Z_F8),a
L_FC6B:
        ld a,$0F
L_FC6D:
        ld (Z_F6),a
L_FC6F:
        ld a,(Z_D6)
L_FC71:
        cp $05
        ccf
L_FC73:
        jp nz,L_FC9F
L_FC75:
        ld a,ixl
L_FC76:
        and $07
L_FC78:
        ld ixl,a
L_FC79:
        ld hl,Z_F2
        xor (hl)
L_FC7B:
        cp $30
L_FC7D:
        jp nz,L_FC82
L_FC7F:
        srl a
L_FC80:
        ld (Z_F6),a
L_FC82:
        ld a,ixl
L_FC83:
        or a
L_FC84:
        adc a,$08
L_FC86:
        ld ixl,a
L_FC87:
        ld b,a
        ld a,ixl
        cp $38
        ld a,b
        ccf
L_FC89:
        jp c,L_FCD8
L_FC8B:
        ld a,(ix-128)
L_FC8D:
        and $0F
L_FC8F:
        ld hl,Z_F2
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_FC91:
        jr nc,LC_FC91_0
        xor $0E
        scf
        jr LC_FC91_1
LC_FC91_0:
        xor $0E
LC_FC91_1:
L_FC93:
        jp nz,L_FC99
L_FC95:
        ld hl,Z_F6
        dec (hl)
L_FC97:
        ld hl,Z_F6
        dec (hl)
L_FC99:
        jr nc,LC_FC99_0
        xor $08
        scf
        jr LC_FC99_1
LC_FC99_0:
        xor $08
LC_FC99_1:
L_FC9B:
        jp nz,L_FC82
L_FC9D:
        jp nc,L_FCC7
L_FC9F:
        jp nc,L_FD1D
L_FCA1:
        ld iyl,$03
L_FCA3:
        dec iyl
L_FCA4:
        jp m,L_FCA1
L_FCA6:
        ld a,ixl
L_FCA7:
        or a
L_FCA8:
        push af
        ld a,iyl
        add a,$D2
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        adc a,(hl)
L_FCAB:
        ld ixl,a
L_FCAC:
        and $07
L_FCAE:
        push af
        ld a,iyl
        add a,$FB
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        xor (hl)
L_FCB1:
        jp z,L_FCA3
L_FCB3:
        ld a,ixl
L_FCB4:
        ld hl,Z_F2
        or (hl)
L_FCB6:
        ld b,a
        ld a,ixl
        cp $40
        ld a,b
        ccf
L_FCB8:
        jp c,L_FCC2
L_FCBA:
        ld a,(ix-128)
L_FCBC:
        and $0F
L_FCBE:
        xor $0E
L_FCC0:
        jp nz,L_FCA3
L_FCC2:
        ld hl,Z_F6
        dec (hl)
L_FCC4:
        ld iyl,a
        inc iyl
        dec iyl
L_FCC5:
        jp nz,L_FCC9
L_FCC7:
        ld (Z_F6),a
L_FCC9:
        ld hl,Z_E4
        ld e,(hl)
        ld ixl,e
L_FCCB:
        ld b,a
        ld a,ixl
        cp $04
        ld a,b
        ccf
L_FCCD:
        jp c,L_FCD2
L_FCCF:
        ld a,(Z_D7)
L_FCD1:
        add a,a
L_FCD2:
        ld hl,Z_D6
        ld e,(hl)
        ld iyl,e
L_FCD4:
        ld b,a
        ld a,iyl
        cp $06
        ld a,b
L_FCD6:
        jp z,L_FD2B
L_FCD8:
        ld iyl,$03
L_FCDA:
        ld hl,Z_F2
        ld e,(hl)
        ld ixl,e
L_FCDC:
        ld hl,Z_D4
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
L_FCDE:
        jp nz,L_FCE6
L_FCE0:
        ld b,a
        ld a,iyl
        cp $02
        ld a,b
        ccf
L_FCE2:
        jp nc,L_FCE6
L_FCE4:
        ld hl,Z_D5
        ld e,(hl)
        ld ixl,e
L_FCE6:
        ld a,ixl
L_FCE7:
        or a
L_FCE8:
        push af
        ld a,iyl
        add a,$7E
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        adc a,(hl)
L_FCEB:
        ld ixl,a
L_FCEC:
        ld hl,Z_F2
        xor (hl)
L_FCEE:
        cp $08
        ccf
L_FCF0:
        jp nc,L_FCF6
L_FCF2:
        and $C7
L_FCF4:
        jp nz,L_FD09
L_FCF6:
        ld hl,Z_D4
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
L_FCF8:
        jp z,L_FCE6
L_FCFA:
        ld a,(ix-128)
L_FCFC:
        and $0F
L_FCFE:
        jp z,L_FCE6
L_FD00:
        ld ixl,a
L_FD01:
        ld a,iyl
L_FD02:
        srl a
L_FD03:
        xor $05
L_FD05:
        ld b,a
        ld a,ixl
        cp $05
        ld a,b
L_FD07:
        jp z,L_FD0D
L_FD09:
        dec iyl
L_FD0A:
        ld a,iyl
        or a
L_FD0B:
        jp p,L_FCDA
L_FD0D:
        scf
L_FD0E:
        ld hl,Z_F6
        adc a,(hl)
L_FD10:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_FD12:
        xor $FF
L_FD14:
        ld hl,Z_F2
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_FD16:
        jp z,L_FD2C
L_FD18:
        xor $FF
L_FD1A:
        jp L_FC67
L_FD1D:
        srl a
L_FD1E:
        jp nz,L_FD28
L_FD20:
        dec ixl
L_FD21:
        dec ixl
L_FD22:
        ld iyl,$14
L_FD24:
        ld hl,Z_D4
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
L_FD26:
        jp z,L_FD2A
L_FD28:
        ld iyl,$00
L_FD2A:
        ld a,iyl
L_FD2B:
        or a
L_FD2C:
        ld hl,Z_F8
        adc a,(hl)
        jp pe,LV_FD2C_1
        res 6,d
        jr LV_FD2C_2
LV_FD2C_1:
        set 6,d
LV_FD2C_2:
L_FD2E:
        xor $80
L_FD30:
        ld (Z_F0),a
L_FD32:
        ret
L_FD33:
        ld hl,Z_D4
        ld e,(hl)
        ld iyl,e
L_FD35:
        ld hl,Z_D5
        ld e,(hl)
        ld ixl,e
L_FD37:
        ld a,(iy-128)
L_FD3A:
        jr nc,LC_FD3A_0
        and $0F
        scf
        jr LC_FD3A_1
LC_FD3A_0:
        and $0F
LC_FD3A_1:
L_FD3C:
        ld (Z_E9),a
L_FD3E:
        jr nc,LC_FD3E_0
        xor (iy-128)
        scf
        jr LC_FD3E_1
LC_FD3E_0:
        xor (iy-128)
LC_FD3E_1:
L_FD41:
        ld (iy-128),a
L_FD44:
        ld a,(ix-128)
L_FD46:
        jr nc,LC_FD46_0
        and $F0
        scf
        jr LC_FD46_1
LC_FD46_0:
        and $F0
LC_FD46_1:
L_FD48:
        ld hl,Z_E9
        jr nc,LC_FD48_0
        or (hl)
        scf
        jr LC_FD48_1
LC_FD48_0:
        or (hl)
LC_FD48_1:
L_FD4A:
        ld (ix-128),a
L_FD4C:
        ret
L_FD4D:
        ld hl,Z_D6
        ld e,(hl)
        ld ixl,e
L_FD4F:
        scf
L_FD50:
        dec ixl
L_FD51:
        jp z,L_FD63
L_FD53:
        dec ixl
L_FD54:
        dec ixl
L_FD55:
        dec ixl
L_FD56:
        jp m,L_FD5D
L_FD58:
        dec ixl
L_FD59:
        jp m,L_FD63
L_FD5B:
        jp nz,L_FD64
L_FD5D:
        ld a,(Z_D8)
L_FD5F:
        and $F8
L_FD61:
        ld (Z_D8),a
L_FD63:
        or a
L_FD64:
        ret
L_FD65:
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        ld a,(hl)
L_FD68:
        or a
L_FD69:
        ld hl,Z_D7
        ld e,(hl)
        ld iyl,e
L_FD6B:
        push af
        ld a,iyl
        add a,$D5
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        adc a,(hl)
        jp pe,LV_FD6B_1
        res 6,d
        jr LV_FD6B_2
LV_FD6B_1:
        set 6,d
LV_FD6B_2:
L_FD6E:
        ld iyl,a
L_FD6F:
        ld a,(Z_DA)
        or a
L_FD71:
        jp z,L_FD81
L_FD73:
        ld hl,Z_E3
        xor (hl)
L_FD75:
        jp p,L_FD81
L_FD77:
        ld a,iyl
L_FD78:
        or a
L_FD79:
        ld hl,Z_DA
        adc a,(hl)
        jp pe,LV_FD79_1
        res 6,d
        jr LV_FD79_2
LV_FD79_1:
        set 6,d
LV_FD79_2:
L_FD7B:
        jp z,L_FD90
L_FD7D:
        ld hl,Z_E3
        jr nc,LC_FD7D_0
        xor (hl)
        scf
        jr LC_FD7D_1
LC_FD7D_0:
        xor (hl)
LC_FD7D_1:
L_FD7F:
        jp p,L_FD90
L_FD81:
        ld a,(Z_E3)
L_FD83:
        add a,a
L_FD84:
        ld a,iyl
L_FD85:
        jp c,L_FD8B
L_FD87:
        jr nc,LC_FD87_0
        xor $FF
        scf
        jr LC_FD87_1
LC_FD87_0:
        xor $FF
LC_FD87_1:
L_FD89:
        adc a,$01
        jp pe,LV_FD89_1
        res 6,d
        jr LV_FD89_2
LV_FD89_1:
        set 6,d
LV_FD89_2:
L_FD8B:
        xor $80
L_FD8D:
        cp $7B
        ccf
L_FD8F:
        rr a
L_FD90:
        ret
L_FD91:
        call L_FD33
L_FD94:
        ld ixl,$3F
L_FD96:
        ld a,$04
L_FD98:
        ld (Z_CA),a
L_FD9A:
        ld (Z_CC),a
L_FD9C:
        ld a,(ix-128)
L_FD9E:
        and $CF
L_FDA0:
        ld (ix-128),a
L_FDA2:
        and $0F
L_FDA4:
        cp $08
        ccf
L_FDA6:
        jr nc,LC_FDA6_0
        and $07
        scf
        jr LC_FDA6_1
LC_FDA6_0:
        and $07
LC_FDA6_1:
L_FDA8:
        ld iyl,a
L_FDA9:
        push af
        ld a,iyl
        add a,$DD
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        ld a,(hl)
L_FDAC:
        jp nc,L_FDB6
L_FDAE:
        or a
L_FDAF:
        ld hl,Z_CA
        adc a,(hl)
L_FDB1:
        ld (Z_CA),a
L_FDB3:
        jp L_FDBC
L_FDB6:
        ld hl,Z_CC
        adc a,(hl)
L_FDB8:
        jp c,L_FDBC
L_FDBA:
        ld (Z_CC),a
L_FDBC:
        dec ixl
L_FDBD:
        jp p,L_FD9C
L_FDBF:
        ld hl,Z_F7
        ld e,ixl
        ld (hl),e
L_FDC1:
        ld a,(Z_D6)
L_FDC3:
        and $07
L_FDC5:
        cp $06
        ccf
L_FDC7:
        jp nz,L_FDD6
L_FDC9:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_FDCB:
        ld a,ixl
L_FDCC:
        ld hl,Z_D5
        ccf
        sbc a,(hl)
        ccf
L_FDCE:
        cp $F0
        ccf
L_FDD0:
        jp z,L_FDD8
L_FDD2:
        cp $10
        ccf
L_FDD4:
        jp z,L_FDD8
L_FDD6:
        ld ixl,$80
L_FDD8:
        ld hl,Z_E5
        ld e,ixl
        ld (hl),e
L_FDDA:
        ld iyl,$03
L_FDDC:
        ld hl,Z_B4
        rl (hl)
L_FDDE:
        scf
L_FDDF:
        ld hl,Z_B4
        rr (hl)
L_FDE1:
        ld hl,Z_B7
        rl (hl)
L_FDE3:
        scf
L_FDE4:
        ld hl,Z_B7
        rr (hl)
L_FDE6:
        ld hl,Z_C1
        ld e,iyl
        ld (hl),e
L_FDE8:
        ld a,$BF
L_FDEA:
        and (iy-120)
L_FDED:
        ld (iy-120),a
L_FDF0:
        push af
        ld a,iyl
        add a,$76
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        ld e,(hl)
        ld ixl,e
L_FDF3:
        ld a,(ix-128)
L_FDF5:
        and $0F
L_FDF7:
        ld (Z_CD),a
L_FDF9:
        xor (ix-128)
L_FDFB:
        ld (ix-128),a
L_FDFD:
        push af
        ld a,iyl
        add a,$7A
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        ld e,(hl)
        ld ixl,e
L_FE00:
        ld hl,Z_C0
        ld e,ixl
        ld (hl),e
L_FE02:
        ld a,iyl
L_FE03:
        srl a
L_FE04:
        jp c,L_FE07
L_FE06:
        dec ixl
L_FE07:
        add a,a
L_FE08:
        adc a,$FF
        jp pe,LV_FE08_1
        res 6,d
        jr LV_FE08_2
LV_FE08_1:
        set 6,d
LV_FE08_2:
L_FE0A:
        ld (Z_E3),a
L_FE0C:
        ld a,(ix-128)
L_FE0E:
        jr nc,LC_FE0E_0
        or (ix-127)
        scf
        jr LC_FE0E_1
LC_FE0E_0:
        or (ix-127)
LC_FE0E_1:
L_FE10:
        jr nc,LC_FE10_0
        or (ix-126)
        scf
        jr LC_FE10_1
LC_FE10_0:
        or (ix-126)
LC_FE10_1:
L_FE12:
        jr nc,LC_FE12_0
        and $0F
        scf
        jr LC_FE12_1
LC_FE12_0:
        and $0F
LC_FE12_1:
L_FE14:
        jp nz,L_FE35
L_FE16:
        ld ixl,$FE
L_FE18:
        ld hl,Z_D8
        ld e,ixl
        ld (hl),e
L_FE1A:
        ld hl,Z_D6
        ld e,ixl
        ld (hl),e
L_FE1C:
        ld a,$40
L_FE1E:
        ld (Z_D4),a
L_FE20:
        call L_FA95
L_FE23:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
        inc ixl
        dec ixl
L_FE25:
        jp m,L_FE3D
L_FE27:
        ld hl,Z_C0
        ld e,(hl)
        ld ixl,e
L_FE29:
        ld iyl,$02
L_FE2B:
        ld hl,Z_D5
        ld e,(hl)
        ld b,a
        ld a,ixl
        cp e
        ld a,b
        ccf
L_FE2D:
        jp z,L_FE35
L_FE2F:
        inc ixl
L_FE30:
        dec iyl
L_FE31:
        jp p,L_FE2B
L_FE33:
        jp m,L_FE20
L_FE35:
        ld hl,Z_C1
        ld e,(hl)
        ld ixl,e
L_FE37:
        ld a,(ix-120)
L_FE39:
        jr nc,LC_FE39_0
        or $40
        scf
        jr LC_FE39_1
LC_FE39_0:
        or $40
LC_FE39_1:
L_FE3B:
        ld (ix-120),a
L_FE3D:
        ld hl,Z_C1
        ld e,(hl)
        ld iyl,e
L_FE3F:
        push af
        ld a,iyl
        add a,$76
        ld l,a
        adc a,$EF
        sub l
        ld h,a
        pop af
        ld e,(hl)
        ld ixl,e
L_FE42:
        call L_FE66
L_FE45:
        dec iyl
L_FE46:
        jp p,L_FDE6
L_FE48:
        call L_F1DC
L_FE4B:
        ld ixl,$05
L_FE4D:
        push af
        ld a,ixl
        add a,$FA
        ld l,a
        adc a,$EE
        sub l
        ld h,a
        pop af
        ld a,(hl)
L_FE50:
        ld hl,Z_D4
        cp (hl)
        ccf
L_FE52:
        jp z,L_FE58
L_FE54:
        ld hl,Z_D5
        cp (hl)
        ccf
L_FE56:
        jp nz,L_FE5E
L_FE58:
        ld a,$40
L_FE5A:
        jr nc,LC_FE5A_0
        or (ix-126)
        scf
        jr LC_FE5A_1
LC_FE5A_0:
        or (ix-126)
LC_FE5A_1:
L_FE5C:
        ld (ix-126),a
L_FE5E:
        dec ixl
L_FE5F:
        jp p,L_FE4D
L_FE61:
        ret
L_FE62:
        ld a,$00
L_FE64:
        ld (Z_CD),a
L_FE66:
        ld a,(ix-128)
L_FE68:
        jr nc,LC_FE68_0
        and $F0
        scf
        jr LC_FE68_1
LC_FE68_0:
        and $F0
LC_FE68_1:
L_FE6A:
        ld hl,Z_CD
        jr nc,LC_FE6A_0
        or (hl)
        scf
        jr LC_FE6A_1
LC_FE6A_0:
        or (hl)
LC_FE6A_1:
L_FE6C:
        ld (ix-128),a
L_FE6E:
        ret
L_FE6F:
        ld a,$09
L_FE71:
        ld (Z_CC),a
L_FE73:
        ld hl,Z_D4
        ld e,(hl)
        ld ixl,e
L_FE75:
        xor (ix-128)
L_FE77:
        ld hl,Z_D5
        ld e,(hl)
        ld ixl,e
L_FE79:
        and $0F
L_FE7B:
        jp z,L_FE9B
L_FE7D:
        ld a,$FF
L_FE7F:
        ld (Z_CD),a
L_FE81:
        ld hl,Z_CD
        ld d,(hl)
L_FE83:
        ld ixl,$3F
L_FE85:
        ld a,(ix-128)
L_FE87:
        and $0F
L_FE89:
        jp z,L_FE96
L_FE8B:
        ld hl,Z_CC
        cp (hl)
        ccf
L_FE8D:
        jp nz,L_FE93
L_FE8F:
        ld hl,Z_CD
        ld e,ixl
        ld (hl),e
L_FE91:
        jp z,L_FE96
L_FE93:
        jp nc,L_FE96
L_FE95:
        res 6,d          ; V do 6502 mora no bit 6 de D
L_FE96:
        dec ixl
L_FE97:
        jp p,L_FE85
L_FE99:
        ld hl,Z_CD
        ld e,(hl)
        ld ixl,e
L_FE9B:
        ret
L_FE9C:
        ld (Z_CC),a
L_FE9E:
        and $07
L_FEA0:
        ld (Z_CB),a
L_FEA2:
        ld hl,Z_CC
        xor (hl)
L_FEA4:
        ld (Z_CC),a
L_FEA6:
        ld a,ixl
L_FEA7:
        and $07
L_FEA9:
        scf
L_FEAA:
        ld hl,Z_CB
        ccf
        sbc a,(hl)
        ccf
L_FEAC:
        jp p,L_FEB2
L_FEAE:
        jr nc,LC_FEAE_0
        xor $FF
        scf
        jr LC_FEAE_1
LC_FEAE_0:
        xor $FF
LC_FEAE_1:
L_FEB0:
        adc a,$01
L_FEB2:
        ld (Z_CD),a
L_FEB4:
        ld a,ixl
L_FEB5:
        and $38
L_FEB7:
        scf
L_FEB8:
        ld hl,Z_CC
        ccf
        sbc a,(hl)
        ccf
L_FEBA:
        jp p,L_FEC0
L_FEBC:
        jr nc,LC_FEBC_0
        xor $FF
        scf
        jr LC_FEBC_1
LC_FEBC_0:
        xor $FF
LC_FEBC_1:
L_FEBE:
        adc a,$01
L_FEC0:
        srl a
L_FEC1:
        srl a
L_FEC2:
        srl a
L_FEC3:
        ld hl,Z_CD
        adc a,(hl)
L_FEC5:
        ret
