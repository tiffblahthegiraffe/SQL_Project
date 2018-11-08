/*PART A*/
/*1.*/
with q1 as(
SELECT P.prodname, extract(month from F.factdate) as salemonth, sum(F.actsales) as sumSales
FROM prodcoffee P, factcoffee F
WHERE P.productid = F.productid
GROUP BY P.prodname, extract(month from F.factdate)
ORDER BY extract(month from F.factdate) ASC, sum(F.actsales) DESC
)
SELECT prodname,nvl(JAN,0) as Jan, nvl(Feb,0) as Feb,nvl(Mar,0) as Mar,nvl(Apr,0) as Apr,nvl(May,0) as May,nvl(Jun,0) as Jun,
                nvl(Jul,0) as Jul,nvl(Aug,0) as Aug,nvl(Sep,0) as Sep, nvl(Oct,0) as Oct,nvl(Nov,0) as NOv,nvl(DEB,0) as deb
FROM q1
PIVOT(
SUM(sumsales)
FOR salemonth in ('1'as Jan, '2'as Feb,'3'as Mar, '4' as Apr, '5' as May, '6' as Jun,
                '7' as Jul,'8' as Aug,'9' as Sep,'10' as Oct,'11' as nov,'12' as DEB)
)
;

/*2.*/
/*i*/
with q1 as(
SELECT S.statename, P.prodname, sum(F.actsales) sumsales,extract(year from F.factdate) as Salesyear
FROM states S, prodcoffee P, factcoffee F, areacode A
WHERE S.stateid = A.stateid and A.areaid = F. areaid and f.productid = P.productid
GROUP BY S.statename, P.prodname, extract(year from F.factdate)
),

q2 as(
SELECT statename, prodname, sumsales, rank()over(partition by statename order by sumsales desc) rankings
FROM q1
WHERE salesyear = 2012
),

q3 as(
SELECT statename, prodname, sumsales, rank()over(partition by statename order by sumsales desc) rankings
FROM q1
WHERE salesyear = 2013
)

SELECT q2.statename,q2.prodname,q2.rankings rank_2012,q3.rankings rank_2013
FROM q2,q3
WHERE q2.statename = q3.statename and q2.prodname = q3.prodname and q2.rankings = 1 and q3.rankings = 1
ORDER BY q2.statename 
;

/*ii*/
with q1 as(
SELECT S.statename, P.prodname, sum(F.actsales) sumsales,extract(year from F.factdate) as Salesyear
FROM states S, prodcoffee P, factcoffee F, areacode A
WHERE S.stateid = A.stateid and A.areaid = F. areaid and f.productid = P.productid
GROUP BY S.statename, P.prodname, extract(year from F.factdate)
),

q2 as(
SELECT statename, prodname, sumsales, rank()over(partition by statename order by sumsales desc) rankings
FROM q1
WHERE salesyear = 2012
),

q3 as(
SELECT statename, prodname, sumsales, rank()over(partition by statename order by sumsales desc) rankings
FROM q1
WHERE salesyear = 2013
)

SELECT q2.statename,q2.prodname,q2.rankings rank_2012,q3.rankings rank_2013
FROM q2,q3
WHERE q2.statename = q3.statename and q2.prodname = q3.prodname and q2.rankings = 1 and q3.rankings > 1
ORDER BY q2.statename 
;

/*iii*/
with q1 as(
SELECT P.prodname, sum(F.actprofit) sumprofit,extract(year from F.factdate) as Salesyear
FROM prodcoffee P, factcoffee F
WHERE f.productid = P.productid
GROUP BY P.prodname, extract(year from F.factdate)
),

q2 as(
SELECT prodname, sumprofit, rank()over(order by sumprofit desc) rankings
FROM q1
WHERE salesyear = 2012
),

q3 as(
SELECT prodname, sumprofit, rank()over(order by sumprofit desc) rankings
FROM q1
WHERE salesyear = 2013
)

SELECT q2.prodname,q2.rankings rank_2012,q3.rankings rank_2013
FROM q2,q3
WHERE q2.prodname = q3.prodname and q2.rankings = 1 and q3.rankings > 1
;

