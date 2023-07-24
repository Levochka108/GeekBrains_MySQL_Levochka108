  -- Дмитрий Клочков
USE vk;
-- Задача 1
DELIMITER $$

CREATE FUNCTION delete_user(user_id_to_delete BIGINT UNSIGNED) RETURNS BIGINT UNSIGNED DETERMINISTIC
BEGIN
    DECLARE user_to_delete_id BIGINT UNSIGNED;
    
    -- Находим пользователя по ID для последующего возврата
    SELECT id INTO user_to_delete_id FROM users WHERE id = user_id_to_delete;
    
    -- Удаляем все сообщения пользователя
    DELETE FROM messages WHERE from_user_id = user_id_to_delete OR to_user_id = user_id_to_delete;
    
    -- Удаляем все лайки пользователя
    DELETE FROM likes WHERE user_id = user_id_to_delete;
    
    -- Удаляем все медиа записи пользователя
    DELETE FROM media WHERE user_id = user_id_to_delete;
    
    -- Удаляем профиль пользователя
    DELETE FROM profiles WHERE user_id = user_id_to_delete;
    
    -- Удаляем запись пользователя из таблицы users
    DELETE FROM users WHERE id = user_id_to_delete;
    
    -- Возвращаем ID удаленного пользователя
    RETURN user_to_delete_id;
END $$

DELIMITER ;

SET @@global.log_bin_trust_function_creators = 1;

-- Задача 2

DELIMITER $$

CREATE PROCEDURE delete_user_procedure(IN user_id_to_delete BIGINT UNSIGNED, OUT deleted_user_id BIGINT UNSIGNED)
BEGIN
    -- Объявляем переменную для хранения ID удаленного пользователя
    DECLARE user_to_delete_id BIGINT UNSIGNED;
    
    -- Начинаем транзакцию
    START TRANSACTION;
    
    -- Находим пользователя по ID для последующего возврата
    SELECT id INTO user_to_delete_id FROM users WHERE id = user_id_to_delete;
    
    -- Если пользователь не найден, откатываем транзакцию и завершаем процедуру
    IF user_to_delete_id IS NULL THEN
        ROLLBACK;
        SET deleted_user_id = NULL;
    ELSE
        -- Удаляем все сообщения пользователя
        DELETE FROM messages WHERE from_user_id = user_id_to_delete OR to_user_id = user_id_to_delete;
        
        -- Удаляем все лайки пользователя
        DELETE FROM likes WHERE user_id = user_id_to_delete;
        
        -- Удаляем все медиа записи пользователя
        DELETE FROM media WHERE user_id = user_id_to_delete;
        
        -- Удаляем профиль пользователя
        DELETE FROM profiles WHERE user_id = user_id_to_delete;
        
        -- Удаляем запись пользователя из таблицы users
        DELETE FROM users WHERE id = user_id_to_delete;
        
        -- Фиксируем изменения в базе данных
        COMMIT;
        
        -- Возвращаем ID удаленного пользователя
        SET deleted_user_id = user_to_delete_id;
    END IF;
END $$

DELIMITER ;

CALL delete_user_procedure(3, @deleted_user_id);




