cd "C:\Users\twter\Google Drive\Graduate\2019 도덕적해이\code\0702\data"

local ind_files : dir . files "*IND*"
local cd_files : dir . files "*CD*"
local ou_files : dir . files "*OU*"
local in_files : dir . files "*IN.DTA"
local er_files : dir . files "*ER*"
local phi_files : dir . files "*PHI*"
local phr_files : dir . files "*PHR*"
local hh_files : dir . files "*HH*"
local ap_files : dir . files "*APPEN*"

****************************************************************************
**** 개인 특성
foreach file in `ind_files' {

use `file', clear
keep hhidwon m1 m2 hhid pid pidwon hpid c3 c4_0 c7 c8 c9 c11 c13_1 c24 c42 c43 c44 c45 c28 i_medicalexp1 i_medicalexp2

* sex dummy
replace c3=0 if c3==1
replace c3=1 if c3==2
rename c3 sex
label variable sex "0=M 1=F"

* age dummy (1950~1990)
gen age1=0
gen age2=0
gen age3=0
gen age4=0
gen age5=0
replace age1=1 if c4_0>1990 | c4_0<1950
replace age2=1 if inrange(c4_0, 1986, 1990)
replace age3=1 if inrange(c4_0, 1976, 1985)
replace age4=1 if inrange(c4_0, 1966, 1975)
replace age5=1 if inrange(c4_0, 1950, 1965)
label variable age1 "under 20, over 65"
label variable age2 "20-29"
label variable age3 "30-39"
label variable age4 "40-49"
label variable age5 "50-65"
gen age = 0
replace age=1 if age1==1
replace age=2 if age2==1
replace age=3 if age3==1
replace age=4 if age4==1
replace age=5 if age5==1
label variable age "1~20+65~ 2-20 3-30 4-40 5-50"
drop age1 age2 age3 age4 age5

gen real_age = 2020-c4_0
gen real_age2 = real_age^2
drop c4_0

*education dummy
gen edu0=0
gen edu1=0
gen edu2=0
gen edu3=0
gen edu4=0
gen edu5=0
replace edu5=1 if inrange(c8,51,52) & c9==1
replace edu4=1 if inrange(c8,51,52) & c9!=1
replace edu4=1 if inrange(c8,41,46) & c9==1
replace edu3=1 if inrange(c8,41,46) & c9!=1
replace edu3=1 if inrange(c8,31,33) & c9==1
replace edu2=1 if inrange(c8,31,33) & c9!=1
replace edu2=1 if inrange(c8,21,23) & c9==1
replace edu1=1 if inrange(c8,21,23) & c9!=1
replace edu1=1 if inrange(c8,11,16) & c9==1
//replace edu0=0 if inrange(c8,11,16) & c9!=1
replace edu0=1 if inrange(c8,11,16) & c9!=1
replace edu0=1 if inrange(c8,1,3)
label variable edu0 "무학"
label variable edu1 "초졸"
label variable edu2 "중졸"
label variable edu3 "고졸"
label variable edu4 "대졸"
label variable edu5 "대학원졸"
gen edu = 0
replace edu=1 if edu1==1
replace edu=2 if edu2==1
replace edu=3 if edu3==1
replace edu=4 if edu4==1
replace edu=5 if edu5==1
label variable edu "0무 1초졸 2중졸 3고졸 4대졸 5원졸"
drop edu0 edu1 edu2 edu3 edu4 edu5
drop c8 c9

* marriage dummy
replace c7=0 if c7!=1
rename c7 marriage
label variable marriage "0=N 1=Y"

* econ dummy
replace c24=0 if c24!=1
rename c24 econ
label variable econ "0=N 1=Y"

* disability dummy //수정
gen disability=1 if c13_1==1
replace disability=0 if c13_1==2| c13_1==3|c13_1==4
label variable disability "0=N 1=Y"

* 의료이용여부
gen med_use = 0
replace med_use = 1 if c42==1|c43==1|c44==1|c45==1

* 임신
gen preg = 0
replace preg = 1 if c45==1

drop c42 c43 c44 c45

*의료급여
gen benefit=1 if c11==4|c11==5|c11==6|c11==7|c11==10|c11==8|c11==9
replace benefit=0 if benefit==.

