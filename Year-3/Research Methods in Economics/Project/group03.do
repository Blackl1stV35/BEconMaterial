* Setup
clear all
set more off
set linesize 120
version 17

capture log close
log using "group03_WellBeing", replace text

* Import + disqualify
import delimited "google_form.tsv", ///
    encoding(UTF-8) clear varnames(nonames) delimiter(tab)

drop if _n == 1   

rename v1  timestamp
rename v2  sector_raw
rename v3  age_raw
rename v4  gender_raw
rename v5  living_raw
rename v6  income_raw
rename v7  ladder_raw
rename v8  soc_hrs_raw
rename v9  pas_inf_raw
rename v10 pas_lux_raw
rename v11 pas_cmp_raw
rename v12 close_ppl_raw
rename v13 ppl_care_raw
rename v14 nbr_help_raw
rename v15 cfpb_hard_raw
rename v16 cfpb_sit_raw
rename v17 cfpb_wry_raw
rename v18 cfpb_emg_raw
rename v19 cfpb_mon_raw
rename v20 cfpb_con_raw
rename v21 who1_raw
rename v22 who2_raw
rename v23 who3_raw
rename v24 who4_raw
rename v25 who5_raw

drop if age_raw == "มากกว่า 45 ปี"
drop if age_raw == "น้อยกว่า 18 ปี"
drop if missing(gender_raw)  

count

* Ordinal Encoding
destring ladder_raw, gen(SubStat) force
label variable SubStat "MacArthur subjective social rank (1=bottom, 10=top)"

gen byte SOC_HRS = .
replace SOC_HRS = 1 if soc_hrs_raw == "น้อยกว่า 1 ชั่วโมง"
replace SOC_HRS = 2 if soc_hrs_raw == "1 — 2 ชั่วโมง"
replace SOC_HRS = 3 if soc_hrs_raw == "2 — 4 ชั่วโมง"
replace SOC_HRS = 4 if soc_hrs_raw == "4 — 6 ชั่วโมง"
replace SOC_HRS = 5 if soc_hrs_raw == "มากกว่า 6 ชั่วโมง"
label variable SOC_HRS "Daily social media hours (1=<1hr, 5=>6hrs)"

foreach v in who1 who2 who3 who4 who5 {
    gen byte `v' = .
    replace `v' = 0 if `v'_raw == "ไม่เคยเลย"
    replace `v' = 1 if `v'_raw == "น้อยกว่าครึ่งหนึ่งของเวลา"
    replace `v' = 2 if `v'_raw == "บางครั้ง"
    replace `v' = 3 if `v'_raw == "มากกว่าครึ่งหนึ่งของเวลา"
    replace `v' = 4 if `v'_raw == "ส่วนใหญ่ของเวลา"
    replace `v' = 5 if `v'_raw == "ตลอด"
}

foreach v in pas_inf pas_lux pas_cmp {
    gen byte `v' = .
    replace `v' = 1 if `v'_raw == "ไม่เคย"
    replace `v' = 2 if `v'_raw == "น้อย"
    replace `v' = 3 if `v'_raw == "บางครั้ง"
    replace `v' = 4 if `v'_raw == "บ่อยครั้ง"
    replace `v' = 5 if `v'_raw == "บ่อยมาก"
}

foreach v in cfpb_hard cfpb_sit cfpb_wry {
    gen byte `v' = .
    replace `v' = 0 if `v'_raw == "ไม่เลย"
    replace `v' = 1 if `v'_raw == "น้อยมาก"
    replace `v' = 2 if `v'_raw == "บ้าง"
    replace `v' = 3 if `v'_raw == "ส่วนใหญ่"
    replace `v' = 4 if `v'_raw == "ตลอดเวลา"
}

gen byte cfpb_emg = .
replace cfpb_emg = 0 if cfpb_emg_raw == "ไม่เลย"
replace cfpb_emg = 1 if cfpb_emg_raw == "น้อยมาก"
replace cfpb_emg = 2 if cfpb_emg_raw == "บ้าง"
replace cfpb_emg = 3 if cfpb_emg_raw == "ส่วนใหญ่"
replace cfpb_emg = 4 if cfpb_emg_raw == "ตลอดเวลา"

gen byte cfpb_mon = (cfpb_mon_raw == "ตลอด") if !missing(cfpb_mon_raw)
gen byte cfpb_con = (cfpb_con_raw == "ตลอด") if !missing(cfpb_con_raw)

gen byte close_ppl = .
replace close_ppl = 0 if close_ppl_raw == "ไม่มี"
replace close_ppl = 1 if close_ppl_raw == "1 — 2 คน"
replace close_ppl = 2 if close_ppl_raw == "3 — 5 คน"
replace close_ppl = 3 if close_ppl_raw == "มากกว่า 5 คน"

gen byte ppl_care = .
replace ppl_care = 1 if ppl_care_raw == "ไม่มีเลย"
replace ppl_care = 2 if ppl_care_raw == "น้อย"
replace ppl_care = 3 if ppl_care_raw == "ไม่แน่ใจ"     // sara ae U+0E41
replace ppl_care = 3 if ppl_care_raw == "ไม่เเน่ใจ"    // double sara e variant in data
replace ppl_care = 4 if ppl_care_raw == "มาก"
replace ppl_care = 5 if ppl_care_raw == "มากที่สุด"

gen byte nbr_help = .
replace nbr_help = 1 if nbr_help_raw == "ยากมาก"
replace nbr_help = 2 if nbr_help_raw == "ยาก"
replace nbr_help = 3 if nbr_help_raw == "เป็นไปได้"
replace nbr_help = 4 if nbr_help_raw == "ง่าย"
replace nbr_help = 5 if nbr_help_raw == "ง่ายมาก"