/*3.*/
with q1 as(
SELECT P.prodname, sum(F.actsales) sumsales,extract(year from F.factdate) as Salesyear
FROM prodcoffee P, factcoffee F, areacode A
WHERE A.areaid = F. areaid and f.productid = P.productid
GROUP BY P.prodname, extract(year from F.factdate)
),

q2 as(
SELECT prodname, sumsales, rank()over(order by sumsales desc) rankings
FROM q1
WHERE salesyear = 2012
),

q3 as(
SELECT prodname, sumsales, rank()over(order by sumsales desc) rankings
FROM q1
WHERE salesyear = 2013
)

SELECT q2.prodname,q2.rankings rank_2012,q3.rankings rank_2013
FROM q2,q3
WHERE q2.prodname = q3.prodname
ORDER BY q2.rankings, q3.rankings
FETCH FIRST 2 ROWS ONLY
;

/*4.*/
SELECT statename, sumsales, sumprofit, salespercent,profitpercent,
sum(salespercent)over(order by sumsales DESC)||'%' as cum_salespercent,
sum(profitpercent)over(order by sumsales DESC)||'%' as cum_profitpercent
FROM
(
SELECT statename, sumsales, sumprofit, round(100*ratio_to_report(sum(sumsales)) over(),2) salespercent,
round(100*ratio_to_report(sum(sumprofit))over(),2) profitpercent
FROM
(
SELECT S.statename, sum(F.actsales) sumsales, sum(F.actprofit) sumprofit
FROM states S,areacode A, factcoffee F
WHERE S.stateid = A.stateid and A.areaid = F.areaid
GROUP BY S.statename
ORDER BY sum(F.actsales) DESC
)
GROUP BY statename, sumsales, sumprofit
ORDER BY sumsales DESC
)
GROUP BY statename, sumsales, sumprofit, salespercent, profitpercent
ORDER BY sumsales DESC
FETCH FIRST 7 ROWS ONLY
;

/*5.*/
SELECT P.prodname, sum(F.actsales)sumsales, sum(F.actprofit)sumprofit
FROM prodcoffee P, factcoffee F
WHERE P.productid = F.productid
GROUP BY P.prodname
ORDER BY sum(F.actprofit) ASC
;

SELECT prodname, abs(totalprofit-budgetprofit) difference
FROM
(
SELECT P.prodname, sum(F.budprofit)budgetprofit, sum(F.actprofit)totalprofit
FROM prodcoffee P, factcoffee F
WHERE P.productid = F.productid
GROUP BY P.prodname
ORDER BY sum(F.actprofit) ASC
)
ORDER BY difference DESC
FETCH FIRST 10 ROWS ONLY
;

SELECT prodname, Y2012, Y2013, Round(100*(Y2013-Y2012)/abs(Y2012),2)||'%' growth_rate
FROM
(
SELECT prodname, nvl(Y2012,0)Y2012,nvl(Y2013,0)Y2013
FROM
(
SELECT P.prodname, extract(year from F.factdate) salesyear, sum(F.actprofit)sumprofit
FROM prodcoffee P, factcoffee F
WHERE P.productid = F.productid
GROUP BY P.prodname, extract(year from F.factdate) 
)
PIVOT(
sum(sumprofit)
FOR salesyear in ('2012'as Y2012,'2013' as Y2013)
)
)
ORDER BY Round(100*(Y2012-Y2013)/Y2012,2) ASC
FETCH FIRST 10 ROWS ONLY
;

/*6.*/
SELECT salesyear, nvl(JAN,0) as Jan, nvl(Feb,0) as Feb,nvl(Mar,0) as Mar,nvl(Apr,0) as Apr,nvl(May,0) as May,nvl(Jun,0) as Jun,
    nvl(Jul,0) as Jul,nvl(Aug,0) as Aug,nvl(Sep,0) as Sep, nvl(Oct,0) as Oct,nvl(Nov,0) as NOv,nvl(DEB,0) as deb
