
# segment 1:- database - tables,column,relation ships

#2.find the total number of rows in each table of the schema.
select table_name ,
table_rows from information_schema.Tables
where table_schema='imdb' ;
#3. identify which coloumns in the movies table have null values.
describe movies;
select 'id' , count(*) as null_count 
from movies

where id is null
union 
select 'title', count(*) as null_count
from movies  where title is null
union
select 'year' ,count(*) as null_count 
from movies where year is null
union
select 'date_published'  ,count(*) as null_count 
from movies
where date_published is null
union
select 'duration',count(*) as null_count 
from movies where duration  is null
union
select 'country' , count(*) as null_count
from  movies where country is null
union
select 'worlwide_gross_income' , count(*) as null_count
from movies where worlwide_gross_income is null
union
select 'languages' , count(*) as null_count
from movies where languages is null
union
select 'production_company', count(*) as null_count 
from movies where production_company is null;

#segment 2:movie release trends
#determine the total number of movies released each year and analyse the month wise trend.
 select month (date_published) as month ,year(date_published)as year
 from movies;
 # calculate the number of movies produced in  usa or india in the year 2019.
 
select count(*) from movies 
 
 where country in('usa','india')and year in(date_published)=2019;
#segment 3:- production statistics and genre analysis
# retrieve the unique list of genre present in dataset.
select distinct genre from genre;
# identify the genre with the highest number of movies produced overall.
select g.genre ,max(m.title) as title from movies m
inner join genre g on m.id=g.movie_id
group by g.genre;
#determine the count of movies that belong to only one genre.
with cte as(
	select 
		movie_id , 
        count(genre) as cnt
	from 
		genre 
	group by 
		movie_id)
        select count(movie_id) as num_mov_one_genre  from cte where cnt=1 ;
#Calculate the average duration of movies in each genre.
select 
	genre , 
    avg(m.duration) as avg_duration  
from 
	genre g 
inner join 
	movies m on g.movie_id=m.id 
group by 
	genre;
#Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
with cte as (
select 
	genre , 
    count(*) as movie_count
from 
	genre g 
group by 
	genre),
    cte2 as 
    (select * , 
	rank() over(order by movie_count desc) as rnk
from 
	 cte)
     select * from cte2 where genre ="thriller";
#segment 4:-Ratings Analysis and Crew Member.
-- Ratings Analysis
select r.avg_rating as rating_analysis from  rating r
inner join movies m on r.movie_id=m.id;
  #Identify the top 10 movies based on average rating
select (m.title) as movie_title,r.avg_rating as average_rating  from rating r
join  movies m on r.movie_id=m.id
group by  movie_title,average_rating
order by average_rating desc
limit 10;
 #Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
 select * from rating;
SELECT
    MIN(avg_rating) AS min_avg_rating,
    MAX(avg_rating) AS max_avg_rating,
    MIN(total_votes) AS min_total_votes,
    MAX(total_votes) AS max_total_votes,
    MIN(median_rating) AS min_median_rating,
    MAX(median_rating) AS max_median_rating
FROM rating;
 #Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
 SELECT COUNT(m.title) AS movie_count, g.genre
FROM movies m
JOIN genre g ON m.id = g.movie_id
JOIN rating r ON m.id = r.movie_id
WHERE m.year = '2017' AND MONTH(m.date_published)  AND m.country = 'USA' AND r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;


-- Summarise the ratings table based on movie counts by median ratings.
SELECT MEDIAN_RATING,COUNT(MOVIE_ID) AS MOVIE_COUNT
FROM RATING
GROUP BY MEDIAN_RATING
ORDER BY MOVIE_COUNT DESC;


-- Identify the production house that has produced the most number of hit movies (average rating > 8).
SELECT * FROM MOVIES LIMIT 10;
SELECT PRODUCTION_COMPANY,COUNT(ID) AS MOVIE_COUNT
FROM MOVIES
WHERE ID IN (SELECT MOVIE_ID FROM RATING WHERE AVG_RATING > 8)
AND PRODUCTION_COMPANY IS NOT NULL
GROUP BY PRODUCTION_COMPANY
ORDER BY MOVIE_COUNT DESC
LIMIT 1;

-- Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.

SELECT GENRE,COUNT(A.MOVIE_ID) AS MOVIE_COUNT
FROM GENRE A
JOIN MOVIES B
ON A.MOVIE_ID = B.ID
JOIN RATING C
ON A.MOVIE_ID = C.MOVIE_ID
WHERE YEAR = 2017
AND MONTH(DATE_PUBLISHED) = 3
AND COUNTRY LIKE '%USA%'
AND TOTAL_VOTES > 1000
GROUP BY GENRE
ORDER BY MOVIE_COUNT DESC ;

-- Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
SELECT TITLE,AVG_RATING,GENRE
FROM MOVIES A
JOIN GENRE B
ON A.ID = B.MOVIE_ID
JOIN RATING C
ON A.ID = C.MOVIE_ID
WHERE TITLE LIKE 'THE%'
AND AVG_RATING > 8;

with cte as
(SELECT TITLE,AVG_RATING,GENRE
FROM MOVIES A
JOIN GENRE B
ON A.ID = B.MOVIE_ID
JOIN RATING C
ON A.ID = C.MOVIE_ID
WHERE TITLE LIKE 'THE%'
AND AVG_RATING > 8)

select title,avg_rating,group_concat(distinct genre) as genres
from cte group by title,avg_rating
order by title;



-- Segment 5: Crew Analysis

-- Identify the columns in the names table that have null values.
-- using case statement
select * from names limit 100;
-- Method 1 
SELECT sum(case when id is null then 1 else 0 end) as id_null_count,
sum(case when name is null then 1 else 0 end) as name_null_count,
sum(case when height is null then 1 else 0 end) as height_null_count,
sum(case when date_of_birth is null then 1 else 0 end) as dob_null_count,
sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_null_count
FROM names;

-- Method 2 
select count(*) id from names where id is null;
select count(*) name from names where name is null;

-- Determine the top three directors in the top three genres with movies having an average rating > 8.

select * From genre;

select * from director_mapping;

select * from rating;

with genre_top_3 as
(select genre,count(movie_id) as num_movies
from genre 
where movie_id in (select movie_id from rating where avg_rating > 8)
group by genre
order by num_movies desc
limit 3) ,

director_genre_movies as
(select b.movie_id,b.genre,c.name_id,d.name
from genre b 
join director_mapping c
on b.movie_id = c.movie_id
join names d on c.name_id = d.id
where b.movie_id in (select movie_id from rating where avg_rating > 8))

select * from
(select genre,name as director_name,count(movie_id) as num_movies,
row_number() over (partition by genre order by count(movie_id) desc) as director_rk
from director_genre_movies 
where genre in (select distinct genre from genre_top_3)
group by genre,name)t
where director_rk <= 3
order by genre,director_rk;


-- Find the top two actors whose movies have a median rating >= 8.

select * from role_mapping limit 100; -- ratings & names

with top_actors as
(select name_id,count(movie_id) as num_movies
from role_mapping 
where category = 'actor'
and movie_id in (select movie_id from rating where median_Rating >= 8)
group by name_id
order by num_movies desc
limit 2)

select b.name as actors,num_movies 
from top_actors a
join names b
on a.name_id = b.id
order by num_movies desc;

 #Identify the top three production houses based on the number of votes received by their movies.
select production_company,sum(total_votes) as totalvotes
from movies a join rating b on a.id = b.movie_id
group by production_company
order by totalvotes desc
limit 3; 
-- Rank actors based on their average ratings in Indian movies released in India.
with actors_cte as
(select name_id,sum(total_votes) as total_votes,
count(a.movie_id) as movie_count,
sum(avg_rating * total_votes)/sum(total_votes) as actor_avg_rating
from role_mapping a
join rating b
on a.movie_id = b.movie_id
where category = 'actor'
and a.movie_id in
(select distinct id from movies
where country like '%India%')
group by name_id)


select b.name as actor_name,total_votes,movie_count,actor_avg_rating,
dense_rank() over (order by actor_avg_rating desc) as actor_rank
from actors_cte a
join names b
on a.name_id = b.id
order by actor_avg_rating desc ;


-- Identify the top five actresses in Hindi movies released in India based on their average ratings.
select distinct languages From movies;

with actors_cte as
(select name_id,sum(total_votes) as total_votes,
count(a.movie_id) as movie_count,
sum(avg_rating * total_votes)/sum(total_votes) as actress_avg_rating
from role_mapping a
join rating b
on a.movie_id = b.movie_id
where category = 'actress'
and a.movie_id in
(select distinct id from movies
where country like '%India%'
and languages like '%Hindi%')
group by name_id)
select b.name as actor_name,total_votes,movie_count,round(actress_avg_rating,2) as actress_avg_rating,
dense_rank() over (order by actress_avg_rating desc,total_votes desc) as actress_rank
from actors_cte a
join names b
on a.name_id = b.id
 where movie_count > 1
