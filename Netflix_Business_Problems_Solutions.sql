select * from netflix;

select count(*) as total_content from netflix;

select distinct type from netflix;

-- Business problems --

--Q1. Count the number of Movies vs the TV Shows

select 
	type, count(*) as total_content
from netflix
group by type;

--Q2. Find the most common rating for movies and tv shows

select
	type,
	rating,
	count_of_rating
from
(
	select 
		type, 
		rating, 
		count(rating) as count_of_rating,
		rank() over(partition by type order by count(rating) desc) as ranking
	from netflix
	group by type, rating
)
where ranking = 1;

--Q3. List all the movies released in a specific year (e.g. - 2020)

select
	title
from netflix
where type = 'Movie' and release_year = 2020;

--Q4. Find the top 5 countries with the most content on Netflix

select
	trim(unnest(string_to_array(country,','))) as new_country,
	count(show_id) as total_content
from netflix
group by 1
order by 2 desc
limit 5;

--Q5. Identify the longest movie.

select * from netflix
where 
	type = 'Movie'
	and
	regexp_replace(duration, '[^\d]', '', 'g')::int = (
		select max(regexp_replace(duration, '[^\d]', '', 'g')::int)
		from netflix
		where type = 'Movie');
			   
--Q6. Find content released in the last 5 years

select * from netflix
where release_year in (
	select distinct release_year from netflix
	order by release_year desc
	limit 5);
	
--Q7. Find content added in the last 5 years

select * from netflix
where
	to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

--Q8. Find all the TV Shows/ Movies directed by 'Rajiv Chilaka'

select * from netflix
where director ilike '%rajiv chilaka%';

--Q9. List all the TV Shows with more than 5 seasons

select * from netflix
where 
	type = 'TV Show'
	and
	split_part(duration, ' ', 1)::numeric > 5;
	
--Q10. Count the number of content items in each genre

select 
	trim(unnest(string_to_array(listed_in, ','))) as genre,
	count(show_id) as content_count
from netflix
group by genre;

--Q11. Find each year and the average number of contents released by India on netflix.
--	   Return the top 5 year with highest average content release!

select 
	extract(year from to_date(date_added, 'Month DD, YYYY')) as year,
	count(*) as content_count,
	round(count(*)::numeric/(select count(*) from netflix where country ilike '%india%')::numeric*100, 2) as avg_content 
from netflix
where country ilike '%india%'
group by 1;

--Q11. List all the movies that are documentaries.

select title, listed_in from netflix
where 
	type = 'Movie' 
	and
	listed_in ilike '%documentaries%';

--Q12. Find all the content without a director.

select * from netflix
where director is null;

--Q13. Find in how many movies, actor 'Salman Khan' appeared in the last 10 years.

select * from netflix
where
	casts ilike '%salman khan%'
	and
	release_year > extract(year from current_date) - 10;

--Q14. Find the top 10 actors who have appeared in the highest number of movies produced in India

select 
	trim(unnest(string_to_array(casts, ','))) as cast_name,
	count(*) as shows_count
from netflix
where country ilike '%india%'
group by 1
order by 2 desc
limit 10;

--Q15. Categorize the contents based on the presence of the keywords 'kill' and 'violence' in the
--     description field. Label content containing these keywords as 'Bad' an all other content as 
--	   'Good'. Count how many items fall into each category.

with new_netflix_table as (
select 
	*,
	case 
	when 
		description ilike '%kill%'
		or
		description ilike '%violence%'
	then 'bad content'
	else 'good content'
	end category
from netflix)
select category, count(category) as total_content from new_netflix_table
group by 1