* 직종
gen job = 0
replace job=10 if c28==1 //군인
tostring(job), replace
tostring(c28), replace 
replace job = substr(c28, 1, 1)
replace job="0" if job=="-" 
destring(job), replace

save "clean/`file'", replace
}
****************************************************************************
**** 개인 만성질환 여부
foreach file in `cd_files' {
use `file', clear

drop if cd2==2 | cd2==4
gen cd_count = 1
collapse (sum) cd_count, by(pidwon)

save "clean/`file'", replace
}
****************************************************************************
**** 개인별 외래진료 이용 횟수 및 비용
foreach file in `ou_files' {
use `file', clear

merge 1:1 _n using 4disease_row.dta, nogen
forval i=1/668{
replace var`i'=var`i'[1]
}
gen dis4_1o = 0 //희귀난치
gen dis4_2o = 0 //암
gen dis4_3o = 0 //뇌혈관
gen dis4_4o = 0 //심장

forval n=1/478{
replace dis4_1o = 1 if ou3_2==var`n'|ou4_2==var`n'|ou5_5==var`n'|ou5_8==var`n'
}
forval n=479/600{
replace dis4_2o = 1 if ou3_2==var`n'|ou4_2==var`n'|ou5_5==var`n'|ou5_8==var`n'
}
forval n=601/615{
replace dis4_3o = 1 if ou3_2==var`n'|ou4_2==var`n'|ou5_5==var`n'|ou5_8==var`n'
}
forval n=616/668{
replace dis4_4o = 1 if ou3_2==var`n'|ou4_2==var`n'|ou5_5==var`n'|ou5_8==var`n'
}

keep hhidwon m1 m2 hhid pid pidwon oucount ou29_4 ou29_5 ou29_6 ou29_7 dis4_1o dis4_2o dis4_3o dis4_4o

replace ou29_4=0 if ou29_4==-1 //건보
replace ou29_5=0 if ou29_5==-1 //본인부담
replace ou29_6=0 if ou29_6==-1 //비급여
replace ou29_7=0 if ou29_7==-1 //총진료비

drop if ou29_4==-9|ou29_5==-9|ou29_6==-9|ou29_7==-9
drop if ou29_4<0 // 건보 금액이 마이너스인 경우. 보사연에서도 알고 있는 부분이나 연구자는 이유 모름.
drop if ou29_6<0 // 비급여 금액이 마이너스인 경우. 보사연에서도 알고 있는 부분이나 연구자는 이유 모름.

replace ou29_7=ou29_4+ou29_5+ou29_6

egen ou_tot = rowtotal(ou29_5 ou29_6), missing //out-of-pocket
egen ou_count = count(pidwon) if ou29_7>0, by(pidwon)

collapse ou_count (sum) ou_tot ou29_6 ou29_7 dis4_1o dis4_2o dis4_3o dis4_4o, by(pidwon)
drop if ou29_7 ==0

rename ou_count oucount
label variable oucount "왜래 이용 횟수"
label variable ou_tot "외래 본+비"

save "clean/`file'", replace
}
****************************************************************************
**** 개인별 내원치료 이용 횟수 및 비용
foreach file in `in_files' {
use `file', clear

merge 1:1 _n using 4disease_row.dta, nogen
forval i=1/668{
replace var`i'=var`i'[1]
}
gen dis4_1i = 0 //희귀난치
gen dis4_2i = 0 //암
gen dis4_3i = 0 //뇌혈관
gen dis4_4i = 0 //심장

forval n=1/478{
replace dis4_1i = 1 if in25_2==var`n'|in26_2==var`n'|in27_2==var`n'
}
forval n=479/600{
replace dis4_2i = 1 if in25_2==var`n'|in26_2==var`n'|in27_2==var`n'
}
forval n=601/615{
replace dis4_3i = 1 if in25_2==var`n'|in26_2==var`n'|in27_2==var`n'
}
forval n=616/668{
replace dis4_4i = 1 if in25_2==var`n'|in26_2==var`n'|in27_2==var`n'
}

keep hhidwon m1 m2 hhid pid pidwon hpid in9 in8 in35_3 in35_4 in35_5 in35_6 in31 in33 in34 dis4_1i dis4_2i dis4_3i dis4_4i

