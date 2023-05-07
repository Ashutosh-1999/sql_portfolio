select * from sqlproject.dbo.Data1;
select * from sqlproject.dbo.Data2;

--COUNTING TOTAL NO.OF ROWS IN DATA1 & data2
SELECT COUNT(*) FROM sqlproject..DATA1;
SELECT COUNT(*) FROM sqlproject..DATA2;

--dataset from states jharkhand and bihar
select * from sqlproject..Data1 where state in ('Jharkhand','Bihar');

--POPULATION OF INDIA 
SELECT SUM(POPULATION) AS POPULATION FROM sqlproject..Data2;

--AVERAGE GROWTH 
SELECT AVG(GROWTH)*100  AS AVG_GROWTH FROM sqlproject..Data1;

--AVG GROWTH OF STATES
SELECT STATE,AVG(GROWTH)*100  AS AVG_GROWTH FROM sqlproject..Data1 GROUP BY STATE;

--AVG SEX RATIO
SELECT state,round(AVG(Sex_Ratio),0) as  AVG_sex_Ratio FROM sqlproject..Data1 group by state;

--AVG SEX RATIO IN DESC ORDER
SELECT state,round(AVG(Sex_Ratio),0) as  AVG_sex_Ratio FROM sqlproject..Data1 group by state ORDER BY  AVG_sex_Ratio DESC;

--AVG LITERACY RATE
SELECT state,round(AVG(Literacy),0) as  AVG_LITERACY_RatE FROM sqlproject..Data1 group by state ORDER BY  AVG_LITERACY_RatE DESC;

--AVG LITERACY RATE GREATER THAN 90
SELECT state,round(AVG(LITERACY),0) as  AVG_LITERACY_RatE FROM sqlproject..Data1 group by state HAVING round(AVG(LITERACY),0) >90 ORDER BY  AVG_LITERACY_RatE DESC;

--TOP 3 STATES SHOWING HIGHEST GROWTH RATIO
SELECT TOP 3 STATE,AVG(GROWTH)*100  AS AVG_GROWTH FROM sqlproject..Data1 GROUP BY STATE ORDER BY AVG_GROWTH DESC;

--BOTTOM 3 STATES SHOWING LOWEST SEX RATIO
 SELECT TOP 3 state,round(AVG(Sex_Ratio),0) as  AVG_sex_Ratio FROM sqlproject..Data1 group by state ORDER BY  AVG_sex_Ratio ASC;

 --TOP AND BOTTOM 3 STATES IN LITERACY RATE
 drop table if exists topstates;
 create table topstates
 (state nvarchar(255),
 top_states float
 )

 insert into topstates
  SELECT state,round(AVG(literacy),0) as  AVG_literacy_Rate FROM sqlproject..Data1 group by state ORDER BY  AVG_literacy_Rate deSC;

  select top 3 * from topstates order by topstates.top_states desc;

  drop table if exists bottomstates;
 create table bottomstates
 (state nvarchar(255),
 bottom_states float
 )

 insert into bottomstates
  SELECT state,round(AVG(literacy),0) as  AVG_literacy_Rate FROM sqlproject..Data1 group by state ORDER BY  AVG_literacy_Rate deSC;

  select top 3 * from bottomstates order by bottomstates.bottom_states asc;

  --union operator to combine both above tables
  select * from(
    select top 3 * from topstates order by topstates.top_states desc) a
	union
	select * from (
  select top 3 * from bottomstates order by bottomstates.bottom_states asc)b;

  --states starting with the letter A or B
  select distinct state from sqlproject..Data1 where lower(state) like 'a%' or lower(state) like 'b%';

  --states starting with letter a and ending with letter m
   select distinct state from sqlproject..Data1 where lower(state) like 'a%' and lower(state) like '%m';

   --joining both tables and extract total number of males and females with the states
   select d.state,sum(d.males)total_males,sum(d.females)total_females from
   (select c.district,c.state,round(c.population/(c.sex_ratio+1),0)males, round((c.population*c.sex_ratio)/(c.sex_ratio+1),0)females from
   (select a.District,a.state,a.sex_ratio/1000 sex_ratio,b.population from sqlproject..Data1 a inner join sqlproject..Data2 b on a.district=b.district)c) d
   group by d.state;

   --total literacy rate(total literate ppl and iliterate ppl)
   select c.state,sum(c.total_literate_people)total_literate_people,sum(c.iliterate_people)total_iliterate_people from
   (select d.district,d.state,round(d.literacy_ratio*d.population,0) total_literate_people, round((1-d.literacy_ratio)*d.population,0) iliterate_people from
  ( select a.District,a.state,a.literacy/100 literacy_ratio,b.population from sqlproject..Data1 a inner join sqlproject..Data2 b on a.district=b.district) d)c
  group by c.state;

  --population in previos census
  SELECT SUM(M.PREVIOUS_CENSUS_POPULATION) PREVIOUS_CENSUS_POPULATION, SUM(M.CURRENT_CENSUS_POPULATION)CURRENT_CENSUS_POPULATION FROM(
  select e.state,sum(e.previous_census_population)previous_census_population,sum(e.current_census_population) current_census_population from
  (select d.district,d.state,round(population/(1+growth),0) previous_census_population,d.population current_census_population from
  (select a.District,a.state,a.growth growth,b.population from sqlproject..Data1 a inner join sqlproject..Data2 b on a.district=b.District) d ) e
  group by e.state)M;

  --POPULATION VS AREA
  SELECT (G.TOTAL_AREA/G.PREVIOUS_CENSUS_POPULATION) AS PREVIOUS_CENSUS_POPULATION_VS_AREA,(G.TOTAL_AREA/G.CURRENT_CENSUS_POPULATION) AS CURRENT_CENSUS_POPULATION_VS_AREA  FROM
  (SELECT Q.*,R.TOTAL_AREA FROM(

  SELECT '1' AS KEYY,N.* FROM(
   SELECT SUM(M.PREVIOUS_CENSUS_POPULATION) PREVIOUS_CENSUS_POPULATION, SUM(M.CURRENT_CENSUS_POPULATION)CURRENT_CENSUS_POPULATION FROM(
  select e.state,sum(e.previous_census_population)previous_census_population,sum(e.current_census_population) current_census_population from
  (select d.district,d.state,round(population/(1+growth),0) previous_census_population,d.population current_census_population from
  (select a.District,a.state,a.growth growth,b.population from sqlproject..Data1 a inner join sqlproject..Data2 b on a.district=b.District) d ) e
  group by e.state)M)N) Q INNER JOIN(

  SELECT '1' AS KEYY,Z.* FROM(
  SELECT SUM(AREA_KM2)TOTAL_AREA FROM sqlproject..Data2)Z)R ON Q.KEYY=R.KEYY) G;