FROM
(
SELECT extract(year from F.factdate)as salesyear, extract(month from F.factdate) as salemonth, sum(F.actsales) as sumSales
FROM factcoffee F
WHERE extract(year from F.factdate) = 2012
GROUP BY extract(month from F.factdate), F.factdate, extract(year from F.factdate)
ORDER BY extract(month from F.factdate)
)

PIVOT(
SUM(sumsales)
FOR salemonth in ('1'as Jan, '2'as Feb,'3'as Mar, '4' as Apr, '5' as May, '6' as Jun,
                '7' as Jul,'8' as Aug,'9' as Sep,'10' as Oct,'11' as nov,'12' as DEB)
)

UNION

SELECT salesyear, nvl(JAN,0) as Jan, nvl(Feb,0) as Feb,nvl(Mar,0) as Mar,nvl(Apr,0) as Apr,nvl(May,0) as May,nvl(Jun,0) as Jun,
    nvl(Jul,0) as Jul,nvl(Aug,0) as Aug,nvl(Sep,0) as Sep, nvl(Oct,0) as Oct,nvl(Nov,0) as NOv,nvl(DEB,0) as deb
FROM
(
SELECT extract(year from F.factdate)as salesyear, extract(month from F.factdate) as salemonth, sum(F.actsales) as sumSales
FROM factcoffee F
WHERE extract(year from F.factdate) = 2013
GROUP BY extract(month from F.factdate), F.factdate, extract(year from F.factdate)
ORDER BY extract(month from F.factdate)
)

PIVOT(
SUM(sumsales)
FOR salemonth in ('1'as Jan, '2'as Feb,'3'as Mar, '4' as Apr, '5' as May, '6' as Jun,
                '7' as Jul,'8' as Aug,'9' as Sep,'10' as Oct,'11' as nov,'12' as DEB)
)
;

/*i--2012*/

SELECT prodname, nvl(JAN,0) as Jan, nvl(Feb,0) as Feb,nvl(Mar,0) as Mar,nvl(Apr,0) as Apr,nvl(May,0) as May,nvl(Jun,0) as Jun,
    nvl(Jul,0) as Jul,nvl(Aug,0) as Aug,nvl(Sep,0) as Sep, nvl(Oct,0) as Oct,nvl(Nov,0) as NOv,nvl(DEB,0) as deb
FROM
(
SELECT P.prodname, extract(month from F.factdate) as salemonth, sum(F.actsales) as sumSales
FROM Prodcoffee P, factcoffee F
WHERE P.productid = F.productid and extract(year from F.factdate) = 2012
GROUP BY P.prodname, extract(month from F.factdate)
ORDER BY extract(month from F.factdate)
)

PIVOT(
SUM(sumsales)
FOR salemonth in ('1'as Jan, '2'as Feb,'3'as Mar, '4' as Apr, '5' as May, '6' as Jun,
                '7' as Jul,'8' as Aug,'9' as Sep,'10' as Oct,'11' as nov,'12' as DEB)
);

/*i--2013*/


SELECT prodname, nvl(JAN,0) as Jan, nvl(Feb,0) as Feb,nvl(Mar,0) as Mar,nvl(Apr,0) as Apr,nvl(May,0) as May,nvl(Jun,0) as Jun,
    nvl(Jul,0) as Jul,nvl(Aug,0) as Aug,nvl(Sep,0) as Sep, nvl(Oct,0) as Oct,nvl(Nov,0) as NOv,nvl(DEB,0) as deb
FROM
(
SELECT P.prodname, extract(month from F.factdate) as salemonth, sum(F.actsales) as sumSales
FROM Prodcoffee P, factcoffee F
WHERE P.productid = F.productid and extract(year from F.factdate) = 2013
GROUP BY P.prodname, extract(month from F.factdate)
ORDER BY extract(month from F.factdate)
)

PIVOT(
SUM(sumsales)
FOR salemonth in ('1'as Jan, '2'as Feb,'3'as Mar, '4' as Apr, '5' as May, '6' as Jun,
                '7' as Jul,'8' as Aug,'9' as Sep,'10' as Oct,'11' as nov,'12' as DEB)
);