label variable in9 "입원일수"

* 입원중인 경우 제외
drop if in9==-1
drop if in8==55
drop in8

gen room_s = 0
replace room_s = 1 if in31==1|in33==1|in34==1
gen room_1 = 0
replace room_1 = 1 if in31==2|in33==2|in34==2
gen room_2 = 0
replace room_2 = 1 if in31==3|in33==3|in34==3
drop in31 in33 in34

replace in35_3=0 if in35_3==-1 //건보
replace in35_4=0 if in35_4==-1 //본인부담
replace in35_5=0 if in35_5==-1 //비급여
replace in35_6=0 if in35_6==-1 //총진료비

drop if in35_3==-9|in35_4==-9|in35_5==-9|in35_6==-9
drop if in35_3<0 // 건보 금액이 마이너스인 경우. 보사연에서도 알고 있는 부분이나 연구자는 이유 모름.
drop if in35_5<0 // 비급여 금액이 마이너스인 경우. 보사연에서도 알고 있는 부분이나 연구자는 이유 모름.

replace in35_6=in35_3+in35_4+in35_5

egen in_tot = rowtotal(in35_4 in35_5), missing

collapse (sum) in9 in_tot in35_5 in35_6 room_s room_1 room_2 dis4_1i dis4_2i dis4_3i dis4_4i, by (pidwon)
replace room_s = 1 if room_s>=1
replace room_1 = 1 if room_1>=1
replace room_2 = 1 if room_2>=1
gen room = 0
replace room = 1 if room_s!=0|room_1!=0|room_2!=0
gen room_special = 0
replace room_special = 1 if room_s!=0|room_1!=0

drop if in35_6==0

label variable in9 "입원일수"
label variable in_tot "입원 본+비"

save "clean/`file'", replace
}
****************************************************************************
**** 개인별 응급치료 이용 횟수 및 비용
foreach file in `er_files' {
use `file', clear

merge 1:1 _n using 4disease_row.dta, nogen
forval i=1/668{
replace var`i'=var`i'[1]
}
gen dis4_1e = 0 //희귀난치
gen dis4_2e = 0 //암
gen dis4_3e = 0 //뇌혈관
gen dis4_4e = 0 //심장

forval n=1/478{
replace dis4_1e = 1 if er22_2==var`n'|er23_2==var`n'|er24_2==var`n'
}
forval n=479/600{
replace dis4_2e = 1 if er22_2==var`n'|er23_2==var`n'|er24_2==var`n'
}
forval n=601/615{
replace dis4_3e = 1 if er22_2==var`n'|er23_2==var`n'|er24_2==var`n'
}
forval n=616/668{
replace dis4_4e = 1 if er22_2==var`n'|er23_2==var`n'|er24_2==var`n'
}

keep hhidwon m1 m2 hhid pid pidwon hpid er26_2 er26_3 er26_4 er26_5 dis4_1e dis4_2e dis4_3e dis4_4e

replace er26_2=0 if er26_2==-1 //건보
replace er26_3=0 if er26_3==-1 //본인부담
replace er26_4=0 if er26_4==-1 //비급여
replace er26_5=0 if er26_5==-1 //총진료비

drop if er26_2==-9|er26_3==-9|er26_4==-9|er26_5==-9
drop if er26_2<0 // 건보 금액이 마이너스인 경우. 보사연에서도 알고 있는 부분이나 연구자는 이유 모름.
drop if er26_4<0 // 비급여 금액이 마이너스인 경우. 보사연에서도 알고 있는 부분이나 연구자는 이유 모름.

replace er26_5=er26_2+er26_3+er26_4

egen er_tot = rowtotal(er26_3 er26_4), missing
drop if er26_5==0

collapse (sum) er_tot er26_4 er26_5 dis4_1e dis4_2e dis4_3e dis4_4e, by (pidwon)
label variable er_tot "응급 본+비"

save "clean/`file'", replace
}
****************************************************************************
**** HH INCOME
foreach file in `hh_files' {
use `file', clear

keep hhidwon m1 m2 hhid b1 total tot_h h_medicalexp1 p 

* income by no. of members
gen total_pp = total/b1
label variable total_pp "인당 가구소득"

