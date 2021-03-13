#How many copies of the film Hunchback Impossible exist in the inventory system?
select f.film_id as Film_ID, f.title as Title, count(i.inventory_id) as Inventory
from sakila.inventory as i
join (select film_id, title from sakila.film
where title = 'Hunchback Impossible') as f
on f.film_id = i.film_id
group by Film_ID;


#List all films whose length is longer than the average of all the films.
select film.title, film.length from sakila.film
where film.length > (select avg(film.length)
from sakila.film)
order by film.length desc;


#Use subqueries to display all actors who appear in the film Alone Trip.
select f.film_id as Film_ID, f.title as Title, a.actor_id, a.actor_name
from sakila.film_actor as fa
join (select film_id, title from sakila.film
        where title = 'Alone Trip') as f
on f.film_id = fa.film_id
join (select actor_id, concat(first_name, ' ', last_name) as actor_name from sakila.actor) as a
on a.actor_id = fa.actor_id
group by f.film_id, f.title, a.actor_id;


#Identify all movies categorized as family films.
select fc.category_id, c.name, f.film_id as Film_ID, f.title as Title
from sakila.film as f
join (select film_id, category_id from sakila.film_category) as fc
on f.film_id = fc.film_id
join (select category_id, name from sakila.category
	   where name = 'Family') as c
on c.category_id = fc.category_id
group by fc.category_id, c.name, f.film_id, f.title;


#Get name and email from customers from Canada using subqueries. Do the same with joins. 
#Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, 
#that will help you get the relevant information.
select CONCAT(cu.first_name, '', cu.last_name) as CustumerName, cu.email
from sakila.customer as cu
join (select address_id, city_id from sakila.address) as a
on cu.address_id = a.address_id
join (select city_id, country_id from sakila.city) as ci
on a.city_id = ci.city_id
join (select country_id, country from sakila.country
	where country = 'Canada') as co
on ci.country_id = co.country_id;


#Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. 
#First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
select title, (
	SELECT CONCAT(a.first_name, ' ', a.last_name) as ActorName
	FROM sakila.actor as a
	JOIN (
		SELECT actor_id, count(film_id) from film_actor
        GROUP BY actor_id
		ORDER BY count(film_id) DESC
        LIMIT 1) as fa
	ON a.actor_id = fa.actor_id) sub1
from sakila.film;

select fa.actor_id, a.first_name, a.last_name, count(fa.film_id) as films_acted
from sakila.film_actor as fa
join sakila.actor as a
on fa.actor_id = a.actor_id
group by fa.actor_id, a.first_name
order by films_acted desc
limit 20;


select f.film_id, f.title, a.actor_id, concat(a.first_name, ' ', a.last_name) as actor_name
from sakila.film as f
join sakila.film_actor as fa
on f.film_id = fa.film_id
join sakila.actor as a
on a.actor_id = fa.actor_id
where a.actor_id = (
    select actor_id from (
    select a.actor_id, count(fa.film_id) as films_acted
    from sakila.film_actor as fa
    join sakila.actor as a
    on fa.actor_id = a.actor_id
    group by fa.actor_id, a.first_name
    order by films_acted desc
    limit 1) sub1
);


#Films rented by most profitable customer. 
#You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments

select title, CustomerName from sakila.film as f
join (select inventory_id, film_id from sakila.inventory) as i
ON i.film_id = f.film_id
join (select rental_id, inventory_id from sakila.rental) as r
ON i.inventory_id = r.inventory_id
join (select CONCAT(c.first_name, ' ', c.last_name) as CustomerName
from sakila.customer as c
JOIN (SELECT customer_id, max(totality) as spent
FROM (select customer_id, sum(amount) as totality
from sakila.payment
group by customer_id) as g
group by customer_id
order by max(totality) desc
Limit 1) as r
ON r.customer_id = c.customer_id) as c
group by title, CustomerName;


select f.film_id, f.title, p.customer_id, concat(c.first_name, ' ', c.last_name) as customer_name
from sakila.payment as p
join sakila.rental as r
on p.rental_id = r.rental_id
join sakila.customer as c
on r.customer_id = c.customer_id
join sakila.inventory as i
on r.inventory_id = i.inventory_id
join sakila.film as f
on f.film_id = i.film_id
where p.customer_id = (  #select only actor_id in subquery. Use =  instead of in
    select customer_id from (
    select p.customer_id, sum(p.amount) as total_amount_spent
	from sakila.payment as p
	group by p.customer_id
	order by sum(p.amount) desc
	limit 1) sub1
);

#Customers who spent more than the average payments.
select concat(c.first_name, ' ', c.last_name) as customer_name, sum(p.amount) as spent_more_than_average
from sakila.payment as p
join sakila.rental as r
on p.rental_id = r.rental_id
join sakila.customer as c
on r.customer_id = c.customer_id
group by customer_name
having sum(p.amount) > (  #select only actor_id in subquery. Use =  instead of in
    select avg(average_amount_spent) from (
    select sum(p.amount) as average_amount_spent
	from sakila.payment as p
    group by p.customer_id
	) sub1
);