gen byte inc_num = .
replace inc_num = 1 if income_raw == "น้อยกว่า 10,000 บาท"
replace inc_num = 2 if income_raw == "10,000 — 20,000 บาท"
replace inc_num = 3 if income_raw == "20,001 — 30,000 บาท"
replace inc_num = 4 if income_raw == "30,001 — 50,000 บาท"
replace inc_num = 5 if income_raw == "50,001 — 80,000 บาท"
replace inc_num = 6 if income_raw == "80,001 — 150,000 บาท"
replace inc_num = 7 if income_raw == "มากกว่า 150,000 บาท"

di "=== Encoding Completeness Check ==="
foreach v in who1 who2 who3 who4 who5 ///
             pas_inf pas_lux pas_cmp ///
             cfpb_hard cfpb_sit cfpb_wry cfpb_emg cfpb_mon cfpb_con ///
             close_ppl ppl_care nbr_help inc_num SOC_HRS {
    qui count if missing(`v')
    if r(N) > 0  di "  WARNING: `v' — " r(N) " unmatched values"
    else         di "  `v': OK"
}

* Constructing index
egen who5_sum = rowtotal(who1 who2 who3 who4 who5)
gen  WHO5 = who5_sum * 4
label variable WHO5 "WHO-5 Well-Being Index (0-100)"
assert WHO5 >= 0 & WHO5 <= 100 if !missing(WHO5)

gen byte atrisk = (WHO5 <= 50)
label variable atrisk "WHO5 <= 50 = at-risk well-being"

egen PasExp = rowmean(pas_inf pas_lux pas_cmp)
label variable PasExp "Passive Social Media Exposure (mean 3 items, 1-5)"
assert PasExp >= 1 & PasExp <= 5 if !missing(PasExp)

egen PsySca = rowmean(cfpb_hard cfpb_sit cfpb_wry)
label variable PsySca "CFPB worry subscale: psychological scarcity (0-4)"

gen cfpb_emg_norm = cfpb_emg / 4
egen CFPB_liquid = rowmean(cfpb_mon cfpb_con cfpb_emg_norm)
label variable CFPB_liquid "CFPB liquidity subscale (0-1)"

gen HHInc = inc_num
label variable HHInc "Household income bracket (1=<10k THB, 7=>150k THB)"

gen close_ppl_std = close_ppl / 3
gen ppl_care_std  = (ppl_care - 1) / 4
gen nbr_help_std  = (nbr_help - 1) / 4
egen OSSS3 = rowmean(close_ppl_std ppl_care_std nbr_help_std)
label variable OSSS3 "Offline Social Support Scale (mean 3 normalised items, 0-1)"

gen PAS_x_LADDER = PasExp * SubStat
label variable PAS_x_LADDER "Interaction: PasExp x SubStat"

* ======================================================
* Centering conditional PasExp, SubStat
quietly summarize PasExp
gen PasExp_c = PasExp - r(mean)

quietly summarize SubStat
gen SubStat_c = SubStat - r(mean)
* ======================================================

* Constructing interaction term (PasExp x SubStat)
gen PasExpc_SubStatc = PasExp_c * SubStat_c

label variable PasExp_c          "PasExp centered at mean"
label variable SubStat_c         "SubStat centered at mean"
label variable PasExpc_SubStatc  "Centered PasExp x SubStat interaction"

di "=== Index Summary ==="
summarize WHO5 PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS OSSS3

* EFA for Adapted CFPB SubScale Structure
* Note: Justifying 2-SubScales

* EFA: Psychological Scarcity subscale (hard/sit/wry)
factor cfpb_hard cfpb_sit cfpb_wry, pcf factors(1)
estat kmo           // Kaiser-Meyer-Olkin measure of sampling adequacy
alpha cfpb_hard cfpb_sit cfpb_wry, item std casewise

* EFA: Liquidity Constraint subscale (emg/mon/con)
gen cfpb_emg_rev = 4 - cfpb_emg
label variable cfpb_emg_rev "cfpb_emg reversed (0=full, 4=none)"

* cfpb_mon and cfpb_con are binary (1 = always covers; reverse for constraint)
gen cfpb_mon_rev = 1 - cfpb_mon
gen cfpb_con_rev = 1 - cfpb_con
label variable cfpb_mon_rev "cfpb_mon reversed (1=does NOT cover monthly)"
label variable cfpb_con_rev "cfpb_con reversed (1=NOT confident)"

factor cfpb_emg_rev cfpb_mon_rev cfpb_con_rev, pcf factors(1)
estat kmo
alpha cfpb_emg_rev cfpb_mon_rev cfpb_con_rev, item std casewise

* Drop fac2_liquid --> error
cap drop fac2_liquid      

* Cronbach Alpha
di _newline "--- 5A. WHO5 (5 items) ---"
alpha who1 who2 who3 who4 who5, item std casewise
pwcorr who1 who2 who3 who4 who5, sig star(0.05)

di _newline "--- 5B. PasExp (3 items) ---"
alpha pas_inf pas_lux pas_cmp, item std casewise
pwcorr pas_inf pas_lux pas_cmp, sig star(0.05)

di _newline "--- 5C. PsySca subscale (3 items) ---"
alpha cfpb_hard cfpb_sit cfpb_wry, item std casewise
pwcorr cfpb_hard cfpb_sit cfpb_wry, sig star(0.05)

di _newline "--- 5D. CFPB all 6 items ---"
alpha cfpb_hard cfpb_sit cfpb_wry cfpb_emg cfpb_mon cfpb_con, item std casewise

di _newline "--- 5E. OSSS3 (3 normalised items) ---"
alpha close_ppl_std ppl_care_std nbr_help_std, item std casewise
pwcorr close_ppl_std ppl_care_std nbr_help_std, sig star(0.05)


* CFA
di _newline "--- 6A. WHO5 (1 factor, 5 indicators) ---"
sem (WellBeing -> who1 who2 who3 who4 who5), method(ml) vce(robust)
estat gof, stats(all)
sem, standardized

di _newline "--- 6B. PasExp (1 factor, 3 indicators) ---"
sem (MediaExp -> pas_inf pas_lux pas_cmp), method(ml) vce(robust)
estat gof, stats(all)
sem, standardized

di _newline "--- 6C. PsySca subscale (1 factor, 3 indicators) ---"
sem (FinStress -> cfpb_hard cfpb_sit cfpb_wry), method(ml) vce(robust)
estat gof, stats(all)
sem, standardized

di _newline "--- 6D. OSSS3 (1 factor, 3 normalised indicators) ---"
sem (SocSupp -> close_ppl_std ppl_care_std nbr_help_std), method(ml) vce(robust)
estat gof, stats(all)
sem, standardized

di _newline "--- 6E. Full 3-construct model (discriminant validity) ---"
sem (WellBeing -> who1 who2 who3 who4 who5) ///
    (MediaExp   -> pas_inf pas_lux pas_cmp) ///
    (FinStress  -> cfpb_hard cfpb_sit cfpb_wry), ///
    method(ml) vce(robust) ///
    cov(WellBeing*MediaExp WellBeing*FinStress MediaExp*FinStress)
estat gof, stats(all)
sem, standardized

* Descriptive Statistics
summarize WHO5 PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS OSSS3, detail

di _newline "--- At-risk prevalence (WHO5 <= 50) ---"
tab atrisk

* Correlation Analysis: Spearman ranking matrix
di _newline "--- Spearman correlations ---"
spearman WHO5 PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS, stats(rho p) pw

di _newline "--- Sample demographics ---"
tab gender_raw
tab age_raw
tab living_raw
tab sector_raw

* Dummy Variables
gen byte d_female = (gender_raw == "หญิง") if !missing(gender_raw)
gen byte d_gnd_nd = (gender_raw == "ไม่ต้องการระบุ") if !missing(gender_raw)
label variable d_female "Female (ref: male)"
label variable d_gnd_nd "Gender not disclosed (ref: male)"
tab gender_raw

gen byte d_age25_34 = (age_raw == "25 — 34 ปี") if !missing(age_raw)
gen byte d_age35_44 = (age_raw == "35 — 44 ปี") if !missing(age_raw)
label variable d_age25_34 "Age 25-34 (ref: 18-24)"
label variable d_age35_44 "Age 35-44 (ref: 18-24)"
tab d_age25_34 d_age35_44

gen byte d_live_alone  = (living_raw == "อยู่คนเดียว") if !missing(living_raw)
gen byte d_live_shared = (living_raw == "อยู่กับเพื่อน / คู่รัก / แชร์ที่พัก") if !missing(living_raw)
gen byte d_live_other  = inlist(living_raw, "บ้านเช่า","หอพัก","อพาร์ทเม้นท์", ///
                                             "พักในที่ทำงาน","คอนโด") if !missing(living_raw)
label variable d_live_alone   "Live alone (ref: with family)"
label variable d_live_shared  "Live with partner/friends (ref: with family)"
label variable d_live_other   "Rented/independent dwelling (ref: with family)"
tab d_live_alone
tab d_live_shared
tab d_live_other

* Reclassifying sector_raw from others inputted fields
replace sector_raw = "การค้าส่ง ค้าปลีก และการซ่อมแซม" ///
    if inlist(sector_raw, "E-commerce ","E-commerce","ขายของออนไลน์")
replace sector_raw = "อุตสาหกรรมการผลิตและโรงงาน" ///
    if sector_raw == "บริษัทผลิตยาปัจจุบันและเครื่องสำอาง"
replace sector_raw = "การบริหารราชการและรัฐวิสาหกิจ" ///
    if inlist(sector_raw, "รับราชการ","ลูกจ้างของรัฐ")
replace sector_raw = "สุขภาพและกิจกรรมทางสังคม" ///
    if sector_raw == "รพ.สต."

* Reclassifying sector_raw from	from choices
gen byte WrkIndy_IT   = (sector_raw == "การสื่อสารและเทคโนโลยีสารสนเทศ") if !missing(sector_raw)
gen byte WrkIndy_Edu  = (sector_raw == "การศึกษา") if !missing(sector_raw)
gen byte WrkIndy_Mfg  = (sector_raw == "อุตสาหกรรมการผลิตและโรงงาน") if !missing(sector_raw)
gen byte WrkIndy_Ret  = (sector_raw == "การค้าส่ง ค้าปลีก และการซ่อมแซม") if !missing(sector_raw)
gen byte WrkIndy_Hosp = (sector_raw == "ที่พักแรมและบริการด้านอาหาร") if !missing(sector_raw)
gen byte WrkIndy_Log  = (sector_raw == "การขนส่งและคลังสินค้า") if !missing(sector_raw)
gen byte WrkIndy_Hlth = (sector_raw == "สุขภาพและกิจกรรมทางสังคม") if !missing(sector_raw)
gen byte WrkIndy_Pub  = (sector_raw == "การบริหารราชการและรัฐวิสาหกิจ") if !missing(sector_raw)
label variable WrkIndy_IT   "IT/ICT (ref: Finance & Insurance)"
label variable WrkIndy_Edu  "Education (ref: Finance & Insurance)"
label variable WrkIndy_Mfg  "Manufacturing (ref: Finance & Insurance)"
label variable WrkIndy_Ret  "Retail/Trade (ref: Finance & Insurance)"
label variable WrkIndy_Hosp "Hospitality/F&B (ref: Finance & Insurance)"
label variable WrkIndy_Log  "Transport/Logistics (ref: Finance & Insurance)"
label variable WrkIndy_Hlth "Health/Social (ref: Finance & Insurance)"
label variable WrkIndy_Pub  "Public Administration (ref: Finance & Insurance)"

* Collapse WrkIndy to Contextual Working Groups
gen byte WrkIndy_grp = .

replace WrkIndy_grp = 1 if inlist(sector_raw, ///
    "การเงินและประกันภัย", ///
    "การสื่อสารและเทคโนโลยีสารสนเทศ", ///
    "พนักงานบริษัท")

replace WrkIndy_grp = 2 if inlist(sector_raw, ///
    "การบริหารราชการและรัฐวิสาหกิจ", ///
    "การศึกษา", ///
    "สุขภาพและกิจกรรมทางสังคม")

replace WrkIndy_grp = 3 if inlist(sector_raw, ///
    "การค้าส่ง ค้าปลีก และการซ่อมแซม", ///
    "ที่พักแรมและบริการด้านอาหาร", ///
    "การขนส่งและคลังสินค้า")

replace WrkIndy_grp = 4 if inlist(sector_raw, ///
    "อุตสาหกรรมการผลิตและโรงงาน", ///
    "การเกษตรกรรม ป่าไม้ และประมง", ///
    "รับจ้างทั่วไป")

replace WrkIndy_grp = 5 if sector_raw == "นักเรียน/นักศึกษา"

* Set unclassified to Group 6
replace WrkIndy_grp = 6 if missing(WrkIndy_grp) & !missing(sector_raw)

label define lgrp 1 "Corporate/Prof" 2 "Public/Essential" 3 "Commerce/Hosp" ///
                  4 "Labor/Ag/Informal" 5 "Students" 6 "Unclassified"
label values WrkIndy_grp lgrp

tab WrkIndy_grp
count if missing(WrkIndy_grp) & !missing(sector_raw)

* ======================================================
* Visualization variables for descriptive statistical  
set scheme s1color

histogram WHO5, ///
    width(8) freq ///
    kdensity kdenopts(lcolor(cranberry) lwidth(medthick)) ///
    color(edkblue%50) lcolor(edkblue) ///
    xline(50, lcolor(red) lpattern(dash) lwidth(medium)) ///
    title("Distribution of WHO-5 Well-Being (0–100)", size(medium)) ///
    xtitle("WHO-5 Score") ytitle("Frequency") ///
    name(g_who5, replace)
graph export "summary_WHO5.png", name(g_who5) replace width(1200)

histogram PasExp, ///
    discrete freq ///
    color(dkorange%60) lcolor(dkorange) ///
    xline(2.936, lcolor(navy) lpattern(dash) lwidth(medium)) ///
    title("Passive Social Media Exposure (PasExp)", size(medium)) ///
    xtitle("PasExp Score (1=Never, 5=Very often)") ytitle("Frequency") ///
    xlabel(1 2 3 4 5) ///
    name(g_pasex, replace)
graph export "summary_PasEx.png", name(g_pasex) replace width(1200)

qui sum PsySca, detail
local psy_med = r(p50)
histogram PsySca, ///
    width(0.33) freq ///
    kdensity kdenopts(lcolor(purple) lwidth(medthick)) ///
    color(purple%40) lcolor(purple) ///
    xline(`psy_med', lcolor(maroon) lpattern(dash) lwidth(medium)) ///
    title("Psychological Scarcity (PsySca)", size(medium)) ///
    xtitle("PsySca Score (0=None, 4=Constant)") ytitle("Frequency") ///
    name(g_psy, replace)
graph export "summary_PsySca.png", name(g_psy) replace width(1200)

histogram SubStat, ///
    discrete freq ///
    color(teal%60) lcolor(teal) ///
    xline(6.124, lcolor(red) lpattern(dash) lwidth(medium)) ///
    title("Subjective Social Status (SubStat)", size(medium)) ///
    xtitle("MacArthur Ladder (1=Bottom, 10=Top)") ytitle("Frequency") ///
    xlabel(1(1)10) ///
    name(g_sub, replace)
graph export "summary_SubStat.png", name(g_sub) replace width(1200)

histogram CFPB_liquid, ///
    width(0.083) freq ///
    kdensity kdenopts(lcolor(dkgreen) lwidth(medthick)) ///
    color(dkgreen%40) lcolor(dkgreen) ///
    title("Liquidity Constraint Subscale (CFPB_liquid)", size(medium)) ///
    xtitle("CFPB_liquid Score (0=No constraint, 1=Full constraint)") ytitle("Frequency") ///
    name(g_liq, replace)
graph export "summary_CFPB_liquid.png", name(g_liq) replace width(1200)

histogram HHInc, ///
    discrete freq ///
    color(sienna%60) lcolor(sienna) ///
    xline(3.809, lcolor(navy) lpattern(dash) lwidth(medium)) ///
    title("Household Income Bracket (HHInc)", size(medium)) ///
    xtitle("Income Bracket (1=<10k THB, 7=>150k THB)") ytitle("Frequency") ///
    xlabel(1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7") ///
    name(g_inc, replace)
graph export "summary_HHInc.png", name(g_inc) replace width(1200)

histogram SOC_HRS, ///
    discrete freq ///
    color(gold%70) lcolor(gold) ///
    title("Daily Social Media Hours (SOC_HRS)", size(medium)) ///
    xtitle("Hours Bracket (1=<1hr, 5=>6hrs)") ytitle("Frequency") ///
    xlabel(1 "<1hr" 2 "1-2hr" 3 "2-4hr" 4 "4-6hr" 5 ">6hr") ///
    name(g_soc, replace)
graph export "summary_SOC_HRS.png", name(g_soc) replace width(1200)

histogram OSSS3, ///
    width(0.05) freq ///
    kdensity kdenopts(lcolor(midblue) lwidth(medthick)) ///
    color(midblue%40) lcolor(midblue) ///
    title("Offline Social Support Scale (OSSS3)", size(medium)) ///
    xtitle("OSSS3 Score (0=No support, 1=Full support)") ytitle("Frequency") ///
    name(g_oss, replace)
graph export "summary_OSSS3.png", name(g_oss) replace width(1200)

graph combine g_who5 g_pasex g_psy g_sub, ///
    cols(2) ///
    title("Core Study Variables — Distribution Summary", size(medsmall)) ///
    xsize(14) ysize(10)
graph export "summary_core4_combined.png", replace width(1600)
* ======================================================

* OLS no robust 
quietly regress WHO5 ///
    PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other

* Test Heteroskedasticity: Breusch-Pagan / Cook-Weisberg test
estat hettest

* Test Heteroskedasticity+Non-linearity: White's general test
estat imtest, white

* ======================================================
* Plot Residual VS Fitted Plot
predict resid_ols, residuals
predict yhat_ols,  xb
scatter resid_ols yhat_ols, ///
    yline(0, lcolor(red) lpattern(dash)) ///
    title("Residuals vs Fitted — M1 (plain OLS)") ///
    xtitle("Fitted values") ytitle("Residuals") ///
    mcolor(navy%40) msymbol(smcircle) ///
    name(g_hettest, replace)
graph export "diag_residvsfitted_OLS.png", replace width(1200)
* ======================================================

* M1 (Base Model) + Robust applied
regress WHO5 ///
    PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other, ///
    vce(robust)
estimates store M1_robust_confirmed

* Test Normality: Shapiro-Wilk in M1 (Base Model)
swilk resid_ols

* Test Normality: Skewness-Kurtosis Test 
sktest resid_ols

* ======================================================
* Plot Q-Q, P-P Plots
qnorm resid_ols, ///
    title("Normal Q-Q Plot — M1 Residuals") ///
    name(g_qq, replace)
graph export "diag_qqplot_M1.png", replace width(1200)

pnorm resid_ols, ///
    title("Normal P-P Plot — M1 Residuals") ///
    name(g_pp, replace)
graph export "diag_ppplot_M1.png", replace width(1200)
* ======================================================

* Re-run OLS for Post-Estimation Leverage/Influencial
quietly regress WHO5 ///
    PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other

* Leverag-residual Squared Plot
lvr2plot, ///
    title("Leverage vs Normalized Residual² — M1") ///
    name(g_lvr2, replace)
graph export "diag_lvr2plot_M1.png", replace width(1200)

* Cook's Distance
predict cookd, cooksd
* Set Conventional threshold = 4/N
scalar thresh_cook = 4 / e(N)
di "  Cook's D threshold (4/N = 4/" e(N) "): " %6.4f thresh_cook

count if cookd > thresh_cook & !missing(cookd)
di "  Observations exceeding threshold: " r(N)

* List Influential Observations (Cook's Distance > 4/N)
gen influential = (cookd > thresh_cook) if !missing(cookd)
label variable influential "Cook's D > 4/N"

list WHO5 PasExp SubStat PsySca HHInc cookd if influential == 1, ///
    sepby(influential) noobs

* Identify Outliers in Y 
predict stdres, rstandard
count if abs(stdres) > 2.5 & !missing(stdres)
di "  Observations with |stdres| > 2.5: " r(N)

count if abs(stdres) > 3 & !missing(stdres)
di "  Observations with |stdres| > 3 (severe): " r(N)

* Sensitivity Check: Re-run M1 (Base Model)+Robusted excluding influential obs. 
regress WHO5 ///
    PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other ///
    if influential == 0, vce(robust)
estimates store M1_no_influential

* Compare M1 VS M1 with no influential coefficients
estimates table M1_robust_confirmed M1_no_influential, ///
    b(%8.3f) se(%8.3f) stats(N r2) ///
    title("M1: Full sample vs Influential Observations Excluded")
	
* ======================================================
* Testing M1 without CFPB_liquid 
quietly regress WHO5 ///
    PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other
estimates store M1_ols_full

quietly regress WHO5 ///
    PasExp PsySca SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other
estimates store M1_ols_drop

lrtest M1_ols_full M1_ols_drop

* AIC/BIC Comparison
estimates stats M1_ols_full M1_ols_drop

* Robust M1 without CFPB_liquid
regress WHO5 ///
    PasExp PsySca SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other, ///
    vce(robust)
estimates store M1_no_liquid

* Testing core coefficients without CFPB_liquid
estimates table M1_robust_confirmed M1_no_liquid, ///
    keep(PasExp PsySca SubStat) b(%8.3f) se(%8.3f) ///
    title("Core coefficients: M1 with vs without CFPB_liquid")	

* M1 (Base Model) with CFPB_liquid
regress WHO5 ///
    PasExp PsySca CFPB_liquid ///
    SubStat ///
    HHInc SOC_HRS ///
    d_female d_gnd_nd ///
    d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other, ///
    vce(robust)

estimates store M1
di "M1: R2=" e(r2) " | Adj-R2=" e(r2_a) " | N=" e(N) " | df_res=" e(df_r)

test PasExp PsySca SubStat

* Hypothesis testing on M1 (Base Model)
lincom PsySca
lincom SubStat
lincom PasExp

* M1r (Base Model with Working Industry)
regress WHO5 ///
    PasExp PsySca CFPB_liquid ///
    SubStat ///
    HHInc SOC_HRS ///
    d_female d_gnd_nd ///
    d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other ///
    ib1.WrkIndy_grp, vce(robust)

estimates store M1r
di "M1r: R2=" e(r2) " | Adj-R2=" e(r2_a) " | N=" e(N)

test PasExp PsySca SubStat

* Multiconllinearity Testing: VIF on Base Model
qui regress WHO5 PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other
vif

* Multiconllinearity Testing: VIF on Core Variables
qui regress WHO5 PasExp_c SubStat_c PasExpc_SubStatc PsySca
vif

* Multiconllinearity Testing: Pairwise 
pwcorr PasExp PsySca CFPB_liquid SubStat HHInc OSSS3, sig star(0.05)

* M3 (Uncenter Mean) with Interaction Term included and Control Lists dropped
regress WHO5 c.PasExp##c.SubStat PsySca, vce(robust)
estimates store M3

di "M3: R2=" e(r2) " | Adj-R2=" e(r2_a) " | N=" e(N)

* Partial Differentials
scalar b_PAS   = _b[PasExp]
scalar b_LAD   = _b[SubStat]
scalar b_INT   = _b[c.PasExp#c.SubStat]
scalar b_CW    = _b[PsySca]
scalar b_CONST = _b[_cons]

di _newline "COEFFICIENTS:"
di "  a (constant):      " %7.3f b_CONST
di "  b1 (PasExp direct):   " %7.3f b_PAS
di "  b2 (SubStat direct):" %7.3f b_LAD
di "  b3 (PsySca):   " %7.3f b_CW
di "  b4 (PasExp x SubStat): " %7.4f b_INT

di _newline "SUBSTITUTED EQUATION:"
di "  WHO5 = " %5.2f b_CONST " + (" %6.3f b_PAS ")·PasExp + (" %6.3f b_LAD ")·SubStat"
di "               + (" %6.4f b_INT ")·(PasExp x SubStat) + (" %6.3f b_CW ")·PsySca"

test PasExp SubStat c.PasExp#c.SubStat PsySca

* M3c (Center Mean)
regress WHO5 c.PasExp_c##c.SubStat_c PsySca, vce(robust)
estimates store M3c

* Comparing Models
estimates stats M1 M1r M3

* Heteroskedasticity Testing: M3 Model without Robust
quietly regress WHO5 ///
    PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other

test CFPB_liquid HHInc SOC_HRS ///
     d_female d_gnd_nd d_age25_34 d_age35_44 ///
     d_live_alone d_live_shared d_live_other
	 
* ======================================================
* Comparing M1 VS M3 on plain OLS	 
di _newline "--- [F2] Re-state M3 for reference ---"
regress WHO5 c.PasExp##c.SubStat PsySca, vce(robust)
estimates store M3_confirmed

quietly regress WHO5 ///
    PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other
estimates store M1_ols_f

quietly regress WHO5 c.PasExp##c.SubStat PsySca
estimates store M3_ols_f

estimates stats M1_ols_f M3_ols_f

* Adding Control Lists to M3 Model with Interaction Term included 
regress WHO5 c.PasExp##c.SubStat PsySca ///
    CFPB_liquid HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other, ///
    vce(robust)
estimates store M3_full_controls

esttab M3_confirmed M3_full_controls, ///
    keep(PasExp SubStat c.PasExp#c.SubStat PsySca) ///
    b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Interaction robustness: M3 parsimonious vs M3 with full controls") ///
    mtitles("M3_confirmed" "M3_full_controls")
* ======================================================

* Hypothesis Re-Testing
qui regress WHO5 c.PasExp##c.SubStat PsySca, vce(robust)

lincom PsySca

qui sum PasExp
local pas_bar = r(mean)
di "  Mean PasExp = `pas_bar'"
di "  MEM(SubStat) = " b_LAD + b_INT*`pas_bar'
lincom SubStat + `pas_bar' * c.PasExp#c.SubStat

qui sum SubStat
local lad_bar = r(mean)
di "  Mean SubStat = `lad_bar'"
di "  MEM(PasExp) = " b_PAS + b_INT*`lad_bar'
lincom PasExp + `lad_bar' * c.PasExp#c.SubStat

test c.PasExp#c.SubStat
lincom c.PasExp#c.SubStat

* ======================================================
* Computing Marginal Effects + Ploting
qui regress WHO5 c.PasExp##c.SubStat PsySca, vce(robust)

margins, dydx(*) atmeans

margins, dydx(PasExp) at(SubStat=(1 2 3 4 5 6 7 8 9 10))
marginsplot, ///
    yline(0, lcolor(red) lpattern(dash)) ///
    title("Marginal Effect of PasExp on WHO5 by Social Rank (M3)") ///
    xtitle("MacArthur Ladder") ytitle("dWHO5/dPAS")
graph export "ME_PAS_by_LADDER.png", replace width(1200)

margins, dydx(SubStat) at(PasExp=(1 2 3 4 5))
marginsplot, ///
    title("Marginal Effect of SubStat on WHO5 by PasExp Level (M3)") ///
    xtitle("PasExp Index") ytitle("dWHO5/dLADDER")
graph export "ME_LADDER_by_PAS.png", replace width(1200)

margins, at(PasExp=(1 2 3 4 5) SubStat=(1 2 3 4 5 6 7 8 9 10))
marginsplot, ///
    x(SubStat) ///
    title("Predicted WHO5: PasExp x SubStat Surface (M3)") ///
    ytitle("Predicted WHO-5 (0-100)") xtitle("MacArthur Ladder")
graph export "interaction_surface.png", replace width(1400)

margins, dydx(PasExp SubStat) over(d_age25_34 d_age35_44) atmeans

margins, dydx(PasExp SubStat) over(d_female) atmeans
* ======================================================

* ======================================================
* Marginal Effects by Industry Groups 

* Predicting WHO5 by Industry Groups
margins, over(WrkIndy_grp) atmeans

marginsplot, ///
    recast(bar) recastci(rcap) ///
    ciopt(lcolor(gs8) lwidth(medium)) ///
    ytitle("Predicted WHO-5 (0–100)") ///
    xtitle("") ///
    xlabel(1 `" "Corporate/" "Prof" "' ///
           2 `" "Public/" "Essential" "' ///
           3 `" "Commerce/" "Hosp" "' ///
           4 `" "Labor/Ag/" "Informal" "', noticks) ///
    yline(50, lcolor(red) lpattern(dash) lwidth(medium)) ///
    title("Predicted WHO-5 Well-Being by Industry Group (M3)", size(medium)) ///
    note("Red dashed line = clinical at-risk threshold (50)" ///
         "Bars = predicted margins at group means | 95% CI shown" ///
         "Restricted N = WrkIndy_grp 1–4 | vce(robust)") ///
    name(g_ind_pred, replace)
graph export "ME_industry_predicted_WHO5.png", name(g_ind_pred) replace width(1200)

* ME PasExp by Industry Group
margins, dydx(PasExp) over(WrkIndy_grp) atmeans

marginsplot, ///
    recast(bar) recastci(rcap) ///
    ciopt(lcolor(gs8) lwidth(medium)) ///
    yline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    ytitle("dWHO5/dPasEx (Marginal Effect)") ///
    xtitle("") ///
    xlabel(1 `" "Corporate/" "Prof" "' ///
           2 `" "Public/" "Essential" "' ///
           3 `" "Commerce/" "Hosp" "' ///
           4 `" "Labor/Ag/" "Informal" "', noticks) ///
    title("Marginal Effect of PasExp on WHO5 by Industry Group (M3)", size(medium)) ///
    note("Red dashed line = zero (null effect)" ///
         "At group means of PasExp, SubStat, PsySca | 95% CI shown") ///
    name(g_ind_pas, replace)
graph export "ME_industry_PasEx.png", name(g_ind_pas) replace width(1200)

* ME SubStat by Industry Group
margins, dydx(SubStat) over(WrkIndy_grp) atmeans

marginsplot, ///
    recast(bar) recastci(rcap) ///
    ciopt(lcolor(gs8) lwidth(medium)) ///
    yline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    ytitle("dWHO5/dSubStat (Marginal Effect)") ///
    xtitle("") ///
    xlabel(1 `" "Corporate/" "Prof" "' ///
           2 `" "Public/" "Essential" "' ///
           3 `" "Commerce/" "Hosp" "' ///
           4 `" "Labor/Ag/" "Informal" "', noticks) ///
    title("Marginal Effect of SubStat on WHO5 by Industry Group (M3)", size(medium)) ///
    note("Red dashed line = zero (null effect)" ///
         "At group means of PasExp, SubStat, PsySca | 95% CI shown") ///
    name(g_ind_sub, replace)
graph export "ME_industry_SubStat.png", name(g_ind_sub) replace width(1200)

* ME PsySca by Industry Group
margins, dydx(PsySca) over(WrkIndy_grp) atmeans

marginsplot, ///
    recast(bar) recastci(rcap) ///
    ciopt(lcolor(gs8) lwidth(medium)) ///
    yline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    ytitle("dWHO5/dPsySca (Marginal Effect)") ///
    xtitle("") ///
    xlabel(1 `" "Corporate/" "Prof" "' ///
           2 `" "Public/" "Essential" "' ///
           3 `" "Commerce/" "Hosp" "' ///
           4 `" "Labor/Ag/" "Informal" "', noticks) ///
    title("Marginal Effect of PsySca on WHO5 by Industry Group (M3)", size(medium)) ///
    note("Red dashed line = zero (null effect)" ///
         "At group means of PasExp, SubStat, PsySca | 95% CI shown") ///
    name(g_ind_psy, replace)
graph export "ME_industry_PsySca.png", name(g_ind_psy) replace width(1200)

* Interaction Surface by Industry Group
table WrkIndy_grp, stat(mean PasExp SubStat PsySca WHO5) nformat(%6.3f)

* Interaction surface: ME of PasExp across full SubStat range, split by industry
margins, dydx(PasExp) at(SubStat=(1 2 3 4 5 6 7 8 9 10)) over(WrkIndy_grp) atmeans

marginsplot, ///
    x(SubStat) ///
    by(WrkIndy_grp) ///
    yline(0, lcolor(red) lpattern(dash) lwidth(medium)) ///
    ytitle("dWHO5/dPasEx") xtitle("MacArthur Ladder (SubStat)") ///
    title("ME of PasExp on WHO5 by SubStat Level — by Industry Group", ///
          size(small)) ///  
    note("Red dashed line = zero | Each panel = one industry group" ///
         "95% CI bands shown | Restricted N (WrkIndy_grp 1–4)", ///
          size(vsmall)) ///  
    xsize(16) ysize(8) ///  
    name(g_ind_interact, replace)

graph export "ME_industry_PasEx_by_SubStat.png", ///
    name(g_ind_interact) replace width(4800)

* Combined 3-panel
graph combine g_ind_pas g_ind_sub g_ind_psy, ///
    cols(3) ///
    imargin(zero) ///  
    title("Marginal Effects by Industry Group (M3, Restricted Sample)", ///
          size(small)) ///  
    note("WrkIndy_grp 1–4 only | At group means | 95% CI | vce(robust)", ///
          size(vsmall)) ///  
    xsize(20) ysize(8) //  

graph export "ME_industry_combined3_revised.png", replace width(3600)

restore

* Computing Standardized Betas * Elasticities on M3
qui sum WHO5
local sd_y  = r(sd)
local u_bar = r(mean)

qui regress WHO5 c.PasExp##c.SubStat PsySca, vce(robust)

qui sum PasExp
local pas_bar = r(mean)
local pas_sd  = r(sd)

qui sum SubStat
local lad_bar = r(mean)
local lad_sd  = r(sd)

qui sum PsySca
local cw_bar  = r(mean)
local cw_sd   = r(sd)

* Computing MEM
lincom PasExp + `lad_bar' * c.PasExp#c.SubStat
local mem_pas = r(estimate)

lincom SubStat + `pas_bar' * c.PasExp#c.SubStat
local mem_lad = r(estimate)

local mem_cw  = _b[PsySca]

* Final Results for MEM, x-bar, Elasticities, Standardized Betas 
di ""
di "Variable      MEM        x-bar    Elasticity  Std.Beta(MEM)"
di "──────────────────────────────────────────────────────────"
di "PasExp       " %7.3f `mem_pas' "  " %5.3f `pas_bar' "  " %8.4f (`mem_pas'*`pas_bar'/`u_bar') "  " %8.4f (`mem_pas'*`pas_sd'/`sd_y')
di "SubStat     " %7.3f `mem_lad' "  " %5.3f `lad_bar' "  " %8.4f (`mem_lad'*`lad_bar'/`u_bar') "  " %8.4f (`mem_lad'*`lad_sd'/`sd_y')
di "PsySca      " %7.3f `mem_cw'  "  " %5.3f `cw_bar'  "  " %8.4f (`mem_cw'*`cw_bar'/`u_bar')   "  " %8.4f (`mem_cw'*`cw_sd'/`sd_y')

* Bootstrap CI (seeds 42 and 1,000 reps on M3)
set seed 42
di _newline "--- Bootstrap M3 ---"
bootstrap _b, reps(1000) nodots: ///
    regress WHO5 c.PasExp##c.SubStat PsySca
estat bootstrap, all

* Bootstrap CI (seeds 42 and 1,000 reps on M1)
set seed 42
di _newline "--- Bootstrap M1 ---"
bootstrap _b, reps(1000) nodots: ///
    regress WHO5 PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other
estat bootstrap, all

* Cochran C and Heteroskedasticity Testing
di _newline "--- WHO5 variance by Gender ---"
oneway WHO5 d_female, tabulate
robvar WHO5, by(d_female)
qui sum WHO5 if d_female == 0
scalar v_m = r(Var)
qui sum WHO5 if d_female == 1
scalar v_f = r(Var)
scalar C_gender = max(v_m, v_f) / (v_m + v_f)
di "  Cochran C (Gender, k=2): C = " %6.4f C_gender

di _newline "--- WHO5 variance by Age Group ---"
gen byte age_3cat = .
replace age_3cat = 1 if age_raw == "18 — 24 ปี"
replace age_3cat = 2 if age_raw == "25 — 34 ปี"
replace age_3cat = 3 if age_raw == "35 — 44 ปี"
label define lage3 1 "18-24" 2 "25-34" 3 "35-44"
label values age_3cat lage3

oneway WHO5 age_3cat, tabulate
robvar WHO5, by(age_3cat)

scalar sv_a = 0
scalar mx_a = 0
forval g = 1/3 {
    qui sum WHO5 if age_3cat == `g'
    di "  Age group `g': n=" r(N) ", s2=" %7.2f r(Var)
    scalar sv_a = sv_a + r(Var)
    if r(Var) > mx_a scalar mx_a = r(Var)
}
di "  Cochran C (Age, k=3): C = " %6.4f mx_a/sv_a " | critical ~0.727"

di _newline "--- Breusch-Pagan and White on M1 residuals ---"
qui regress WHO5 PasExp PsySca CFPB_liquid SubStat HHInc SOC_HRS ///
    d_female d_gnd_nd d_age25_34 d_age35_44 ///
    d_live_alone d_live_shared d_live_other, vce(robust)
estat hettest
estat imtest, white

di _newline "--- Cochran C summary ---"
di "  Gender (k=2): C = " %6.4f C_gender   " | critical ~0.975"
di "  Age    (k=3): C = " %6.4f mx_a/sv_a  " | critical ~0.727"

* ======================================================
* Profiling High Status (6-10) VS Low Status (1-5) Groups

* Creating binary variable
gen high_status = (SubStat >= 6) if !missing(SubStat)
label define status_lbl 0 "Low Status (1-5)" 1 "High Status (6-10)"
label values high_status status_lbl

tabulate WrkIndy_grp high_status, row column

tabulate HHInc high_status, row column

tabstat PsySca, by(high_status) stat(mean sd N) format(%6.2f)

tabstat OSSS3, by(high_status) stat(mean sd N) format(%6.2f)

tabstat PasExp SubStat, by(WrkIndy_grp) stat(mean sd N) format(%6.2f)

tabstat PasExp SubStat, by(HHInc) stat(mean sd N) format(%6.2f)

* Ploting Industry Group into Interaction Surface
twoway (scatter SubStat PasExp if WrkIndy_grp == 1, mcolor(navy) msymbol(O)) ///
       (scatter SubStat PasExp if WrkIndy_grp == 2, mcolor(forest_green) msymbol(D)) ///
       (scatter SubStat PasExp if WrkIndy_grp == 3, mcolor(cranberry) msymbol(T)) ///
       (scatter SubStat PasExp if WrkIndy_grp == 4, mcolor(gs10) msymbol(X)), ///
       ytitle("Subjective Status (1-10)") xtitle("Passive Exposure (Frequency)") ///
       legend(order(1 "Public/Essential" 2 "Commerce/Hosp" 3 "Labor/Ag/Informal" 4 "Unclassified") row(2)) ///
       title("Demographic Distribution Across the Interaction Space")
* ======================================================

save "group03_WellBeing.dta", replace
log close
