/*1. Who is the Senior most employee based on job title?*/
select top 1 * from employee order by levels desc

/*2. which countries has the most invoices?*/
select count(*) as c, billing_country from [dbo].[invoice] 
group by billing_country order by c desc

/*3. What are top 3 values of total invoice?*/
Select top 3 total FROM Invoice order by total desc



/*4. Which city has the best customers? we would like to throw a promotional Music festival in the city 
 we made the most money . Write a query  that returns one city that has  the highest sum of invoice totals.
 Return both the city name  & sum of all invoice totals*/
select billing_city, Sum(total) as Total from [dbo].[invoice] group by billing_city order by Total desc

/*5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT TOP 1 
 c.customer_id,
c.first_name, 
c.last_name, 
    SUM(i.total) AS Total 
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY Total DESC;


/*WAQ to return the email, firstname, last name & genre of all ROck music listeners.
Return your list ordered alphabetically by email starting with A*/


SELECT DISTINCT c.first_name, c.last_name, c.email from customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line ON i.invoice_id = invoice_line.invoice_id
WHERE track_id IN
(
	select track_id From track t
	JOIN genre g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
order by email




/*Lets's invite the artists who have written the most rock music in our dataset.
WAQ that returns the artist name & total track count of the top 10 rock bands.*/


SELECT TOP 10 
    artist.artist_id, 
    artist.name, 
    COUNT(artist.artist_id) AS Numberofsongs
FROM 
    track
JOIN 
    album ON album.album_id = track.album_id
JOIN 
    artist ON artist.artist_id = album.artist_id
JOIN 
    genre ON genre.genre_id = track.genre_id
WHERE 
    genre.name LIKE 'Rock'
GROUP BY 
    artist.artist_id, 
    artist.name
ORDER BY 
    Numberofsongs DESC;





/*Return all the track names that have a song length than the average song length.
Return the name & milliseconds for each track. 
Order by the song length with the longest songs listed first.*/

Select name, milliseconds FROM track
Where milliseconds >
(
SELECT AVG(CAST(milliseconds AS FLOAT)) AS Avg_track_length
FROM track
)
ORDER BY milliseconds desc



/*Find how much amount spent by each customer on artists?
WAQ to return customer name, artist name & total spent

group by 1 --- group by artist_id
order by 3 --- order by sales

*/


WITH best_selling_artist AS (
    SELECT TOP 1
        artist.artist_id AS artist_id, 
        artist.name AS artist_name, 
        SUM(CAST(invoice_line.unit_price AS DECIMAL) * CAST(invoice_line.quantity AS INT)) AS total_sales
    FROM 
        invoice_line
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        album ON album.album_id = track.album_id
    JOIN 
        artist ON artist.artist_id = album.artist_id
    GROUP BY 
        artist.artist_id, artist.name
    ORDER BY 
        total_sales DESC
)
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    bsa.artist_name, 
    SUM(CAST(il.unit_price AS DECIMAL) * CAST(il.quantity AS INT)) AS amount_spent
FROM 
    invoice i
JOIN 
    customer c ON c.customer_id = i.customer_id
JOIN 
    invoice_line il ON il.invoice_id = i.invoice_id
JOIN 
    track t ON t.track_id = il.track_id
JOIN 
    album alb ON alb.album_id = t.album_id
JOIN 
    best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 
    c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 
    amount_spent DESC;





/*We want to find out the most popular music genre for each country.
We determine the most poplular genre as the genre with the highest amount of purchases.
WAQ that returns each country along with the top Genre.
For countries where the maximum number of purchases is shared return all genres.*/


WITH popular_genre AS 
(
    SELECT 
        COUNT(invoice_line.quantity) AS purchases, 
        customer.country, 
        genre.name, 
        genre.genre_id, 
        ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM 
        invoice_line 
    JOIN 
        invoice ON invoice.invoice_id = invoice_line.invoice_id
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    JOIN 
        track ON track.track_id = invoice_line.track_id
    JOIN 
        genre ON genre.genre_id = track.genre_id
    GROUP BY 
        customer.country, genre.name, genre.genre_id
)
SELECT 
    * 
FROM 
    popular_genre 
WHERE 
    RowNo = 1
ORDER BY 
    country ASC, purchases DESC;









/*WQA that determines the customer that has spent the most on music for each country.
WAQ that returns the country along with the top customer & how much they spent. For countries where the top amount spent is shared,
provide all customers who spent this amount*/


WITH Customer_with_country AS (
    SELECT 
        customer.customer_id,
        first_name,
        last_name,
        billing_country,
        SUM(total) AS total_spending,
        ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
    FROM 
        invoice
    JOIN 
        customer ON customer.customer_id = invoice.customer_id
    GROUP BY 
        customer.customer_id, first_name, last_name, billing_country
)
SELECT 
    * 
FROM 
    Customer_with_country 
WHERE 
    RowNo = 1
ORDER BY 
    billing_country ASC, total_spending DESC;