gen tot_h_pp = tot_h/b1
label variable tot_h_pp "인당 근로소득"

rename p region

save "clean/`file'", replace
}
****************************************************************************
**** 개인 민간보험 가입 여부 및 납입료
foreach file in `phi_files' {
use `file', clear

keep hhidwon m1 m2 hhid pid pidwon hpid e0 e1_3 e3_1 e4 e6_0 e6 e7
duplicates drop

* 2012 이전 가입 제외, 중도 해약 제외
* 의료를 더 받기 위해 최근 보험을 가입하는 경우를 조사
drop if e3_1<2012
drop if e1_3==3 | e1_3==4

* 실손, 정액, 혼합형 보험 구분
gen ins1=0
gen ins2=0
gen ins3=0
replace ins1=1 if e4==2
replace ins2=1 if e4==1
replace ins3=1 if e4==3
label variable ins1 "실손"
label variable ins2 "정액"
label variable ins3 "혼합" //실손+정액

* 실손 보험 납입료
gen s1 = e6 if e6!=-1&e6!=-9&ins1>=1&ins2==0&ins3==0
gen s2 = e7 if e7!=-1&e7!=-9&ins1>=1&ins2==0&ins3==0
egen s_pay =rowtotal(s1 s2), missing
replace s_pay = s_pay*12

* 개인별로 합치기
collapse (sum) s_pay ins1 ins2 ins3, by (pidwon)
label variable ins1 "실손"
label variable ins2 "정액"
label variable ins3 "혼합"

save "clean/`file'", replace
}
****************************************************************************
**** 주관적 건강상태
foreach file in `ap_files' {
use `file', clear

keep hhidwon m1 m2 hhid pid pidwon hpid sj7

label variable sj7 "건강상태(1좋음 5나쁨)"

* 해당사항 없음/무응답은 missing 처리(수정)
replace sj7=. if sj7<0

save "clean/`file'", replace
}
****************************************************************************
*** 보험금
foreach file in `phr_files' {
use `file', clear
keep hhidwon m1 m2 hhid pid pidwon hpid f3 f4 f6_1 f7_1 f8_1 f8_2 f8_3 f9

* 주된 수령사유(1)/(2)가 실손인 경우만 남김
keep if f6_1==8|f6_1==9|f6_1==10|f7_1==8|f7_1==9|f7_1==10
drop if f9<0

sort pidwon f4
by pidwon f4 : gen in_phr = f9 if f3==1
by pidwon f4 : gen ou_phr = f9 if f3==2

collapse (sum) f9 in_phr ou_phr, by (pidwon f4)
rename f9 tot_phr
rename f4 year
label variable in_phr "입원 실손 급여"
label variable ou_phr "외래 실손 급여"
label variable tot_phr "총 실손 급여"

