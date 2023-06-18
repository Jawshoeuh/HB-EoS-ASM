; ------------------------------------------------------------------------------
; Jawshoeuh 2/14/202 - Confirmed Working
; Turn StatusCheckerCheck into a big 'switch' statement so
; a move's status checker check can easily be changed. To fit
; the table and some checks into the original spot, some weird
; 'optimizations' (for instructions, not runtime) have been made.
; Additionally, checks can be deleted if you are confident you will not
; need them in your game (for example, removing check_lucky_chant or 
; evasion_speed_boost_not_max).
; Here are the conditions after branching from the large switch statement.
; r9 = Move ID (can be overwritten later if not needed)
; r8 = Pointer to the entity that is considering using the move ()
; r7 = Pointer to extra Pokemon data (can be overwritten later if not needed)
; r6 = DUNGEON_PTR (can be overwritten later if not needed)
; r4,r5 = reserved for scratch register in this function in
; ------------------------------------------------------------------------------

.org StatusCheckerCheck
.area 0xF24 ; If run into space errors, use overlay 36, don't increase area here.
    stmdb sp!,{r3,r4,r5,r6,r7,r8,r9,lr}
    mov   r8,r0
    ldr   r7,[r0,#0xB4]
    ldrh  r9,[r1,#0x4]
    ldr   r6,=PTR_DUNGEON_PTR 
    ldr   r6,[r6]
    cmp   r9,#600 ; Yes it's not 558, just return false for 559
    addls pc,pc,r9, lsl #0x2
    b return_false                                         ; ID > 600 (INVALID)
    b return_false                                         ; ID = 0   (INVALID)
    b return_true                                          ; ID = 1
    b return_true                                          ; ID = 2
    b return_true                                          ; ID = 3
    b return_true                                          ; ID = 4
    b return_true                                          ; ID = 5
    b return_true                                          ; ID = 6
    b not_fixed_room_boss_fight                            ; ID = 7
    b return_true                                          ; ID = 8
    b return_true                                          ; ID = 9
    b return_true                                          ; ID = 10
    b return_true                                          ; ID = 11
    b weather_not_rain                                     ; ID = 12
    b return_true                                          ; ID = 13
    b weather_not_hail                                     ; ID = 14
    b return_true                                          ; ID = 15
    b return_true                                          ; ID = 16
    b return_true                                          ; ID = 17
    b return_true                                          ; ID = 18
    b not_biding_d2                                        ; ID = 19
    b return_true                                          ; ID = 20
    b return_true                                          ; ID = 21
    b return_true                                          ; ID = 22
    b return_true                                          ; ID = 23
    b return_true                                          ; ID = 24
    b return_true                                          ; ID = 25
    b return_true                                          ; ID = 26
    b return_true                                          ; ID = 27
    b return_true                                          ; ID = 28
    b return_true                                          ; ID = 29
    b return_true                                          ; ID = 30
    b return_true                                          ; ID = 31
    b return_true                                          ; ID = 32
    b return_true                                          ; ID = 33
    b return_true                                          ; ID = 34
    b return_true                                          ; ID = 35
    b return_true                                          ; ID = 36
    b return_true                                          ; ID = 37
    b not_protected_d5                                     ; ID = 38
    b return_true                                          ; ID = 39
    b check_mirror_move                                    ; ID = 40
    b return_true                                          ; ID = 41
    b return_true                                          ; ID = 42
    b not_fixed_room_boss_fight                            ; ID = 43
    b return_true                                          ; ID = 44
    b return_true                                          ; ID = 45
    b return_true                                          ; ID = 46
    b return_true                                          ; ID = 47
    b return_true                                          ; ID = 48
    b not_bearing_grudge_fd                                ; ID = 49
    b return_true                                          ; ID = 50
    b not_protected_d5                                     ; ID = 51
    b return_true                                          ; ID = 52
    b return_true                                          ; ID = 53
    b return_true                                          ; ID = 54
    b attack_boost_not_max                                 ; ID = 55
    b evasion_boost_not_max                                ; ID = 56
    b return_true                                          ; ID = 57
    b defense_boost_not_max                                ; ID = 58
    b return_true                                          ; ID = 59
    b return_true                                          ; ID = 60
    b not_biding_d2                                        ; ID = 61
    b return_true                                          ; ID = 62
    b return_true                                          ; ID = 63
    b return_true                                          ; ID = 64
    b return_true                                          ; ID = 65
    b return_true                                          ; ID = 66
    b return_true                                          ; ID = 68
    b return_true                                          ; ID = 68
    b return_true                                          ; ID = 69
    b defense_boost_not_max                                ; ID = 70
    b return_true                                          ; ID = 71
    b return_true                                          ; ID = 72
    b return_true                                          ; ID = 73
    b return_true                                          ; ID = 74
    b return_true                                          ; ID = 75
    b return_true                                          ; ID = 76
    b return_true                                          ; ID = 77
    b return_true                                          ; ID = 78
    b return_true                                          ; ID = 79
    b return_true                                          ; ID = 80
    b return_true                                          ; ID = 81
    b return_true                                          ; ID = 82
    b return_true                                          ; ID = 83
    b return_true                                          ; ID = 84
    b return_true                                          ; ID = 85
    b return_true                                          ; ID = 86
    b return_true                                          ; ID = 87
    b return_true                                          ; ID = 88
    b return_true                                          ; ID = 89
    b return_true                                          ; ID = 90
    b return_true                                          ; ID = 91
    b return_true                                          ; ID = 92
    b return_true                                          ; ID = 93
    b return_true                                          ; ID = 94
    b speed_not_max                                        ; ID = 95
    b return_true                                          ; ID = 96
    b return_true                                          ; ID = 97
    b return_true                                          ; ID = 98
    b defense_spdefense_boost_not_max                      ; ID = 99
    b return_true                                          ; ID = 100
    b return_true                                          ; ID = 101
    b not_active_decoy                                     ; ID = 102
    b return_true                                          ; ID = 103
    b not_protected_d5                                     ; ID = 104
    b return_true                                          ; ID = 105
    b return_true                                          ; ID = 106
    b return_true                                          ; ID = 107
    b return_true                                          ; ID = 108
    b return_true                                          ; ID = 109
    b return_true                                          ; ID = 110
    b return_true                                          ; ID = 111
    b return_true                                          ; ID = 112
    b return_true                                          ; ID = 113
    b return_true                                          ; ID = 114
    b return_true                                          ; ID = 115
    b return_true                                          ; ID = 116
    b return_true                                          ; ID = 117
    b return_true                                          ; ID = 118
    b return_true                                          ; ID = 119
    b return_true                                          ; ID = 120
    b return_true                                          ; ID = 121
    b return_true                                          ; ID = 122
    b return_true                                          ; ID = 123
    b return_true                                          ; ID = 124
    b return_true                                          ; ID = 125
    b return_true                                          ; ID = 126
    b return_true                                          ; ID = 127
    b not_biding_d2                                        ; ID = 128
    b return_true                                          ; ID = 129
    b not_protected_d5                                     ; ID = 130
    b return_true                                          ; ID = 131
    b return_true                                          ; ID = 132
    b return_true                                          ; ID = 133
    b not_protected_d5                                     ; ID = 134
    b return_true                                          ; ID = 135
    b return_true                                          ; ID = 136
    b return_true                                          ; ID = 137
    b return_true                                          ; ID = 138
    b return_true                                          ; ID = 139
    b return_true                                          ; ID = 140
    b weather_not_sandstorm                                ; ID = 141
    b return_true                                          ; ID = 142
    b return_true                                          ; ID = 143
    b return_true                                          ; ID = 144
    b return_true                                          ; ID = 145
    b return_true                                          ; ID = 146
    b return_true                                          ; ID = 147
    b spattack_boost_not_max                               ; ID = 148
    b return_true                                          ; ID = 149
    b return_true                                          ; ID = 150
    b return_true                                          ; ID = 151
    b return_true                                          ; ID = 152
    b return_true                                          ; ID = 153
    b return_true                                          ; ID = 154
    b return_true                                          ; ID = 155
    b return_true                                          ; ID = 156
    b return_true                                          ; ID = 157
    b return_true                                          ; ID = 158
    b return_true                                          ; ID = 159
    b not_max_stockpiled                                   ; ID = 160
    b return_true                                          ; ID = 161
    b return_true                                          ; ID = 162
    b return_true                                          ; ID = 163
    b return_true                                          ; ID = 164
    b return_true                                          ; ID = 165
    b return_true                                          ; ID = 166
    b return_true                                          ; ID = 167
    b return_true                                          ; ID = 168
    b evasion_boost_not_max                                ; ID = 169
    b return_true                                          ; ID = 170
    b return_true                                          ; ID = 171
    b return_true                                          ; ID = 172
    b return_true                                          ; ID = 173
    b return_true                                          ; ID = 174
    b return_true                                          ; ID = 175
    b return_true                                          ; ID = 176
    b return_true                                          ; ID = 177
    b return_true                                          ; ID = 178
    b return_true                                          ; ID = 179
    b return_true                                          ; ID = 180
    b attack_boost_not_max                                 ; ID = 181
    b return_true                                          ; ID = 182
    b return_true                                          ; ID = 183
    b not_protected_d5                                     ; ID = 184
    b check_helping_hand_acupressure                       ; ID = 185
    b defense_boost_not_max                                ; ID = 186
    b not_fixed_room_boss_fight                            ; ID = 187
    b return_true                                          ; ID = 188
    b return_true                                          ; ID = 189
    b return_true                                          ; ID = 190
    b return_true                                          ; ID = 191
    b return_true                                          ; ID = 192
    b return_true                                          ; ID = 193
    b return_true                                          ; ID = 194
    b return_true                                          ; ID = 195
    b return_true                                          ; ID = 196
    b return_true                                          ; ID = 197
    b return_true                                          ; ID = 198
    b return_true                                          ; ID = 199
    b return_true                                          ; ID = 200
    b return_true                                          ; ID = 201
    b return_true                                          ; ID = 202
    b return_true                                          ; ID = 203
    b return_true                                          ; ID = 204
    b return_true                                          ; ID = 205
    b return_true                                          ; ID = 206
    b return_true                                          ; ID = 207
    b return_true                                          ; ID = 208
    b return_true                                          ; ID = 209
    b return_true                                          ; ID = 210
    b return_true                                          ; ID = 211
    b check_mud_sport                                      ; ID = 212
    b return_true                                          ; ID = 213
    b return_true                                          ; ID = 214
    b spdefense_boost_not_max                              ; ID = 215
    b return_true                                          ; ID = 216
    b return_true                                          ; ID = 217
    b return_true                                          ; ID = 218
    b return_true                                          ; ID = 219
    b return_true                                          ; ID = 220
    b return_true                                          ; ID = 221
    b return_true                                          ; ID = 222
    b weather_not_sun                                      ; ID = 223
    b return_true                                          ; ID = 224
    b not_protected_d5                                     ; ID = 225
    b return_true                                          ; ID = 226
    b return_true                                          ; ID = 227
    b return_true                                          ; ID = 228
    b return_true                                          ; ID = 229
    b return_true                                          ; ID = 230
    b return_true                                          ; ID = 231
    b check_rest                                           ; ID = 232
    b check_ingrain                                        ; ID = 233
    b return_true                                          ; ID = 234
    b return_true                                          ; ID = 235
    b check_swallow                                        ; ID = 236
    b return_true                                          ; ID = 237
    b return_true                                          ; ID = 238
    b return_true                                          ; ID = 239
    b return_true                                          ; ID = 240
    b return_true                                          ; ID = 241
    b return_true                                          ; ID = 242
    b return_true                                          ; ID = 243
    b return_true                                          ; ID = 244
    b has_stockpiled                                       ; ID = 245
    b return_true                                          ; ID = 246
    b return_true                                          ; ID = 247
    b return_true                                          ; ID = 248
    b return_true                                          ; ID = 249
    b return_true                                          ; ID = 250
    b return_true                                          ; ID = 251
    b return_true                                          ; ID = 252
    b return_true                                          ; ID = 253
    b return_true                                          ; ID = 254
    b return_true                                          ; ID = 255
    b return_true                                          ; ID = 256
    b check_belly_drum                                     ; ID = 257
    b return_true                                          ; ID = 258
    b not_protected_d5                                     ; ID = 259
    b return_true                                          ; ID = 260
    b return_true                                          ; ID = 261
    b return_true                                          ; ID = 262
    b return_true                                          ; ID = 263
    b return_true                                          ; ID = 264
    b attack_defense_boost_not_max                         ; ID = 265
    b return_true                                          ; ID = 266
    b return_true                                          ; ID = 267
    b not_fixed_room_boss_fight                            ; ID = 268
    b not_fixed_room_boss_fight                            ; ID = 269
    b return_true                                          ; ID = 270
    b return_true                                          ; ID = 271
    b return_true                                          ; ID = 272
    b return_true                                          ; ID = 273
    b return_true                                          ; ID = 274
    b return_true                                          ; ID = 275
    b return_true                                          ; ID = 276
    b return_true                                          ; ID = 277
    b return_true                                          ; ID = 278
    b return_true                                          ; ID = 279
    b return_true                                          ; ID = 280
    b return_true                                          ; ID = 281
    b check_transform                                      ; ID = 282
    b return_true                                          ; ID = 283
    b not_fixed_room_boss_fight                            ; ID = 284
    b return_true                                          ; ID = 285
    b check_camouflage                                     ; ID = 286
    b return_true                                          ; ID = 287
    b spattack_boost_not_max                               ; ID = 288
    b return_true                                          ; ID = 289
    b return_true                                          ; ID = 290
    b return_true                                          ; ID = 291
    b return_true                                          ; ID = 292
    b return_true                                          ; ID = 293
    b return_true                                          ; ID = 294
    b can_place_trap_below                                 ; ID = 295
    b return_true                                          ; ID = 296
    b return_true                                          ; ID = 297
    b not_protected_d5                                     ; ID = 298
    b return_true                                          ; ID = 299
    b return_true                                          ; ID = 300
    b not_protected_d5                                     ; ID = 301
    b defense_boost_not_max                                ; ID = 302
    b return_true                                          ; ID = 303
    b not_active_decoy                                     ; ID = 304
    b return_true                                          ; ID = 305
    b return_true                                          ; ID = 306
    b check_water_sport                                    ; ID = 307
    b return_true                                          ; ID = 308
    b return_true                                          ; ID = 309
    b return_true                                          ; ID = 310
    b return_true                                          ; ID = 311
    b return_true                                          ; ID = 312
    b check_destiny_bond                                   ; ID = 313
    b return_true                                          ; ID = 314
    b return_true                                          ; ID = 315
    b not_protected_d5                                     ; ID = 316
    b return_true                                          ; ID = 317
    b return_true                                          ; ID = 318
    b spattack_spdefense_boost_not_max                     ; ID = 319
    b return_true                                          ; ID = 320
    b return_true                                          ; ID = 321
    b return_true                                          ; ID = 322
    b return_true                                          ; ID = 323
    b return_true                                          ; ID = 324
    b return_true                                          ; ID = 325
    b return_true                                          ; ID = 326
    b return_true                                          ; ID = 327
    b return_true                                          ; ID = 328
    b return_true                                          ; ID = 329
    b return_true                                          ; ID = 330
    b return_true                                          ; ID = 331
    b return_true                                          ; ID = 332
    b attack_boost_not_max                                 ; ID = 333
    b check_snatch                                         ; ID = 334
    b return_true                                          ; ID = 335
    b return_true                                          ; ID = 336
    b return_true                                          ; ID = 337
    b not_protected_d5                                     ; ID = 338
    b return_true                                          ; ID = 339
    b not_biding_d2                                        ; ID = 340
    b return_true                                          ; ID = 341
    b return_true                                          ; ID = 342
    b attack_speed_boost_not_max                           ; ID = 343
    b return_true                                          ; ID = 344
    b return_true                                          ; ID = 345
    b return_true                                          ; ID = 346
    b return_true                                          ; ID = 347
    b return_true                                          ; ID = 348
    b return_true                                          ; ID = 349
    b return_true                                          ; ID = 350
    b return_true                                          ; ID = 351
    b return_true                                          ; ID = 352
    b return_true                                          ; ID = 353
    b return_true                                          ; ID = 354
    b return_true                                          ; ID = 355
    b return_true                                          ; ID = 356
    b return_true                                          ; ID = 357
    b return_true                                          ; ID = 358
    b return_true                                          ; ID = 359
    b return_true                                          ; ID = 360
    b return_true                                          ; ID = 361
    b return_true                                          ; ID = 362
    b return_true                                          ; ID = 363
    b has_no_item                                          ; ID = 364
    b return_true                                          ; ID = 365
    b return_true                                          ; ID = 366
    b not_fixed_room_boss_fight                            ; ID = 367
    b not_fixed_room_boss_fight                            ; ID = 368
    b not_fixed_room_boss_fight                            ; ID = 369
    b return_true                                          ; ID = 370
    b return_true                                          ; ID = 371
    b return_true                                          ; ID = 372
    b return_true                                          ; ID = 373
    b return_true                                          ; ID = 374
    b return_true                                          ; ID = 375
    b return_true                                          ; ID = 376
    b return_true                                          ; ID = 377
    b has_sticky_item                                      ; ID = 378
    b return_true                                          ; ID = 379
    b not_active_decoy                                     ; ID = 380
    b return_true                                          ; ID = 381
    b return_true                                          ; ID = 382
    b return_true                                          ; ID = 383
    b return_true                                          ; ID = 384
    b return_true                                          ; ID = 385
    b return_true                                          ; ID = 386
    b return_true                                          ; ID = 387
    b return_true                                          ; ID = 388
    b check_trapbuster                                     ; ID = 389
    b return_true                                          ; ID = 390
    b check_invisify                                       ; ID = 391
    b return_true                                          ; ID = 392
    b return_true                                          ; ID = 393
    b return_true                                          ; ID = 394
    b return_true                                          ; ID = 395
    b return_true                                          ; ID = 396
    b return_true                                          ; ID = 397
    b return_true                                          ; ID = 398
    b return_true                                          ; ID = 399
    b return_true                                          ; ID = 400
    b return_true                                          ; ID = 401
    b return_true                                          ; ID = 402
    b return_true                                          ; ID = 403
    b return_true                                          ; ID = 404
    b return_true                                          ; ID = 405
    b return_true                                          ; ID = 406
    b return_true                                          ; ID = 407
    b return_true                                          ; ID = 408
    b return_true                                          ; ID = 409
    b return_true                                          ; ID = 410
    b return_true                                          ; ID = 411
    b return_true                                          ; ID = 412
    b return_true                                          ; ID = 413
    b return_true                                          ; ID = 414
    b return_true                                          ; ID = 415
    b return_true                                          ; ID = 416
    b return_true                                          ; ID = 417
    b return_true                                          ; ID = 418
    b return_true                                          ; ID = 419
    b return_true                                          ; ID = 420
    b return_true                                          ; ID = 421
    b return_true                                          ; ID = 422
    b return_true                                          ; ID = 423
    b return_true                                          ; ID = 424
    b return_true                                          ; ID = 425
    b return_true                                          ; ID = 426
    b return_true                                          ; ID = 427
    b return_true                                          ; ID = 428
    b return_true                                          ; ID = 429
    b return_true                                          ; ID = 430
    b return_true                                          ; ID = 431
    b return_true                                          ; ID = 432
    b return_true                                          ; ID = 433
    b not_protected_d5                                     ; ID = 434
    b return_true                                          ; ID = 435
    b return_true                                          ; ID = 436
    b return_true                                          ; ID = 437
    b return_true                                          ; ID = 438
    b return_true                                          ; ID = 439
    b return_true                                          ; ID = 440
    b return_true                                          ; ID = 441
    b return_true                                          ; ID = 442
    b return_true                                          ; ID = 443
    b speed_not_max                                        ; ID = 444
    b return_true                                          ; ID = 445
    b return_true                                          ; ID = 446
    b check_lucky_chant                                    ; ID = 447
    b return_true                                          ; ID = 448
    b return_true                                          ; ID = 449
    b return_true                                          ; ID = 450
    b return_true                                          ; ID = 451
    b return_true                                          ; ID = 452
    b return_true                                          ; ID = 453
    b return_true                                          ; ID = 454
    b return_true                                          ; ID = 455
    b return_true                                          ; ID = 456
    b return_true                                          ; ID = 457
    b return_true                                          ; ID = 458
    b return_true                                          ; ID = 459
    b return_true                                          ; ID = 460
    b return_true                                          ; ID = 461
    b return_true                                          ; ID = 462
    b return_true                                          ; ID = 463
    b has_negative_status_condition                        ; ID = 464
    b return_true                                          ; ID = 465
    b return_true                                          ; ID = 466
    b return_true                                          ; ID = 467
    b return_true                                          ; ID = 468
    b return_true                                          ; ID = 469
    b return_true                                          ; ID = 470
    b return_true                                          ; ID = 471
    b not_protected_d5                                     ; ID = 472
    b return_true                                          ; ID = 473
    b return_true                                          ; ID = 474
    b return_true                                          ; ID = 475
    b return_true                                          ; ID = 476
    b return_true                                          ; ID = 477
    b return_true                                          ; ID = 478
    b return_true                                          ; ID = 479
    b can_place_trap_below                                 ; ID = 480
    b return_true                                          ; ID = 481
    b return_true                                          ; ID = 482
    b return_true                                          ; ID = 483
    b return_true                                          ; ID = 484
    b return_true                                          ; ID = 485
    b return_true                                          ; ID = 486
    b return_true                                          ; ID = 487
    b return_true                                          ; ID = 488
    b return_true                                          ; ID = 489
    b return_true                                          ; ID = 490
    b return_true                                          ; ID = 491
    b check_helping_hand_acupressure                       ; ID = 492
    b not_magnet_rised_f7                                  ; ID = 493
    b return_true                                          ; ID = 494
    b return_true                                          ; ID = 495
    b can_place_trap_below                                 ; ID = 496
    b return_true                                          ; ID = 497
    b return_true                                          ; ID = 498
    b speed_not_boosted                                    ; ID = 499
    b return_true                                          ; ID = 500
    b return_true                                          ; ID = 501
    b return_true                                          ; ID = 502
    b return_true                                          ; ID = 503
    b return_true                                          ; ID = 504
    b return_true                                          ; ID = 505
    b return_true                                          ; ID = 506
    b return_true                                          ; ID = 507
    b return_true                                          ; ID = 508
    b return_true                                          ; ID = 509
    b return_true                                          ; ID = 510
    b return_true                                          ; ID = 511
    b return_true                                          ; ID = 512
    b return_true                                          ; ID = 513
    b return_true                                          ; ID = 514
    b return_true                                          ; ID = 515
    b return_true                                          ; ID = 516
    b return_true                                          ; ID = 517
    b return_true                                          ; ID = 518
    b return_true                                          ; ID = 519
    b defense_spdefense_boost_not_max                      ; ID = 520
    b return_true                                          ; ID = 521
    b return_true                                          ; ID = 522
    b return_true                                          ; ID = 523
    b return_true                                          ; ID = 524
    b return_true                                          ; ID = 525
    b return_true                                          ; ID = 526
    b return_true                                          ; ID = 527
    b return_true                                          ; ID = 528
    b return_true                                          ; ID = 529
    b return_true                                          ; ID = 530
    b return_true                                          ; ID = 531
    b return_true                                          ; ID = 532
    b return_true                                          ; ID = 533
    b return_true                                          ; ID = 534
    b not_protected_d5                                     ; ID = 535
    b return_true                                          ; ID = 536
    b return_true                                          ; ID = 537
    b return_true                                          ; ID = 538
    b return_true                                          ; ID = 539
    b speed_not_max                                        ; ID = 540
    b return_true                                          ; ID = 541
    b spattack_boost_not_max                               ; ID = 542
    b return_true                                          ; ID = 543
    b return_true                                          ; ID = 544
    b return_true                                          ; ID = 545
    b return_true                                          ; ID = 546
    b return_true                                          ; ID = 547
    b return_true                                          ; ID = 548
    b return_true                                          ; ID = 549
    b return_true                                          ; ID = 550
    b return_true                                          ; ID = 551
    b return_true                                          ; ID = 552
    b return_true                                          ; ID = 553
    b return_true                                          ; ID = 554
    b return_true                                          ; ID = 555
    b return_true                                          ; ID = 556
    b return_true                                          ; ID = 557
    b return_true                                          ; ID = 558
    b return_false                                         ; ID = 559 (INVALID)
attack_boost_not_max:
    ldrsh r0,[r7,#0x24]
    b     stat_boost_not_max
spattack_boost_not_max:
    ldrsh r0,[r7,#0x26]
    b     stat_boost_not_max
defense_boost_not_max:
    ldrsh r0,[r7,#0x28]
    b     stat_boost_not_max
spdefense_boost_not_max:
    ldrsh r0,[r7,#0x2A]
    b     stat_boost_not_max
accuracy_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x2C]
    b     stat_boost_not_max
evasion_boost_not_max:
    ldrsh r0,[r7,#0x2E]
    b     stat_boost_not_max
stat_boost_not_max:
    cmp r0,MAX_STAT_BOOST
    bge return_false
    b   return_true
speed_not_max:
    ldr r0,[r7,#0x110]
    cmp r0,MAX_SPEED
    blt return_true
    b   return_false
speed_not_boosted: ; TRICK ROOM Base Game
    ldr r0,[r7,#0x110]
    cmp r0,DEFAULT_SPEED
    bgt return_false
    b   return_true
attack_spattack_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x24]
    cmp   r0,MAX_STAT_BOOST
    bge   spattack_boost_not_max
    b     return_true
attack_defense_boost_not_max: ; BULK UP Base Game
    ldrsh r0,[r7,#0x24]
    cmp   r0,MAX_STAT_BOOST
    bge   defense_boost_not_max
    b     return_true
attack_spdefense_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x24]
    cmp   r0,MAX_STAT_BOOST
    bge   spdefense_boost_not_max
    b     return_true
attack_accuracy_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x24]
    cmp   r0,MAX_STAT_BOOST
    bge   accuracy_boost_not_max
    b     return_true
attack_evasion_boost_not_max: ; UNUSED BASE GAME
    ldrsh r0,[r7,#0x24]
    cmp   r0,MAX_STAT_BOOST
    bge   evasion_boost_not_max
    b     return_true
attack_speed_boost_not_max: ; DRAGON DANCE Base Game
    ldrsh r0,[r7,#0x24]
    cmp   r0,MAX_STAT_BOOST
    bge   speed_not_max
    b     return_true
spattack_defense_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x26]
    cmp   r0,MAX_STAT_BOOST
    bge   defense_boost_not_max
    b     return_true
spattack_spdefense_boost_not_max: ; CALM MIND Base Game
    ldrsh r0,[r7,#0x26]
    cmp   r0,MAX_STAT_BOOST
    bge   spdefense_boost_not_max
    b     return_true
spattack_accuracy_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x26]
    cmp   r0,MAX_STAT_BOOST
    bge   accuracy_boost_not_max
    b     return_true
spattack_evasion_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x26]
    cmp   r0,MAX_STAT_BOOST
    bge   evasion_boost_not_max
    b     return_true
spattack_speed_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x26]
    cmp   r0,MAX_STAT_BOOST
    bge   speed_not_max
    b     return_true
defense_spdefense_boost_not_max: ; COSMIC POWER/DEFEND ORDER Base Game
    ldrsh r0,[r7,#0x28]
    cmp   r0,MAX_STAT_BOOST
    bge   spdefense_boost_not_max
    b     return_true
defense_accuracy_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x28]
    cmp   r0,MAX_STAT_BOOST
    bge   accuracy_boost_not_max
    b     return_true
defense_evasion_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x28]
    cmp   r0,MAX_STAT_BOOST
    bge   evasion_boost_not_max
    b     return_true
defense_speed_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x28]
    cmp   r0,MAX_STAT_BOOST
    bge   speed_not_max
    b     return_true
spdefense_accuracy_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x2A]
    cmp   r0,MAX_STAT_BOOST
    bge   accuracy_boost_not_max
    b     return_true
spdefense_evasion_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x2A]
    cmp   r0,MAX_STAT_BOOST
    bge   evasion_boost_not_max
    b     return_true
spdefense_speed_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x2A]
    cmp   r0,MAX_STAT_BOOST
    bge   speed_not_max
    b     return_true
