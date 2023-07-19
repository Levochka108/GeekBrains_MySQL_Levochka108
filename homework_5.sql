-- Клочков Дмитрий
-- Создание представления
CREATE VIEW vw_users_with_age AS
SELECT u.id, u.firstname, u.lastname, u.email, u.phone, p.age
FROM users u
LEFT JOIN profiles p ON u.id = p.user_id;

-- Использование представления
SELECT * FROM vw_users_with_age;

-- Удаление представления
DROP VIEW vw_users_with_age;