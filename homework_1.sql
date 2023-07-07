/* Создайте таблицу с мобильными телефонами, 
используя графический интерфейс. 
Необходимые поля таблицы: 
product_name (название товара), 
manufacturer (производитель), 
product_count (количество), 
price (цена). 
Заполните БД произвольными данными.*/

SELECT * 
FROM levochka108_local_geekbrains.mobile_phone_table;

/*
# Напишите SELECT-запрос, который выводит название товара, производителя и цену для товаров, количество которых превышает 2
select manufacturer, price
from levochka108_local_geekbrains.mobile_phone_table
WHERE product_count > 2;
*/

/*
SELECT *
FROM levochka108_local_geekbrains.mobile_phone_table
WHERE product_name LIKE '%Samsung%';
*/

/*
select id, product_name, manufacturer, product_count, price
from levochka108_local_geekbrains.mobile_phone_table
where id = 10;
*/

/*
SELECT *
FROM levochka108_local_geekbrains.mobile_phone_table
WHERE product_name REGEXP '8';
*/