accuracy_evasion_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x2C]
    cmp   r0,MAX_STAT_BOOST
    bge   evasion_boost_not_max
    b     return_true
accuracy_speed_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x2C]
    cmp   r0,MAX_STAT_BOOST
    bge   speed_not_max
    b     return_true
evasion_speed_boost_not_max: ; UNUSED Base Game
    ldrsh r0,[r7,#0x2E]
    cmp   r0,MAX_STAT_BOOST
    bge   speed_not_max
    b     return_true
weather_not_clear: ; UNUSED Base Game
    mov r4,WEATHER_CLEAR_ID
    b   weather_not_equal
weather_not_sun:
    mov r4,WEATHER_SUN_ID
    b   weather_not_equal
weather_not_sandstorm:
    mov r4,WEATHER_SANDSTORM_ID
    b   weather_not_equal
weather_not_cloudy: ; UNUSED Base Game
    mov r4,WEATHER_CLOUDY_ID
    b   weather_not_equal
weather_not_rain:
    mov r4,WEATHER_RAIN_ID
    b   weather_not_equal
weather_not_hail:
    mov r4,WEATHER_HAIL_ID
    b   weather_not_equal
weather_not_fog: ; UNUSED Base Game
    mov r4,WEATHER_FOG_ID
    b   weather_not_equal
weather_not_snow: ; UNUSED Base Game
    mov r4,WEATHER_SNOW_ID
weather_not_equal:
    mov r0,r8
    bl  GetApparentWeather
    cmp r0,r4
    bne return_true
    b   return_false
not_protected_d5:
    ldrb r0,[r7,#0xD5]
    b   equal_to_zero
not_biding_d2:
    ldrb r0,[r7,#0xD2]
    b   equal_to_zero
not_accuracy_modified_ec:
    ldrb r0,[r7,#0xEC]
    b   equal_to_zero
not_bearing_grudge_fd: ; GRUDGE Base Game
    ldrb r0,[r7,#0xFD]
    b   equal_to_zero
not_magnet_rised_f7: ; MAGNET RISE Base Game
    ldrb r0,[r7,#0xF7]
    b   equal_to_zero
has_stockpiled: ; SPIT UP Base Game
    ldrb r0,[r7,#0x11E]
    cmp r0,#0
    beq return_false
    b   return_true
not_max_stockpiled: ; STOCKPILE Base Game
    ldrb r0,[r7,#0x11E]
    cmp r0,MAX_STOCKPILE
    blt return_true
    b   return_false
can_place_trap_below:
    add r0,r8,#0x4
    bl  CanPlaceTrapBelow
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
not_active_decoy:
    add  r0,r6,#0x3000
    ldrb r0,[r0,#0xE38]
    b    equal_to_zero
has_negative_status_condition:
    bl    MonsterHasNegativeStatus
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
has_sticky_item: ; CLEANSE (modified) Base Game
    ldrb r0,[r7,#0x62]
    tst  r0,#0b1001
    beq  return_false
    b    return_true
has_no_item: ; TAKEAWAY Base Game
    ldrb r0,[r7,#0x62]
    and  r0,r0,#0b1
    eor  r0,r0,#0b1
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
has_item: ; UNUSED Base Game
    ldrb r0,[r7,#0x62]
    and  r0,r0,#0b1
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
not_empty_belly: ; Part of BELLY DRUM Base Game
    add  r0,r7,#0x100
    ldr  r0,[r0,#0x46]
    bl   CeilFixedPoint
    cmp  r0,#1
    bge  return_true
    b    return_false
gravity_not_active: ; UNUSED Base Game
    bl   GravityIsActive
    b    equal_to_zero
has_levitate: ; UNUSED Base Game
    mov   r0,r8
    bl    LevitateIsActive
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
has_low_health: ; UNUSED Base Game
    mov   r0,r8
    bl    HasLowHealth
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
check_dig_and_dive: ; DO NOT USE FOR ANYTHING THAT'S NOT DIG/DIVE
    mov   r0,r8
    bl    GetTileAtEntity
    mov   r4,r0
    bl    SomeDiveDigTileCheck
    cmp   r0,#0
    cmpeq r9,#156 ; Dive ID
    beq   return_true
    ldrh  r0,[r4,#0x0]
    and   r0,r0,#0x3
    cmp   r0,#0x1
    beq   return_true
    b     return_false
check_mirror_move: ; Some exclusive item effects makes mirror move different
    mov r0,r8
    bl  IsMirrorMoveEffectActive
    b   equal_to_zero
check_helping_hand_acupressure: ; Uses Helping Hand check unless ID = 492
    ldrb  r0,[r7,#0x6]
    cmp   r0,#0x0
    mov   r5,#0x12800
    orrne r4,r5,#0x338 ; r6 = 0x12B38 (Start Enemy, inclusive)
    orrne r5,r5,#0x378 ; r8 = 0x12B78 (End Enemy, not inclusive)
    orreq r4,r5,#0x328 ; r6 = 0x12B28 (Start Ally, inclusive)
    orreq r5,r5,#0x338 ; r8 = 0x12B38 (End Ally, not inclusive)
    helping_hand_acupressure_loop:
    add   r0,r4,r6
    ldr   r7,[r0,#0x0] ; Hold Monster in r7, overwrite monster extra data
    mov   r0,r7
    bl    EntityIsValid
    cmp   r0,#0
    beq   helping_hand_acupressure_loop_iter
    cmp   r7,r8
    beq   helping_hand_acupressure_loop_iter
    mov   r0,r8
    mov   r1,r7
    bl    CanSeeTarget
    cmp   r0,#0
    beq   helping_hand_acupressure_loop_iter
    ldr   r0,[r7,#0xB4]
    ldrsh r1,[r0,#0x24]
    ldrsh r2,[r0,#0x26]
    cmp   r1,MAX_STAT_BOOST
    cmpge r2,MAX_STAT_BOOST
    blt   return_true
    cmp   r9,#492 ; Acupressure Move ID
    bne   helping_hand_acupressure_loop_iter
    ldrsh r1,[r0,#0x28]
    ldrsh r2,[r0,#0x2A]
    cmp   r1,MAX_STAT_BOOST
    cmpge r2,MAX_STAT_BOOST
    blt   return_true
    helping_hand_acupressure_loop_iter:
    add  r4,#0x4
    cmp  r4,r5
    blt  helping_hand_acupressure_loop
    b    return_false
check_mud_sport:
    add  r0,r6,#0xC000
    ldrb r0,[r0,#0xD5B]
    b    equal_to_zero
check_rest:
    mov r0,r8
    bl  MonsterHPBelowFourth
    cmp r0,#0
    beq has_negative_status_condition
    b   return_true
check_ingrain: ; Maybe could use not_protected_d5, but original 
    ldrb  r0,[r7,#0xC4] ; never checks 0xD5 despite Ingrain setting it.
    cmp   r0,#5
    beq   return_false
    ldrsh r0,[r7,#0x12]
    ldrsh r1,[r7,#0x16]
    add   r0,r0,r1
    cmp   r0,#1000 ; 999 illegal immediate, be weird because of that
    movge r0,#1000 
    subge r0,r0,#1
    ldrsh r1,[r7,#0x10]
    cmp   r1,r0, asr #1 ; if hp less than half
    ble   return_true
    b     return_false
check_swallow:
    ldrsh r0,[r7,#0x12]
    ldrsh r1,[r7,#0x16]
    add   r0,r0,r1
    cmp   r0,#1000 ; 999 illegal immediate, be weird because of that
    movge r0,#1000
    subge r0,r0,#1
    ldrsh r1,[r7,#0x10]
    cmp   r1,r0 ; if hp not full
    ble   has_stockpiled
    b     return_false
check_belly_drum:
    ldrsh r0,[r7,#0x24]
    cmp   r0,MAX_STAT_BOOST
    bge   return_false
    b     not_empty_belly
check_water_sport:
    add  r0,r6,#0xC000
    ldrb r0,[r0,#0xD5C]
    b    equal_to_zero
check_destiny_bond:
    ldrb r0,[r7,#0xE0]
    b    not_equal_to_two
check_snatch:
    ldrb r0,[r7,#0xD8]
    cmp  r0,#3
    beq  return_false
    b    return_true
check_trapbuster:
    mov  r0,r8
    bl   GetTileAtEntity
    ldr  r0,[r0,#0x10]
    cmp  r0,#0
    beq  return_false
    ldr  r0,[r0,#0x0]
    cmp  r0,#2
    beq  return_true
    b    return_false
check_invisify:
    ldrb r0,[r6,#0xEF]
    cmp  r0,#1
    beq  return_false
    b    return_true
check_lucky_chant: ; Could also be not_protected_d5_in_room
    ldrb  r0,[r6,#0x6]
    cmp   r0,#0x0
    mov   r5,#0x12800
    orrne r4,r5,#0x338 ; r6 = 0x12B38 (Start Enemy, inclusive)
    orrne r5,r5,#0x378 ; r8 = 0x12B78 (End Enemy, not inclusive)
    orreq r4,r5,#0x328 ; r6 = 0x12B28 (Start Ally, inclusive)
    orreq r5,r5,#0x338 ; r8 = 0x12B38 (End Ally, not inclusive)
    lucky_chant_loop:
    add   r0,r4,r6
    ldr   r7,[r0,#0x0] ; Hold Monster in r7, overwrite monster extra data
    mov   r0,r7
    bl    EntityIsValid
    cmp   r0,#0
    beq   lucky_chant_loop_iter
    cmp   r7,r8 ; Check if ally isn't same? Not necessary but base game does it
    beq   lucky_chant_loop_iter
    mov   r0,r8
    mov   r1,r7
    bl    CanSeeTarget
    cmp   r0,#0
    beq   lucky_chant_loop_iter
    ldr   r0,[r7,#0xB4]
    ldrb  r0,[r0,#0xD5]
    cmp   r0,#0 ; Modified here, base game only returns true if not == 11
    beq   return_true
    lucky_chant_loop_iter:
    add  r4,#0x4
    cmp  r4,r5
    blt  lucky_chant_loop
    b    return_false
check_camouflage:
    mov    r0,r8
    mov    r2,#0xC
    ldr    r3,=PTR_CAMOUFLAGE_TYPES
    add    r1,r6,#0x4000
    ldrsh  r1,[r1,#0xD4]
    smulbb r1,r1,r2
    ldrb   r1,[r3,r1]
    bl     MonsterIsType
    b      equal_to_zero ; ADD YOUR OWN CHECKS BELOW THIS LINE
check_transform: ; ADD YOUR OWN CHECKS ABOVE THIS LINE
    bl   IsCurrentFixedRoomBossFight
    cmp  r0,#0
    bne  return_false
    ldrb r0,[r7,#0xEF]
not_equal_to_two: ; Barely saves instructions, for TRANSFORM/DESTINY BOND
    cmp  r0,#2
    beq  return_false
    b    return_true
not_fixed_room_boss_fight:
    bl  IsCurrentFixedRoomBossFight
equal_to_zero: ; Save some instructions with this.
    cmp r0,#0
    beq return_true
return_false:
    mov r0,#0
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
return_true:
    mov r0,#1
    ldmia sp!,{r3,r4,r5,r6,r7,r8,r9,pc}
    .pool
.endarea

; Original StatusCheckerCheck Starts At 0x02333074 (NA)
; Original StatusCheckerCheck Ends At 0x02333F97 (NA)
; So original space is 969 Instructions, some of which will be needed
; for the PTR_DUNGEON_PTR and other variables in the pool.