order by actress_rank ;


-- Segment 6: Broader Understanding of Data

-- Classify thriller movies based on average ratings into different categories.
-- Rating > 8: Superhit
-- Rating between 7 and 8: Hit
-- Rating between 5 and 7: One-time-watch
-- Rating < 5: Flop

select a.title,case when avg_Rating > 8 then '1. Superhit'
when avg_rating between 7 and 8 then '2. Hit'
when avg_rating between 5 and 7 then '3. One-time-watch'
else '4. Flop' end as movie_category
from movies a
join rating b
on a.id = b.movie_id
where a.id in (select movie_id from genre where genre = 'Thriller')
order by movie_category;

-- analyse the genre-wise running total and moving average of the average movie duration.
with genre_avg_duration as
(select genre, avg(duration) as avg_duration
from genre a join movies b
on a.movie_id = b.id
group by genre)

select genre ,round(avg_duration,2) avg_duration,
round(sum(avg_duration) over (order by genre),2) as running_total,
round(avg(avg_duration) over (order by genre),2) as moving_avg
from genre_avg_duration order by genre;

-- Identify the five highest-grossing movies of each year that belong to the top three genres.
with genre_top_3 as
(select genre, count(movie_id) as movie_count
from genre group by genre
order by movie_count desc
limit 3),

base_table as
(select a.*,b.genre, replace(worlwide_gross_income,'$ ','') as new_gross_income
from movies a
join genre b
on a.id = b.movie_id
where genre in (select genre from genre_top_3))

select * from 
(select genre,year,title,worlwide_gross_income,
dense_rank() over (partition by genre,year order by new_gross_income desc) as movie_rank
from base_table)t
where movie_rank <= 5
order by genre,year,movie_rank;


-- Determine the top two production houses that have produced the highest number of hits among multilingual movies. (average rating > 8)

use imdb;
select languages,locate(',',languages) from movies limit 100;

select * From rating;

select production_company,count(id) as movie_count
from movies
where locate(',',languages)>0
and id in (Select movie_id from rating where avg_rating > 8)
and production_company is not null
group by production_company
order by movie_count desc
limit 2;

-- Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
with actors_cte as
(select name_id,sum(total_votes) as total_votes,
count(a.movie_id) as movie_count,
sum(avg_rating * total_votes)/sum(total_votes) as actress_avg_rating
from role_mapping a
join rating b
on a.movie_id = b.movie_id
where category = 'actress'
and a.movie_id in
(select distinct movie_id from genre
where genre = 'Drama')
group by name_id
having sum(avg_rating * total_votes)/sum(total_votes) > 8)


select b.name as actor_name,total_votes,movie_count,round(actress_avg_rating,2) as actress_avg_rating,
dense_rank() over (order by actress_avg_rating desc,total_votes desc) as actress_rank
from actors_cte a
join names b
on a.name_id = b.id
 where movie_count > 1
order by actress_rank 
limit 3;


-- Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
-- Director id
-- Name
-- Number of movies
-- Average inter movie duration in days
-- Average movie rating
-- Total votes
-- Min rating
-- Max ratings
-- Total movie duration
use imdb;

select * from director_mapping limit 100;

with top_directors as
(Select name_id as director_id,count(movie_id) as movie_count
from director_mapping group by name_id
order by movie_count desc
limit 9),

movies_summary as
(select b.name_id as director_id,a.*,avg_rating,total_votes
from movies a join director_mapping b
on a.id = b.movie_id
left join rating c
on a.id = c.movie_id
where b.name_id in (select director_id from top_directors)),

final as
(select *, lead(date_published) over (partition by director_id order by date_published) as nxt_movie_date,
datediff(lead(date_published) over (partition by director_id order by date_published),date_published) as days_gap
from movies_summary)

select director_id,b.name as director_name,
count(a.id) as movie_count,
round(avg(days_gap),0) as avg_inter_movie_duration,
round(sum(avg_rating*total_votes)/sum(total_votes),2) as avg_movie_rating,
sum(Total_votes) as total_votes,
min(avg_rating) as min_rating,
max(avg_rating) as max_rating,
sum(duration) as total_duration
from final a
join names b
on a.director_id = b.id
group by director_id,name
order by avg_movie_rating desc;
select id,title,duration,lag(duration,1) over(order by date_published ),duration-lag(duration,1) over(order by date_published ) from movies;

-- Segment 7: Recommendations

-- Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.
-- genre, actors, actress, directors, month during the which they want to make the releas

 
 








   
    









 
 





 