/*ii*/
/*New York*/
with q1 as (
select P.prodname, to_char(factdate, 'mm') as Month, sum(F.actsales) as TotProdsales
from factcoffee F, prodcoffee P, areacode A
where p.productid = f.productid and A.areaid = F.areaid and A.stateid = 1013
group by P.prodname, to_char(factdate, 'mm'))
select prodname, nvl(Jan,0) as Jan, nvl(Feb, 0) as Feb,
nvl(Mar,0) as Mar, nvl(Apr, 0) as Apr,
nvl(May,0) as May, nvl(Jun, 0) as Jun,
nvl(Jul,0) as Jul, nvl(Aug, 0) as Aug,
nvl(Sep,0) as Sep, nvl(Oct, 0) as Oct,
nvl(Nov,0) as Nov, nvl(Dec, 0) as Dec
FROM Q1
PIVOT (
Sum(TotProdsales)
FOR Month IN ('01' as Jan, '02' as Feb, '03' as Mar, '04' as Apr, '05' as May, '06' as Jun, '07' as Jul, '08' as Aug, '09' as Sep, '10' as Oct, '11' as Nov, '12' as Dec));

/*Texas*/
with q1 as (
select P.prodname, to_char(factdate, 'mm') as Month, sum(F.actsales) as TotProdsales
from factcoffee F, prodcoffee P, areacode A
where p.productid = f.productid and A.areaid = F.areaid and A.stateid = 1017
group by P.prodname, to_char(factdate, 'mm'))
select prodname, nvl(Jan,0) as Jan, nvl(Feb, 0) as Feb,
nvl(Mar,0) as Mar, nvl(Apr, 0) as Apr,
nvl(May,0) as May, nvl(Jun, 0) as Jun,
nvl(Jul,0) as Jul, nvl(Aug, 0) as Aug,
nvl(Sep,0) as Sep, nvl(Oct, 0) as Oct,
nvl(Nov,0) as Nov, nvl(Dec, 0) as Dec
FROM Q1
PIVOT (
Sum(TotProdsales)
FOR Month IN ('01' as Jan, '02' as Feb, '03' as Mar, '04' as Apr, '05' as May, '06' as Jun, '07' as Jul, '08' as Aug, '09' as Sep, '10' as Oct, '11' as Nov, '12' as Dec));


/*7.*/
ALTER TABLE factcoffee
ADD quarter char(2);

UPDATE factcoffee
SET Quarter = 'Q1'
WHERE (to_char(factdate,'Mon'))='Jan' or(to_char(factdate,'Mon'))='Feb'or(to_char(factdate,'Mon'))='Mar';

UPDATE factcoffee
SET Quarter = 'Q2'
WHERE (to_char(factdate,'Mon'))='Apr' or(to_char(factdate,'Mon'))='May'or(to_char(factdate,'Mon'))='Jun';

UPDATE factcoffee
SET Quarter = 'Q3'
WHERE (to_char(factdate,'Mon'))='Jul' or(to_char(factdate,'Mon'))='Aug'or(to_char(factdate,'Mon'))='Sep';

UPDATE factcoffee
SET Quarter = 'Q4'
WHERE (to_char(factdate,'Mon'))='Oct' or(to_char(factdate,'Mon'))='Nov'or(to_char(factdate,'Mon'))='Dec';

/*i*/
SELECT *
FROM
(
SELECT extract(year from F.factdate)as salesyear, F.quarter, sum(F.actsales) as sumSales
FROM factcoffee F
GROUP BY extract(year from F.factdate), F.quarter
ORDER BY F.quarter ASC
)

PIVOT(
SUM(sumsales)
FOR quarter in ('Q1'as Q1,'Q2'as Q2,'Q3'as Q3,'Q4'as Q4)
)
ORDER BY salesyear ASC
;

