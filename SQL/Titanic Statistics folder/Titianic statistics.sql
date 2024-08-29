#Importing the CSV and checking the table
select *
from titanic_passangers
order by age desc; 

#Listing all the survivors by age
select Name, Sex, Age, Fare
from titanic_passangers
where Survived = 1
order by Age;

#Checking the difference between survival rates by gender
select sex, count(name), 
case
when survived = 0 then 'Died'
else 'Survived'
end as Status
from titanic_passangers
group by sex, survived
order by survived, sex;

#Checking the survival probability by total and divided by gender
select 
round((count_male_s.total_male_s + count_female_s.total_female_s)/(count_male.total_male + count_male.total_male)*100,2) as total_survival_percentage,
round(count_male_s.total_male_s/count_male.total_male*100,2) as precentage_survival_male,
round(count_female_s.total_female_s/count_female.total_female*100,2) as precentage_survival_female
from 
(select count(name) as total_male_s
from titanic_passangers
where sex = 'male' and survived = 1) as count_male_s,
(select count(name) as total_female_s
from titanic_passangers
where sex = 'female' and survived = 1) as count_female_s,
(select count(name) as total_male
from titanic_passangers
where sex = 'male') as count_male,
(select count(name) as total_female
from titanic_passangers
where sex = 'female') as count_female;

#Checking the average price for ticket per class
select pclass, round(avg(fare), 2) as average_price
from titanic_passangers
group by pclass
order by pclass desc;

#Checking statistics by class
select pclass, sex, survived, count(name) as count
from titanic_passangers
group by pclass, survived, sex
order by pclass desc, survived, sex;

#Calculating probability of survival based on class
select pclass, sex, round(avg(survived),2) as chance_of_survival
from titanic_passangers
group by pclass, sex
order by pclass desc, sex;

#Checking for the same statistic but this time for passangers younger than 18 
select pclass, sex, round(avg(survived),2) as chance_of_survival
from titanic_passangers
where age <18
group by pclass, sex
order by pclass desc, sex;

#Checking for the same statistic but this time for passangers older than 50
select pclass, sex, round(avg(survived),2) as chance_of_survival
from titanic_passangers
where age >=50
group by pclass, sex
order by pclass desc, sex;

#Exploring who had the best chance of survival based on class, gender, age, and price paid (determines the class) 
select pclass, sex, 
case
	when age <18 then 'minor (18-)'
    when age between 18 and 31 then 'young adult(18-30)'
    when age between 30 and 51 then 'adult(30-50)'
    else 'senior (50+)'
end as age_bracket,
round(avg(fare), 2) as average_ticket_fare,
round(avg(survived),2) as chance_of_survival
from titanic_passangers
group by pclass, age_bracket, sex
order by chance_of_survival desc;

#Lastly we will check the average age of survivors and persihed per class and gender 
select pclass, sex, round(avg(age))
from titanic_passangers
where survived = 1
group by pclass, sex
order by pclass desc
;

#As we can see, mainly seniors, minors and (young) adult females from 1st and 2nd class had the best chances of survival, while senior and adult males from 2nd and 3rd class had the lowest chances. 
#One of the elements that is overlooked here is the cultural and social environment of the time (1912) as well as the behavioral factors
#Even so, passangers from the 1st and 2nd class probably had better access to lifeboats, being closer to the ship's deck as well as more influence and resources for bribery 