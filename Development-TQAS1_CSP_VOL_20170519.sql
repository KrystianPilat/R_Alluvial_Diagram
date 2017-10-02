--STEP 0 IMOPORT DATA FOR NON MATCH IN PMC

select count(sec_id) from CSP_VOL_PMC_ALL_NO_MATCH;
select * from CSP_PMC_ALL_NO_MATCH;
select * from trqa.fisecmstrx ms;
select * from trqa.fiejvprcdly p;
select * from trqa.fisecmapx mp;


select csp.cusip, p.marketdate, p.close_
from trqa.ds2primqtprc p
join trqa.ds2cusipchg csp on csp.infocode = p.infocode and startdate = (select max(startdate) from trqa.ds2cusipchg where infocode=csp.infocode)
where csp.cusip='65158L65';-- and p.marketdate between '01-JAN-17' AND '10-JAN-17';



/*BONDS
join trqa.fisecmstrx ms on SUBSTR(no_sec.sec_id,1,8) = ms.cusip
join trqa.fisecmapx mp on mp.type_= ms.type_ and mp.seccode = ms.seccode and mp.ventype=45 and ms.type_=21
join trqa.fiejvprcdly p on p.instrcode = mp.vencode

SEC
join trqa.ds2cusipchg csp on csp.cusip = SUBSTR(pmc.sec_id,1,8)
join trqa.ds2primqtprc p on csp.infocode = p.infocode
join trqa.Ds2CtryQtInfo inf on p.infocode = inf.infocode
*/

select SUBSTR(sec_id,1,8) from CSP_PMC_ALL_NO_MATCH;

/*--REJECTED
STEP 0.1
--CREATE TABLE
CREATE TABLE S1_CSP_PMC_BOND
(
  SEC_ID VARCHAR2(50 BYTE) 
, ROVER_DATE DATE 
, ROVER_VALUE FLOAT
, ISIN VARCHAR2(50 BYTE)
, SEDOL VARCHAR2(50 BYTE)
, CUSIP VARCHAR2(50 BYTE)
, NAME VARCHAR2(50 BYTE)
, TRADEDATE DATE
, PRC VARCHAR2(50 BYTE)
, PRICE_COV VARCHAR2(80 BYTE)
);

drop table S1_CSP_PMC_BOND;
--STEP 1
--EJV is the source of our bond data
--Query by cusip
INSERT INTO S1_CSP_PMC_BOND(SEC_ID,ROVER_DATE,ROVER_VALUE,ISIN,SEDOL,CUSIP,NAME,TRADEDATE,PRC,PRICE_COV)
SELECT
SEC_ID,
ROVER_DATE,
ROVER_VALUE,
ms.isin, 
ms.sedol, 
ms.cusip,
ms.name,
p.tradedate, 
p.prc,
case
when pmc.ROVER_DATE = p.tradedate AND ROUND(p.prc,2) = ROUND(pmc.ROVER_VALUE,2) then 'SAME_PRICE_AVAILABLE'
else 'SAME_DATE_AVAILABLE'
end as PRICE_COV
from CSP_PMC_ALL_NO_MATCH pmc
join trqa.fisecmstrx ms on SUBSTR(pmc.sec_id,1,8) = ms.cusip
join trqa.fisecmapx mp on mp.type_= ms.type_ and mp.seccode = ms.seccode and mp.ventype=45 and ms.type_=21
join trqa.fiejvprcdly p on p.instrcode = mp.vencode
where pmc.ROVER_DATE = p.tradedate
and sec_id ='035710508';

--TEST
select *
from CSP_PMC_ALL_NO_MATCH pmc
join trqa.fisecmstrx ms on SUBSTR(pmc.sec_id,1,8) = ms.cusip
join trqa.fisecmapx mp on mp.type_= ms.type_ and mp.seccode = ms.seccode and mp.ventype=45 and ms.type_=21
join trqa.fiejvprcdly p on p.instrcode = mp.vencode
where sec_id ='035710508'
and p.tradedate between '01-JAN-12' AND '01-DEC-12';
--and p.tradedate = pmc.rover_date;

select *
from CSP_PMC_ALL_NO_MATCH pmc
where sec_id ='035710508';


select * from S1_CSP_PMC_BOND;
*/
DROP TABLE S2_CSP_VOL_PMC_SEC;
--STEP 0.2
--CREATE TABLE
DROP TABLE S2_CSP_VOL_PMC_SEC;
CREATE TABLE S2_CSP_VOL_PMC_SEC
(
  SEC_ID VARCHAR2(50 BYTE) 
, ROVER_DATE DATE
, marketdate DATE
, CUSIP VARCHAR2(50 BYTE)
, DSQTNAME VARCHAR2(80 BYTE)
, REGION VARCHAR2(50 BYTE)
, TYPECODE VARCHAR2(50 BYTE)
, PRIMISOCURRCODE VARCHAR2(50 BYTE)
, ROVER_VALUE FLOAT
, volume FLOAT
, PRICE_COV VARCHAR2(80 BYTE)
);