/*ii--2012*/
SELECT quarter Y2012, sum(actsales) sumsales, sum(actprofit) sumprofit,
rank()over(order by sum(actsales) DESC) as salesrank,
rank()over(order by sum(actprofit)DESC) as profitrank
FROM factcoffee
WHERE extract(year from factdate) =2012
GROUP BY quarter
ORDER BY quarter ASC;

/*ii--2013*/
SELECT quarter Y2013, sum(actsales) sumsales, sum(actprofit) sumprofit,
rank()over(order by sum(actsales) DESC) as salesrank,
rank()over(order by sum(actprofit)DESC) as profitrank
FROM factcoffee
WHERE extract(year from factdate) =2013
GROUP BY quarter
ORDER BY quarter ASC;

/*8.*/
CREATE TABLE COMBINATION as(
SELECT S.statename, P.prodname, F.quarter, sum(F.actsales) totalsales, sum(F.actprofit)totalprofit, 
Round(100*sum(actprofit)/sum(actsales),2)||'%' perc_margin,sum(F.actmarkcost)totalmarketing,
rank()over(partition by F.quarter order by sum(F.actsales)DESC)salesrank
FROM areacode A, states S, prodcoffee P, factcoffee F
WHERE S.stateid = A.stateid and A.areaid = F.areaid and F.productid = P.productid
GROUP BY S.statename, P.prodname, F.quarter
);

/*PART B*/
/*1.*/
SELECT M.regmanager, sum(D.ordsales) totalsales, rank()over(order by sum(D.ordsales) DESC) rankings
FROM managers M, customers C, orderdet D
WHERE M.regid = C.custreg and C.custid = D.custid
GROUP BY M.regmanager
ORDER BY sum(D.ordsales) DESC;

/*2.*/
SELECT prodname,prodcat, avg(ordshipdate-orddate) avgshiptime, count(orderid) totalorders
FROM
(
SELECT D.orderid,P.prodname,P.prodcat, D.orddate, D.ordshipdate
FROM products P, orderdet D
WHERE P.prodid = D.prodid
)
GROUP BY prodname, prodcat,(ordshipdate-orddate)
/*ORDER BY count(orderid) DESC*/
ORDER BY avg(ordshipdate-orddate) DESC
FETCH FIRST 10 ROWS ONLY
;

/*3.*/
SELECT custname, sumsales, percentsales, sum(percentsales)over(order by sumsales desc)||'%' cum_percentsales
FROM
(
SELECT custname, sumsales, Round(100*ratio_to_report(sum(sumsales)) over(),2) percentsales
FROM
(
SELECT C.custname, sum(D.ordqty)sumqty, sum(D.ordsales)sumsales
FROM customers C, orderdet D
WHERE C.custid = D.custid
GROUP BY C.custname
)
GROUP BY custname, sumsales
ORDER BY sumsales DESC
)
ORDER BY sumsales DESC
FETCH FIRST 10 PERCENT ROWS ONLY
;
/*4.*/
SELECT custname, sumsales, sumqty, percentqty, sum(percentqty)over(order by sumsales desc)||'%' cum_percentqty
FROM
(
SELECT custname, sumsales,sumqty, Round(100*ratio_to_report(sum(sumqty)) over(),2) percentqty
FROM
(
SELECT C.custname, sum(D.ordqty)sumqty, sum(D.ordsales)sumsales
FROM customers C, orderdet D
WHERE C.custid = D.custid
GROUP BY C.custname
)
GROUP BY custname, sumqty, sumsales
ORDER BY sumsales DESC
)
ORDER BY sumsales DESC
FETCH FIRST 10 PERCENT ROWS ONLY
;

/*5.*/
SELECT c.custstate, C.custcity, P.prodname, sum(D.ordsales)sumsales, 
rank()over(partition by C.custstate, C.custcity order by sum(D.ordsales)DESC)rankings
FROM customers C, products P, orderdet D
WHERE C.custid = D.custid and D.prodid = P.prodid
GROUP BY C.custstate,C.custcity, P.prodname
ORDER BY C.custstate ASC,C.custcity ASC, sum(D.ordsales) DESC
FETCH FIRST 10 ROWS ONLY
;

