# Dmitrii Klochkov

DROP DATABASE IF EXISTS vk;
CREATE DATABASE vk;
USE vk;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY, 
    firstname VARCHAR(50),
    lastname VARCHAR(50) COMMENT 'Фамиль', -- COMMENT на случай, если имя неочевидное
    email VARCHAR(120) UNIQUE,
 	password_hash VARCHAR(100), -- 123456 => vzx;clvgkajrpo9udfxvsldkrn24l5456345t
	phone BIGINT UNSIGNED UNIQUE, 
	
    INDEX users_firstname_lastname_idx(firstname, lastname)
) COMMENT 'Пользователи';

DROP TABLE IF EXISTS `profiles`;
CREATE TABLE `profiles` (
	user_id BIGINT UNSIGNED NOT NULL UNIQUE,
    gender CHAR(1),
    birthday DATE,
	photo_id BIGINT UNSIGNED NULL,
    created_at DATETIME DEFAULT NOW(),
    hometown VARCHAR(100)
	
    -- , FOREIGN KEY (photo_id) REFERENCES media(id) -- пока рано, т.к. таблицы media еще нет
);

ALTER TABLE `profiles` ADD CONSTRAINT fk_user_id
    FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE -- (значение по умолчанию)
    ON DELETE RESTRICT; -- (значение по умолчанию)

DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id SERIAL, -- SERIAL = BIGINT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE
	from_user_id BIGINT UNSIGNED NOT NULL,
    to_user_id BIGINT UNSIGNED NOT NULL,
    body TEXT,
    created_at DATETIME DEFAULT NOW(), -- можно будет даже не упоминать это поле при вставке

    FOREIGN KEY (from_user_id) REFERENCES users(id),
    FOREIGN KEY (to_user_id) REFERENCES users(id)
)COMMENT 'Сообщения';

DROP TABLE IF EXISTS friend_requests;
CREATE TABLE friend_requests (
	-- id SERIAL, -- изменили на составной ключ (initiator_user_id, target_user_id)
	initiator_user_id BIGINT UNSIGNED NOT NULL,
    target_user_id BIGINT UNSIGNED NOT NULL,
    `status` ENUM('requested', 'approved', 'declined', 'unfriended'), # DEFAULT 'requested',
    -- `status` TINYINT(1) UNSIGNED, -- в этом случае в коде хранили бы цифирный enum (0, 1, 2, 3...)
	requested_at DATETIME DEFAULT NOW(),
	updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP, -- можно будет даже не упоминать это поле при обновлении
	
    PRIMARY KEY (initiator_user_id, target_user_id),
    FOREIGN KEY (initiator_user_id) REFERENCES users(id),
    FOREIGN KEY (target_user_id) REFERENCES users(id)-- ,
    -- CHECK (initiator_user_id <> target_user_id)
)COMMENT 'Пользователи отправляют друг другу добавления в друзья';
-- чтобы пользователь сам себе не отправил запрос в друзья
-- ALTER TABLE friend_requests 
-- ADD CHECK(initiator_user_id <> target_user_id);

DROP TABLE IF EXISTS communities;
CREATE TABLE communities(
	id SERIAL,
	name VARCHAR(150),
	admin_user_id BIGINT UNSIGNED NOT NULL,
	
	INDEX communities_name_idx(name), -- индексу можно давать свое имя (communities_name_idx)
	FOREIGN KEY (admin_user_id) REFERENCES users(id)
)COMMENT 'Таблица сообществ';

DROP TABLE IF EXISTS users_communities;
CREATE TABLE users_communities(
	user_id BIGINT UNSIGNED NOT NULL,
	community_id BIGINT UNSIGNED NOT NULL,
  
	PRIMARY KEY (user_id, community_id), -- чтобы не было 2 записей о пользователе и сообществе
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (community_id) REFERENCES communities(id)
)COMMENT 'Таблица для свезей (связь многие ко многим)';

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL,
    name VARCHAR(255), -- записей мало, поэтому в индексе нет необходимости
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL,
    media_type_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
  	body text,
    filename VARCHAR(255),
    -- file BLOB,    	
    size INT,
	metadata JSON,
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME ON UPDATE CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (media_type_id) REFERENCES media_types(id)
)COMMENT 'Медиа контент';

