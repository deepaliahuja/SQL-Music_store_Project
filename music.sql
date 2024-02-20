--1. Who is the senior most employee based on the job title?

SELECT concat(first_name,last_name) 
FROM employee 
WHERE lower(title) LIKE '%senior%'

--OR

SELECT concat(first_name,last_name) 
FROM employee 
WHERE title = 'Senior General Manager'

-- OR

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1

-- 2. Which countries have the most invoices?
SELECT billing_country,COUNT(invoice_id)
FROM invoice
GROUP BY billing_country
ORDER BY COUNT(invoice_id) DESC


-- 3. What are the top 3 values of the total invoice?
SELECT total 
FROM invoice
ORDER BY total DESC
LIMIT 3

/* 4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
SELECT billing_city, SUM(total)
FROM invoice
GROUP BY billing_city
ORDER BY SUM(total) DESC


/* 5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT c.customer_id,c.first_name, c.last_name, SUM(i.total) as total_spending
FROM customer c
JOIN invoice i
ON i.customer_id = c.customer_id
GROUP BY c.customer_id
ORDER BY total_spending DESC
LIMIT 1


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT c.email,c.first_name,c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
ORDER BY c.email;


/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
SELECT a.name,COUNT(*) as totaltrack
FROM artist a
JOIN album al ON a.artist_id = al.artist_id
JOIN track t ON t.album_id = al.album_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name = 'Rock'
GROUP BY a.name
ORDER BY totaltrack DESC
LIMIT 10;

SELECT artist.name AS artist_name, COUNT(artist.artist_id) AS number_of_songs
FROM artist
JOIN album
ON album.artist_id = artist.artist_id
JOIN track
ON track.album_id = album.album_id
JOIN genre
ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
GROUP BY artist.name
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */e
SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

select * from artist
select * from customer 
select * from invoice_line

SELECT customer.first_name,customer.last_name,artist.name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
FROM customer
JOIN invoice 
ON invoice.customer_id = customer.customer_id
JOIN invoice_line
ON invoice_line.invoice_id = invoice.invoice_id
JOIN track
ON track.track_id = invoice_line.track_id
JOIN album
ON album.album_id = track.album_id
JOIN artist
ON album.artist_id = artist.artist_id
WHERE artist.name = 'Queen'
GROUP BY customer.customer_id, artist.artist_id
ORDER BY total_sales desc



select customer.customer_id, customer.first_name, customer.last_name, artist.artist_id, artist.name, sum(invoice_line.unit_price) from customer, invoice, invoice_line, track, album, artist
where customer.customer_id = invoice.customer_id
and invoice_line.invoice_id = invoice.invoice_id
and track.track_id = invoice_line.track_id
and album.album_id = track.album_id
and artist.artist_id = album.artist_id
and artist.name = 'Queen'
group by customer.customer_id, artist.artist_id
order by customer.customer_id, artist.name


WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

-- Select COUNT(il.quantity),c.country, g.name ,g.genre_id from customer c
-- join invoice i
-- on i.customer_id=c.customer_id
-- join invoice_line il
-- on il.invoice_id=i.invoice_id
-- join track t
-- on t.track_id=il.track_id
-- join genre g
-- on g.genre_id = t.genre_id 
-- group by c.country,g.name, g.genre_id 
-- having COUNT(il.quantity)
-- order by c.country,COUNT(il.quantity) desc


SELECT COUNT(il.quantity) as genre_count, c.country, g.name as genre_name, g.genre_id 
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN genre g ON g.genre_id = t.genre_id 
GROUP BY c.country, g.name, g.genre_id 
HAVING COUNT(il.quantity) = (
    SELECT MAX(sub_q.genre_count)
    FROM (
        SELECT COUNT(il_sub.quantity) as genre_count
        FROM customer c_sub
        JOIN invoice i_sub ON i_sub.customer_id = c_sub.customer_id
        JOIN invoice_line il_sub ON il_sub.invoice_id = i_sub.invoice_id
        JOIN track t_sub ON t_sub.track_id = il_sub.track_id
        JOIN genre g_sub ON g_sub.genre_id = t_sub.genre_id 
        WHERE c_sub.country = c.country
        GROUP BY g_sub.name, g_sub.genre_id
    ) as sub_q
)
ORDER BY c.country, genre_count DESC;


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo = 1


/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

WITH customer_with_country AS (
		SELECT customer.customer_id,first_name,last_name,country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM customer_with_country WHERE RowNo = 1

--Q12: determines the customer that has spent the most on music
select c.first_name, c.last_name,c.customer_id, sum(total)
from customer c 
join
invoice i
on i.customer_id = c.customer_id
group by c.customer_id
order by sum(total) desc
limit 1