save "clean/`file'", replace
}
****************************************************************************
* MERGE YEARLY
append using "clean/T12PHR.DTA"
append using "clean/T13PHR.DTA"
append using "clean/T14PHR.DTA"
append using "clean/T15PHR.DTA"
replace year=2012 if year==12
replace year=2013 if year==13
replace year=2014 if year==14
sort pidwon year
collapse (sum) tot_phr in_phr ou_phr, by (pidwon year)
sort pidwon year
save "clean/FULL_PHR.DTA", replace
****************************************************************************
****************************************************************************
* MERGE CLEAN DATA
cd "C:\Users\twter\Google Drive\Graduate\2019 도덕적해이\code\0702\data\clean"
foreach i in 12 13 14 15 16 {

use T`i'IND.DTA, clear
gen year = 20`i'
label variable year "연도"

* merge 주관적 건강
merge 1:1 pidwon using T`i'APPEN.DTA
drop _merge
* merge chronic
merge 1:1 pidwon using T`i'CD.DTA
drop if _merge==2
drop _merge
* merge phi
merge 1:1 pidwon using T`i'PHI.DTA
drop if _merge==2
drop _merge
* merge ou
merge 1:1 pidwon using T`i'OU.DTA
drop _merge
* merge in
merge 1:1 pidwon using T`i'IN.DTA
drop _merge
* merge er
merge 1:1 pidwon using T`i'ER.DTA
drop _merge
* merge hh income
merge m:1 hhidwon m1 m2 hhid using T`i'HH.DTA, nogenerate
* save
save `i'FINAL.DTA, replace
}
*****************************************************************************
* COMPOSE PANEL
use 12FINAL.DTA, clear
foreach i in 13 14 15 16 {
append using `i'FINAL.DTA
}

sort year pidwon
merge 1:1 pidwon year using FULL_PHR.DTA
drop if _merge==2
drop _merge
order year
sort pidwon year

gen dis4_1 = 0
gen dis4_2 = 0
gen dis4_3 = 0
gen dis4_4 = 0
replace dis4_1o=0 if dis4_1o==.
replace dis4_1i=0 if dis4_1i==.
replace dis4_1e=0 if dis4_1e==.
replace dis4_2o=0 if dis4_2o==.
replace dis4_2i=0 if dis4_2i==.
replace dis4_2e=0 if dis4_2e==.
replace dis4_3o=0 if dis4_3o==.
replace dis4_3i=0 if dis4_3i==.
replace dis4_3e=0 if dis4_3e==.
replace dis4_4o=0 if dis4_4o==.
replace dis4_4i=0 if dis4_4i==.
replace dis4_4e=0 if dis4_4e==.
replace dis4_1=1 if dis4_1o>0|dis4_1i>0|dis4_1e>0
replace dis4_2=1 if dis4_2o>0|dis4_2i>0|dis4_2e>0
replace dis4_3=1 if dis4_3o>0|dis4_3i>0|dis4_3e>0
replace dis4_4=1 if dis4_4o>0|dis4_4i>0|dis4_4e>0
gen dis4=0
replace dis4=dis4_1+dis4_2+dis4_3+dis4_4

save FULL.DTA, replace
*****************************************************************************
use FULL.DTA, clear

replace cd_count=0 if cd_count==.
drop if sj7==.
drop if benefit==1
keep if ins1>=1
drop if med_use!=1
drop if ou_tot==.&in_tot==.&er_tot==.

gen m_i = -in_phr //급여 받은 부분
gen m_o = -ou_phr
gen m_t = -tot_phr

format hpid %20.0g

gen cat_cd = 0
replace cat_cd = 1 if cd_count==1
replace cat_cd = 2 if cd_count==2
replace cat_cd = 3 if cd_count>=3

gen l_spay = log(s_pay+1)

save FINAL.DTA, replace
****************************************************************************
use FINAL.DTA, clear

* [_y] 건보 포함 총 의료 지출
egen _y = rowtotal(ou29_7 in35_6 er26_5), missing

* [_y2] 건보X 총 의료 지출 (실제)
egen _y2 = rowtotal(ou_tot in_tot er_tot), missing

* [_x] OOP : 비급여 + 본인부담금 - 민간의료보험 급여
egen _x = rowtotal(ou_tot in_tot er_tot m_t), missing 
replace _x = 0 if _x<0

****************************************************************************
* COINSURANCE RATE

gen rate = _x / _y2
replace rate=rate*100

gen receipt=1 if tot_phr>0 & tot_phr!=.

su rate if age!=1&ins1>=1&ins2==0&ins3==0&receipt==1, de
su m_t if age!=1&ins1>=1&ins2==0&ins3==0&receipt==1, de
su _y2 if age!=1&ins1>=1&ins2==0&ins3==0&receipt==1, de
****************************************************************************
* ELASTICITY

gen l_y = log(_y)
gen l_rate = log(rate+1)
gen l_total = log(total)
gen l_tot_pp = log(total_pp)

save temp, replace
*****************************************************************************
** 실손 보험만 가지고 있는 사람 추출하기 	: ins1>=1&ins2==0&ins3==0
** 19세 미만, 65세 미만 제외하기 	: age!=1
*****************************************************************************
use temp, clear

xtset pidwon year
sort pidwon year

xtgee l_y l_rate l_tot_pp l_spay sex marriage econ disability preg i.cat_cd i.dis4 i.region i.edu i.age i.sj7 ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtreg l_y l_rate l_tot_pp l_spay sex marriage econ disability preg i.cat_cd i.dis4 i.region i.edu i.age i.sj7 ///
if age!=1&ins1>=1&ins2==0&ins3==0, fe

*****************************************************************************
* RIDGE ONE HOT
tab cat_cd, gen(cat)
tab region, gen(reg)
tab edu, gen(edu)
tab age, gen(age)
tab sj, gen(sj)
tab dis4, gen(dis_num)
ridgereg l_y l_rate l_tot_pp l_spay sex marriage econ disability preg cat2 cat3 cat4 dis_num2 dis_num3 ///
edu2 edu3 edu4 edu5 edu6 age3 age4 age5 sj2 sj3 sj4 sj5 if age!=1&ins1>=1&ins2==0&ins3==0, model(orr)

*****************************************************************************
* 상급병실 t-test
/*
keep if age!=1&ins1>=1&ins2==0&ins3==0

ttest s_pay, by(room)
ttest rate, by(room)
ttest total_pp, by(room)

ttest s_pay, by(room_1)
ttest rate, by(room_1)
ttest total_pp, by(room_1)

ttest s_pay, by(room_special)
ttest rate, by(room_special)
ttest total_pp, by(room_special)
*/
*****************************************************************************
*****************************************************************************
* EXPORT
/*
keep if age!=1&ins1>=1&ins2==0&ins3==0

****summary statistics
eststo clear
estpost su s_pay
eststo sum
esttab using 00_summary.csv, ///
cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2)) min(fmt(2)) max(fmt(2))") ///
sfmt(%20.2f) nomtitle nonumber replace 

* regression
eststo clear
xtgee l_y l_rate l_tot_pp l_spay sex marriage econ disability preg i.cat_cd i.dis4 i.region i.edu i.age i.sj7 ///
if age!=1&ins1>=1&ins2==0&ins3==0
eststo m1
xml_tab *, stats(N r2) star(* 0.1 ** 0.05 *** 0.01) ///
save(01_gee.xml) sheet(Table1) ///
replace below nolabel 

eststo clear
ridgereg l_y l_rate l_tot_pp l_spay sex marriage econ disability preg cat2 cat3 cat4 dis_num2 dis_num3 edu2 edu3 edu4 edu5 edu6 age3 age4 age5 sj2 sj3 sj4 sj5 if age!=1&ins1>=1&ins2==0&ins3==0, model(orr)
eststo m1
xml_tab *, star(* 0.1 ** 0.05 *** 0.01) ///
save(02_ridge.xml) sheet(Table1) ///
replace below nolabel 


*****************************************************************************
/* past
gen ind_ou = ou_tot / oucount
gen ind_in = in_tot / in9
gen l_ou = log(ind_ou)
gen l_in = log(ind_in)

xtgee oucount l_ou l_tot_pp sex marriage econ chronic disability preg i.edu i.region real_age real_age2 i.sj /// 
if age!=1&ins1>=1&ins2==0&ins3==0, family(nb) link(log) //rate x/y coinsurance rate (소득, 가격 탄력성 같이)

xtgee in9 l_in l_tot_pp sex marriage i.job econ chronic disability preg i.edu i.region real_age real_age2 i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0, family(nb) link(log) //rate x/y coinsurance rate (소득, 가격 탄력성 같이)
xtgee l_y l_rate l_tot_pp sex marriage econ chronic disability preg i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtgee l_y l_rate l_tot_pp sex marriage econ chronic disability preg i.job i.region i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtgee l_y l_rate l_tot_pp sex marriage econ i.cat_cd disability preg i.job i.region i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtgee l_y l_rate l_tot_pp sex marriage econ disability preg i.cat_cd i.job i.region i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtgee l_y l_rate l_tot_pp sex marriage econ disability preg i.cat_cd i.region i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtgee l_y l_rate l_tot_pp s_pay sex marriage econ disability preg i.cat_cd i.region i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtgee l_y l_rate l_tot_pp i.dis4 sex marriage econ disability preg i.cat_cd i.region i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0

xtreg l_y l_rate l_tot_pp sex marriage econ disability preg i.cat_cd i.region i.edu i.age i.sj ///
if age!=1&ins1>=1&ins2==0&ins3==0, fe

gen cat_region = 0
replace cat_region = 1 if region==36|region==41|region==42|region==43|region==44|region==45|region==46|region==47|region==48|region==50
