-- =============================================
-- 删除 resume 和 resume_module 表的外键约束
-- 执行方式: 在 MySQL 客户端中 source drop_foreign_keys.sql
-- =============================================

DELIMITER //

DROP PROCEDURE IF EXISTS `drop_table_foreign_keys`//

CREATE PROCEDURE `drop_table_foreign_keys`(IN p_table_name VARCHAR(64))
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_constraint_name VARCHAR(64);

    DECLARE cur CURSOR FOR
        SELECT CONSTRAINT_NAME
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND CONSTRAINT_TYPE = 'FOREIGN KEY';

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_constraint_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @sql = CONCAT('ALTER TABLE `', p_table_name, '` DROP FOREIGN KEY `', v_constraint_name, '`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        SELECT CONCAT('已删除外键: ', p_table_name, '.', v_constraint_name) AS result;
    END LOOP;

    CLOSE cur;
END//

DELIMITER ;

-- 删除 resume 表的外键
CALL `drop_table_foreign_keys`('resume');

-- 删除 resume_module 表的外键
CALL `drop_table_foreign_keys`('resume_module');

-- 清理存储过程
DROP PROCEDURE IF EXISTS `drop_table_foreign_keys`;