-- Домбавим таблицу фотоальбомов
DROP TABLE IF EXISTS `photo_albums`;
CREATE TABLE `photo_albums`(
	`id` SERIAL,
    `name` varchar(255),
    `user_id` BIGINT UNSIGNED NOT NULL,
    
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Добавим таблицу фотографий 
DROP TABLE IF EXISTS `photos`;
CREATE TABLE `photos`(
	`id` SERIAL,
    `album_id` BIGINT UNSIGNED,
    `media_id` BIGINT UNSIGNED NOT NULL,
    
    FOREIGN KEY (album_id) REFERENCES photo_albums(id),
    foreign key (media_id) references media(id)
);

DROP TABLE IF EXISTS likes;
CREATE TABLE likes(
	id SERIAL,
    user_id BIGINT UNSIGNED NOT NULL,
    media_id BIGINT UNSIGNED NOT NULL,
    created_at DATETIME DEFAULT NOW()

    -- PRIMARY KEY (user_id, media_id) – можно было и так вместо id в качестве PK
  	-- слишком увлекаться индексами тоже опасно, рациональнее их добавлять по мере необходимости (напр., провисают по времени какие-то запросы)  

/* намеренно забыли, чтобы позднее увидеть их отсутствие в ER-диаграмме
    , FOREIGN KEY (user_id) REFERENCES users(id)
    , FOREIGN KEY (media_id) REFERENCES media(id)
*/
)COMMENT 'Лайки';

-- Добовим таблицу городов
DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
	id SERIAL,
    `name` varchar(255) NOT NULL,
    INDEX (name)
);


-- Возвращение списка имен пользователей без повторений в алфавитном порядке

SELECT DISTINCT firstname
FROM users
ORDER BY firstname;

-- Вывод количества мужчин старше 35 лет

SELECT COUNT(*) AS count
FROM profiles
JOIN users ON profiles.user_id = users.id
WHERE gender = 'M' AND birthday <= DATE_SUB(CURDATE(), INTERVAL 35 YEAR);

-- Подсчет заявок в друзья в каждом статусе

SELECT `status`, COUNT(*) AS count
FROM friend_requests
GROUP BY `status`;



use vk;

INSERT INTO users (id, firstname, lastname, email, phone)
VALUES
(1, 'John', 'Doe', 'john.doe@example.com', '1234567890'),
(2, 'Jane', 'Smith', 'jane.smith@example.com', '0987654321'),
(3, 'Mike', 'Johnson', 'mike.johnson@example.com', '9876543210'),
(4, 'Emily', 'Davis', 'emily.davis@example.com', '0123456789'),
(5, 'David', 'Wilson', 'david.wilson@example.com', '8765432109'),
(6, 'Sarah', 'Taylor', 'sarah.taylor@example.com', '5432109876'),
(7, 'Michael', 'Brown', 'michael.brown@example.com', '9012345678'),
(8, 'Olivia', 'Miller', 'olivia.miller@example.com', '7890123456'),
(9, 'Daniel', 'Anderson', 'daniel.anderson@example.com', '3456789012'),
(10, 'Sophia', 'Thomas', 'sophia.thomas@example.com', '2345678901');


INSERT INTO `likes` VALUES 
('1','1','1','1988-10-14 18:47:39'),
('2','2','1','1988-09-04 16:08:30'),
('3','3','1','1994-07-10 22:07:03'),
('4','4','1','1991-05-12 20:32:08'),
('5','5','2','1978-09-10 14:36:01'),
('6','6','2','1992-04-15 01:27:31'),
('7','7','2','2003-02-03 04:56:27'),
('8','8','8','2017-04-24 09:30:19'),
('9','9','9','1974-02-07 20:53:55'),
('10','10','10','1973-05-11 03:21:40'),
('11','11','11','2008-12-17 13:03:56'),
('12','12','12','1995-07-17 21:22:38'),
('13','13','13','1985-09-07 23:34:21'),
('14','14','14','1973-01-27 23:11:53'); 




-- Добавим полк с идентификатором города
ALTER TABLE profiles ADD COLUMN city_id bigint UNSIGNED;


-- Добавляем флаг is_active
ALTER TABLE vk.profiles 
ADD COLUMN is_active BIT DEFAULT 1;

-- Сделать невовершеннолетних неактивными
UPDATE profiles
SET is_active = 0
WHERE (birthday + INTERVAL 18 YEAR) > NOW();

-- Проверим не активных
select *
from profiles
where is_active = 0
order by birthday;

-- Проверим активных
select *
from profiles
where is_active = 1
order by birthday;


ALTER TABLE vk.likes 
ADD CONSTRAINT likes_fk 
FOREIGN KEY (media_id) REFERENCES vk.media(id);

ALTER TABLE vk.likes 
ADD CONSTRAINT likes_fk_1 
FOREIGN KEY (user_id) REFERENCES vk.users(id);

ALTER TABLE vk.profiles 
ADD CONSTRAINT profiles_fk_1 
FOREIGN KEY (photo_id) REFERENCES media(id);

/* Написать скрипт, удаляющий сообщения «из будущего» (дата позже сегодняшней) */

-- Добавим флаг is_deleted 
ALTER TABLE messages 
ADD COLUMN is_deleted BIT DEFAULT 0;

-- Отметим пару сообщений неправильной датой
update messages
set created_at = now() + interval 1 year
limit 2;

-- Отметим, как удаленные, сообщения "из будущего"
update messages
set is_deleted = 1
where created_at > NOW();

/*
-- физически удалим сообщения "из будущего"
delete from messages
where created_at > NOW()
*/

-- проверим
select *
from messages
order by created_at desc;
