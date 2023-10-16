-- 1. Вывести количество фильмов в каждой категории, отсортировать по убыванию.
SELECT category.name AS category_name, COUNT(film_category.film_id) AS film_count
FROM category
LEFT JOIN film_category ON category.category_id = film_category.category_id
GROUP BY category.category_id, category_name
ORDER BY film_count DESC;

-- 2. Вывести 10 актеров, чьи фильмы большего всего арендовали, отсортировать по убыванию.
SELECT 
    actor.first_name,
    actor.last_name,
    COUNT(rental.rental_id) AS rental_count
FROM actor
JOIN film_actor ON actor.actor_id = film_actor.actor_id
JOIN film ON film_actor.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
GROUP BY actor.actor_id, actor.first_name, actor.last_name
ORDER BY rental_count DESC
LIMIT 10;

-- 3. Вывести категорию фильмов, на которую потратили больше всего денег.
SELECT 
    category.name AS category_name,
    SUM(payment.amount) AS total_payment
FROM category
JOIN film_category ON category.category_id = film_category.category_id
JOIN film ON film_category.film_id = film.film_id
JOIN inventory ON film.film_id = inventory.film_id
JOIN rental ON inventory.inventory_id = rental.inventory_id
JOIN payment ON rental.rental_id = payment.rental_id
GROUP BY category.category_id, category_name
ORDER BY total_payment DESC
LIMIT 1;

-- 4. Вывести названия фильмов, которых нет в inventory. Написать запрос без использования оператора IN.
SELECT film.title
FROM film
WHERE 
    NOT EXISTS (
        SELECT 1 
        FROM inventory 
        WHERE film.film_id = inventory.film_id
    );

-- 5. Вывести топ 3 актеров, которые больше всего появлялись в фильмах в категории “Children”. 
-- Если у нескольких актеров одинаковое кол-во фильмов, вывести всех. 
WITH ActorFilmCounts AS (
    SELECT 
        actor.actor_id,
        actor.first_name,
        actor.last_name,
        COUNT(*) AS film_count
    FROM actor
    JOIN film_actor ON actor.actor_id = film_actor.actor_id
    JOIN film_category ON film_actor.film_id = film_category.film_id
    JOIN category ON film_category.category_id = category.category_id
    WHERE category.name = 'Children'
    GROUP BY actor.actor_id, actor.first_name, actor.last_name
)
SELECT 
    actor_id,
    first_name,
    last_name,
    film_count
FROM ActorFilmCounts
ORDER BY film_count DESC
LIMIT 5;

-- 6. Вывести города с количеством активных и неактивных клиентов (активный — customer.active = 1). 
-- Отсортировать по количеству неактивных клиентов по убыванию. 
SELECT 
    city.city_id,
    city.city,
    SUM(CASE WHEN customer.active = 1 THEN 1 ELSE 0 END) AS active_customers,
    SUM(CASE WHEN customer.active = 0 THEN 1 ELSE 0 END) AS inactive_customers
FROM city
LEFT JOIN address ON city.city_id = address.city_id
LEFT JOIN store ON address.address_id = store.address_id
LEFT JOIN customer ON store.store_id = customer.store_id
GROUP BY city.city_id, city.city
ORDER BY inactive_customers DESC;

-- 7.Вывести категорию фильмов, у которой самое большое кол-во часов суммарной аренды в городах (customer.address_id в этом city), 
-- и которые начинаются на букву “a”. То же самое сделать для городов в которых есть символ “-”. Написать все в одном запросе. 
SELECT name, hours_total
FROM (
	SELECT sum(rental_duratiON) as hours_total, name, city
	FROM rental
		INNER JOIN customer ON rental.customer_id = customer.customer_id
		INNER JOIN address ON customer.address_id =  address.address_id
		INNER JOIN city ON address.city_id = city.city_id
		INNER JOIN inventory ON rental.inventory_id = inventory.inventory_id
		INNER JOIN film ON inventory.film_id = film.film_id
		INNER JOIN film_category ON film.film_id = film_category.film_id
		INNER JOIN category ON film_category.category_id = category.category_id
		where city ilike ('a%') and city like ('%-%')
	GROUP BY customer.address_id, name, city
	) as foo
GROUP BY name, hours_total
ORDER BY hours_total DESC
LIMIT 1;