--STEP 0.2.1
--SECIURITIES
select * from trqa.ds2cusipchg csp;
select * from trqa.ds2primqtprc p;
select * from  trqa.Ds2CtryQtInfo; DSQTNAME, REGION, TYPECODE

select count(sec_id) from CSP_VOL_PMC_ALL_NO_MATCH;
select * from CSP_VOL_PMC_ALL_NO_MATCH;

--STEP 0.2.2
--TEST
Select 
sec_id, rover_date, p.marketdate, csp.cusip cusip, inf.DSQTNAME DSQTNAME, inf.REGION REGION, inf.TYPECODE, inf.PRIMISOCURRCODE, rover_value, p.VOLUME,
case
when ROUND(rover_value,2) = ROUND(p.volume,2)
then 'SAME_PRICE_AVAILABLE'
else 'SAME_DATE_AVAILABLE'
end as PRICE_COV
from CSP_VOL_PMC_ALL_NO_MATCH pmc
join trqa.ds2cusipchg csp on csp.cusip = SUBSTR(pmc.sec_id,1,8)
join trqa.ds2primqtprc p on csp.infocode = p.infocode
join trqa.Ds2CtryQtInfo inf on p.infocode = inf.infocode
where sec_id = '00101J106'
and pmc.rover_date = p.marketdate;

--STEP 2
--ASSIGN VALUES FROM SEC
INSERT INTO S2_CSP_VOL_PMC_SEC(sec_id,rover_date,marketdate,cusip,DSQTNAME,REGION,TYPECODE,PRIMISOCURRCODE,rover_value,volume,PRICE_COV)
Select 
sec_id, rover_date, p.marketdate, csp.cusip cusip, inf.DSQTNAME DSQTNAME, inf.REGION REGION, inf.TYPECODE, inf.PRIMISOCURRCODE, rover_value, p.VOLUME,
case
when ROUND(rover_value,2) = ROUND(p.volume,2)
then 'SAME_PRICE_AVAILABLE'
when rover_date = p.marketdate and volume is not null
then 'SAME_DATE_AVAILABLE'
end as PRICE_COV
from CSP_VOL_PMC_ALL_NO_MATCH pmc
join trqa.ds2cusipchg csp on csp.cusip = SUBSTR(pmc.sec_id,1,8)
join trqa.ds2primqtprc p on csp.infocode = p.infocode
join trqa.Ds2CtryQtInfo inf on p.infocode = inf.infocode
where pmc.rover_date = p.marketdate;

--COUNT
--252828
select count (*) from CSP_VOL_PMC_ALL_NO_MATCH;

--COUNT
select PRICE_COV, count (sec_id) from (
select distinct sec_id,rover_date,PRICE_COV from S2_CSP_VOL_PMC_SEC)
group by PRICE_COV;


--COUNT ALL MATCH
--252569
select count (sec_id) from (
select distinct sec_id,rover_date from S2_CSP_VOL_PMC_SEC);

--COUNT SPECIFIC MATCH
--230580 SAME_PRICE_AVAILABLE
--22865 SAME_DATE_AVAILABLE
select count (sec_id) from (
select distinct sec_id,rover_date from S2_CSP_VOL_PMC_SEC
--where PRICE_COV = 'SAME_PRICE_AVAILABLE');
where PRICE_COV = 'SAME_DATE_AVAILABLE');

--ALL - SAME_PRICE_AVAILABLE = SAME_DATE_AVAILABLE
--252569 - 230580 = 21989

