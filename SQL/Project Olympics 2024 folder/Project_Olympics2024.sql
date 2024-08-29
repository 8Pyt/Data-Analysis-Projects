#importing and checking the dataset
select * 
from athletes;

#Updating the birth_date column to date type
UPDATE athletes
SET birth_date = STR_TO_DATE(birth_date, '%Y-%m-%d');

#Finding out the age of the athletes and inputting the data in a new table
create table athletes_new as
select *, timestampdiff(YEAR, birth_date, '2024-07-01') as age
from athletes; 

#Listing the youngest and oldest athletes participating
with age_agg as 
(select min(age) as min, max(age) as max from athletes_new) 
select code, name, age, country, disciplines
from athletes_new, age_agg
where age = age_agg.min or age = age_agg.max
order by age;

#Checking how many athletes were sent from each country
select country, count(name) as number_athletes
from athletes
group by country 
order by number_athletes desc;

#Checking how many females and males participated
select gender, count(name) as number_athletes
from athletes
group by gender;

#Checking the count of participants for each discipline
select disciplines, count(name) as number_athletes
from athletes
group by disciplines
order by number_athletes desc;

#Checking the number of athletes from the example country by discipline and average age
select disciplines, count(name) as number_athletes, round(avg(age)) as average_age_athletes
from athletes_new
where country like 'Romania'
group by disciplines
order by number_athletes desc;

#Listing all participant from an example country. Here we will check it for Romania
select code, name, gender, country, disciplines, age
from athletes_new
where country like 'Romania'
order by gender, age;

#Checking if there are any athletes that have a different nationality than their country 
select code, name, gender, country, nationality, disciplines, age
from athletes_new
where country != nationality
order by country;

#Checking how the number of athletes by age
select age, count(name) 
from athletes_new
group by age
order by age