/*6.*/
SELECT custname,nvl(y2010,0)as y2010,nvl(y2011,0)as y2011,nvl(y2012,0)as y2012,nvl(y2013,0)as y2013
FROM
(
SELECT C.custname, sum(D.ordqty) totalorders, sum(D.ordsales)sumsales, extract(year from D.orddate)salesyear,
rank()over(partition by extract(year from D.orddate)order by sum(D.ordqty)DESC) as orderrank,
rank()over(partition by extract(year from D.orddate)order by sum(D.ordsales)DESC) as salesrank
FROM customers C, orderdet D
WHERE C.custid = D.custid
GROUP BY extract(year from D.orddate),C.custname
ORDER BY salesrank, extract(year from D.orddate) asc
FETCH FIRST 20 ROWS ONLY
)
PIVOT(
sum(sumsales)
FOR salesyear in ('2010' as y2010,'2011'as y2011,'2012'as y2012,'2013' as y2013)
)
ORDER BY Y2010 DESC, Y2011 DESC, Y2012 DESC,Y2013 DESC
;

/*7.*/
with q1 as(
SELECT P.prodsubcat, sum(D.ordqty)numorders_M
FROM customers C, products P, orderdet D
WHERE C.custid = D.custid and D.prodid= P.prodid and C.custstate = 'Michigan'
GROUP BY P.prodsubcat
),
q2 as(
SELECT P.prodsubcat, sum(D.ordqty)numorders_W
FROM customers C, products P, orderdet D
WHERE C.custid = D.custid and D.prodid= P.prodid and C.custstate = 'Washington'
GROUP BY P.prodsubcat
)
SELECT q1.prodsubcat,numorders_M,numorders_W
FROM q1,q2
WHERE q2.prodsubcat = q1.prodsubcat
FETCH FIRST 10 ROWS ONLY
;

/*8.*/
ALTER TABLE orderdet
ADD quarter char(2);

UPDATE orderdet
SET Quarter = 'Q1'
WHERE (to_char(orddate,'Mon'))='Jan' or(to_char(orddate,'Mon'))='Feb'or(to_char(orddate,'Mon'))='Mar';

UPDATE orderdet
SET Quarter = 'Q2'
WHERE (to_char(orddate,'Mon'))='Apr' or(to_char(orddate,'Mon'))='May'or(to_char(orddate,'Mon'))='Jun';

UPDATE orderdet
SET Quarter = 'Q3'
WHERE (to_char(orddate,'Mon'))='Jul' or(to_char(orddate,'Mon'))='Aug'or(to_char(orddate,'Mon'))='Sep';

UPDATE orderdet
SET Quarter = 'Q4'
WHERE (to_char(orddate,'Mon'))='Oct' or(to_char(orddate,'Mon'))='Nov'or(to_char(orddate,'Mon'))='Dec';

SELECT quarter,nvl(Y2010,0)Y2010,nvl(Y2011,0)Y2011,nvl(Y2012,0)Y2012,nvl(Y2013,0)Y2013
FROM
(
SELECT extract(year from orddate) salesyear, quarter, sum(ordqty)orderqty
FROM orderdet
GROUP BY quarter, extract(year from orddate)
ORDER BY quarter ASC
)
PIVOT(
sum(orderqty)
FOR salesyear IN ('2010'as Y2010,'2011'as Y2011,'2012'as Y2012,'2013'as Y2013)
)
ORDER BY quarter ASC
;

/*9.*/
SELECT custseg, nvl(Q1,0)Q1, nvl(Q2,0)Q2, nvl(Q3,0)Q3, nvl(Q4,0)Q4
FROM
(
SELECT D.quarter, C.custseg, sum(D.ordsales) totalsales
FROM orderdet D,customers C
WHERE D.custid = C.custid
GROUP BY D.quarter, C.custseg
ORDER BY D.quarter ASC
)
PIVOT(
sum(totalsales)
FOR quarter in ('Q1'as Q1,'Q2'as Q2,'Q3'as Q3,'Q4'as Q4)
)
;