--COUNT SAME_DATE_AVAILABLE = 21973 
SELECT COUNT(sec_id) from
(SELECT distinct sec_id,rover_date --ONLY PRICE_FOR_DATE_AVAILABLE WITHOUT SAME_PRICE_AVAILABLE / PRICE_FOR_DATE_AVAILABLE - SAME_PRICE_AVAILABLE = PRICE_FOR_DATE_AVAILABLE ONLY
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_DATE_AVAILABLE'
MINUS
SELECT distinct sec_id,rover_date
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_PRICE_AVAILABLE');

--COUNT ID INPUT -971
select count (distinct sec_id) from (
select distinct sec_id,rover_date from CSP_VOL_PMC_ALL_NO_MATCH);

--COUNT ID MATCHED
--970
select count (distinct sec_id) from (
select distinct sec_id,rover_date from S2_CSP_VOL_PMC_SEC);

select distinct sec_id from (
select distinct sec_id,rover_date from S2_CSP_VOL_PMC_SEC);


DROP TABLE S3_CSP_VOL_PMC_SEC_MATCH;
--S3_CSP_PMC_SEC_MATCH UNIQLY
CREATE TABLE S3_CSP_VOL_PMC_SEC_MATCH
(
  SEC_ID VARCHAR2(50 BYTE) 
, ROVER_DATE DATE
, marketdate DATE
, CUSIP VARCHAR2(50 BYTE)
, DSQTNAME VARCHAR2(80 BYTE)
, REGION VARCHAR2(50 BYTE)
, TYPECODE VARCHAR2(50 BYTE)
, PRIMISOCURRCODE VARCHAR2(50 BYTE)
, ROVER_VALUE FLOAT
, volume FLOAT
, PRICE_COV VARCHAR2(80 BYTE)
, PMC_SRC VARCHAR2(50 BYTE)
);

--253,439
INSERT INTO S3_CSP_VOL_PMC_SEC_MATCH(sec_id,rover_date,marketdate,cusip,DSQTNAME,REGION,TYPECODE,PRIMISOCURRCODE,rover_value,volume,PRICE_COV,PMC_SRC)
SELECT pd1.*, 'TQA_SEC' AS PMC_SRC
FROM(
SELECT distinct *
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_PRICE_AVAILABLE' --PRICE_FOR_DATE_AVAILABLE + SAME_PRICE_AVAILABLE
UNION
SELECT * 
FROM
(SELECT distinct  * --ONLY PRICE_FOR_DATE_AVAILABLE WITHOUT SAME_PRICE_AVAILABLE / PRICE_FOR_DATE_AVAILABLE - SAME_PRICE_AVAILABLE = PRICE_FOR_DATE_AVAILABLE ONLY
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_DATE_AVAILABLE'
MINUS
SELECT distinct *
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_PRICE_AVAILABLE') pd)pd1;

select count(sec_id) from
(select distinct sec_id,rover_date from S3_CSP_VOL_PMC_SEC_MATCH);

select * from S3_CSP_VOL_PMC_SEC_MATCH;

select count(sec_id) from
(select distinct sec_id,rover_date from S3_CSP_VOL_PMC_SEC_MATCH where PRICE_COV = 'SAME_DATE_AVAILABLE');

--STEP 4NO MATCH
--CREATE TABLE

CREATE TABLE S4_CSP_VOL_PMC_SEC_NO_MATCH
(
  SEC_ID VARCHAR2(50 BYTE) 
, ROVER_DATE DATE
, ROVER_VALUE FLOAT
);

-- --STEP 4 NO MATCH
INSERT INTO S4_CSP_VOL_PMC_SEC_NO_MATCH(SEC_ID,ROVER_DATE,ROVER_VALUE)
SELECT distinct SEC_ID,rover_date,rover_value
FROM CSP_VOL_PMC_ALL_NO_MATCH --ALL_ID -*(*minus) THOSE THAT WAS ALREADY FOUND
MINUS
SELECT distinct SEC_ID,rover_date,rover_value
FROM
(
SELECT distinct *
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_PRICE_AVAILABLE' --PRICE_FOR_DATE_AVAILABLE + SAME_PRICE_AVAILABLE
UNION
SELECT distinct * 
FROM
(SELECT distinct * --ONLY PRICE_FOR_DATE_AVAILABLE WITHOUT SAME_PRICE_AVAILABLE / PRICE_FOR_DATE_AVAILABLE - SAME_PRICE_AVAILABLE = PRICE_FOR_DATE_AVAILABLE ONLY
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_DATE_AVAILABLE'
MINUS
SELECT distinct *
FROM S2_CSP_VOL_PMC_SEC
WHERE PRICE_COV = 'SAME_PRICE_AVAILABLE') PFD);

select count(sec_id) from
(select distinct sec_id,rover_date from S4_CSP_VOL_PMC_SEC_NO_MATCH);


CREATE TABLE S4_CSP_VOL_PMC_SEC_NO_M_DESC
(
  SEC_ID VARCHAR2(50 BYTE) 
, ROVER_DATE DATE
, ROVER_VALUE FLOAT
, DSQTNAME VARCHAR2(80 BYTE)
, REGION VARCHAR2(50 BYTE)
, TYPECODE VARCHAR2(50 BYTE)
, PRIMISOCURRCODE VARCHAR2(50 BYTE)
, STATUSCODE VARCHAR2(20 BYTE)
);

commit;
INSERT INTO S4_CSP_VOL_PMC_SEC_NO_M_DESC(SEC_ID,ROVER_DATE,ROVER_VALUE,DSQTNAME,REGION,TYPECODE,PRIMISOCURRCODE, STATUSCODE)
select distinct SEC_ID,ROVER_DATE,ROVER_VALUE,DSQTNAME,REGION,TYPECODE,PRIMISOCURRCODE, STATUSCODE
from S4_CSP_VOL_PMC_SEC_NO_MATCH
left outer join trqa.ds2cusipchg csp on csp.cusip = SUBSTR(sec_id,1,8)
left outer join trqa.ds2primqtprc p on csp.infocode = p.infocode
left outer join trqa.Ds2CtryQtInfo inf on p.infocode = inf.infocode;


select count(sec_id) from
(select distinct sec_id,rover_date from S4_CSP_VOL_PMC_SEC_NO_M_DESC);

select * from S4_CSP_PMC_SEC_NO_MATCH_DESC where DSQTNAME is null;


--STEP 5 SEC NO MATCH vs BOND DB
--CREATE TABLE
CREATE TABLE S5_CSP_SEC_NM_BOND
(
  SEC_ID VARCHAR2(50 BYTE) 
, ROVER_DATE DATE 
, ROVER_VALUE FLOAT
, ISIN VARCHAR2(50 BYTE)
, SEDOL VARCHAR2(50 BYTE)
, CUSIP VARCHAR2(50 BYTE)
, NAME VARCHAR2(50 BYTE)
, TRADEDATE DATE
, PRC VARCHAR2(50 BYTE)
, PRICE_COV VARCHAR2(80 BYTE)
);

--STEP 5 SEC NO MATCH vs BOND DB
INSERT INTO S5_CSP_SEC_NM_BOND(SEC_ID,ROVER_DATE,ROVER_VALUE,ISIN,SEDOL,CUSIP,NAME,TRADEDATE,PRC,PRICE_COV)
SELECT
SEC_ID,
ROVER_DATE,
ROVER_VALUE,
ms.isin, 
ms.sedol, 
ms.cusip,
ms.name,
p.tradedate, 
p.prc,
case
when (ROUND(rover_value,2))*100 = ROUND(p.prc,2)
or ROUND(rover_value,2) = ROUND(p.prc,2)
then 'SAME_PRICE_AVAILABLE'
else 'SAME_DATE_AVAILABLE'  
end as PRICE_COV
from S4_CSP_PMC_SEC_NO_MATCH no_sec
join trqa.fisecmstrx ms on SUBSTR(no_sec.sec_id,1,8) = ms.cusip
join trqa.fisecmapx mp on mp.type_= ms.type_ and mp.seccode = ms.seccode and mp.ventype=45 and ms.type_=21
join trqa.fiejvprcdly p on p.instrcode = mp.vencode
where no_sec.ROVER_DATE = p.tradedate;



--ONLY SAME_PRICE_AVAILABLE ON BONDS -- 111
select count(sec_id) from (
SELECT distinct SEC_ID,rover_date,rover_value --ONLY PRICE_FOR_DATE_AVAILABLE WITHOUT SAME_PRICE_AVAILABLE / PRICE_FOR_DATE_AVAILABLE - SAME_PRICE_AVAILABLE = PRICE_FOR_DATE_AVAILABLE ONLY
FROM S5_CSP_SEC_NM_BOND
WHERE PRICE_COV = 'SAME_PRICE_AVAILABLE'
MINUS
SELECT distinct SEC_ID,rover_date,rover_value
FROM S5_CSP_SEC_NM_BOND
WHERE PRICE_COV = 'PRICE_FOR_DATE_AVAILABLE');





-------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> HEREEEEEEEE




--ONLY PRICE_FOR_DATE_AVAILABLE ON BONDS
select count(sec_id) from (
SELECT distinct SEC_ID,rover_date,rover_value --ONLY PRICE_FOR_DATE_AVAILABLE WITHOUT SAME_PRICE_AVAILABLE / PRICE_FOR_DATE_AVAILABLE - SAME_PRICE_AVAILABLE = PRICE_FOR_DATE_AVAILABLE ONLY
FROM S5_CSP_SEC_NM_BOND
WHERE PRICE_COV = 'PRICE_FOR_DATE_AVAILABLE'
MINUS
SELECT distinct SEC_ID,rover_date,rover_value
FROM S5_CSP_SEC_NM_BOND
WHERE PRICE_COV = 'SAME_PRICE_AVAILABLE');

--export what's not found (S4 in that case)


select * from S2_CSP_PMC_SEC where sec_id = '760936104';

/* ORYGINAL
2.	CSP, StartDate, EndDate
select csp.cusip, p.marketdate, p.close_
from trqa.ds2primqtprc p
join trqa.ds2cusipchg csp on csp.infocode = p.infocode and startdate = (select max(startdate) from trqa.ds2cusipchg where infocode=csp.infocode)
where csp.cusip='74836K10' and p.marketdate between '01-JAN-17' AND '10-JAN-17';*/
