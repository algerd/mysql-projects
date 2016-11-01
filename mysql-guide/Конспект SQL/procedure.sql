-- Хранимые процедуры - это сохранённый объект логических и иных выражений, запросов и т.д. Аналогичен подпрограмме include в php, но с заданием параметров в () как в function. В отличие от SQL VIEW хранит не один запрос а сколько угодно во всевозможных логических комбинациях.
-- Для вывода всех результатов запросов, а не одного, содержащихся в прцедуре надо использовать в php модуль MySQLI и работать через него.
-- Но лучше составлять процедуру так, чтобы она имела только 1 результат селекта

--Фактически хранимые процедуры - это программы по которым выполняются запросы и которые хранятся в базе данных сервера.

--Создание процедуры с двумя результатами выполнения (крайне не рекомендуется)
DELIMITER |     -- создаём знак | выполнения команды (только для консолей, для php не надо как и не надо ;)
DROP PROCEDURE IF EXISTS sp_sample_1 |
CREATE PROCEDURE sp_sample_1()
	BEGIN
		SELECT 'Список преподавателей' AS ' ';    -- 1-й результат - только его выполнит стандартный модуль php MySQL - модуль
		SELECT name FROM teachers ORDER BY name;  -- 2-й результат
	END;
|
DELIMITER ; -- возвращаем знак ; выполнения команды

--Вызов процедуры
CALL sp_sample_1();



-- Классическое создание процедуры с заданием параметров и получением 1-го результата селекта
DELIMITER | 
DROP PROCEDURE IF EXISTS sp_course_by_date |
CREATE PROCEDURE sp_course_by_date(IN teacher_id INT, IN course_date DATE) -- задание входных(IN) параметров (локальных переменных) с обязательным указанием типа (глобальные задаются собачкой). Желательно для себя придумать значок (напр loc_ тогда будет loc_teacher_id) с которого будут начинаться все локальные переменные.
BEGIN 
	SELECT courses.id, course.title
		FROM courses
			INNER JOIN lessons.lesson_date = course_date
		WHERE lessons.lesson_date = course_date
		AND lessons.teacher = teacher_id;
END;
|
DELIMITER ;

-- Вызов этой процедуры
CALL sp_course_by_date(1, '2006-09-15');



--Создание процедуры с 1-м основным результатом-запросом и 2-м в выходной переменной record_count(тоже локальной)
--Какие и сколько занятий было в указанный промежуток времени
DELIMITER |
DROP PROCEDURE IF EXISTS sp_course_dates |
CREATE PROCEDURE sp_course_dates
	(IN date_start DATE, IN date_END, OUT record_count INT)
	BEGIN
		--Создадим временную таблицу с результатами запроса
		CREATE TEMPORARY TABLE course_by_dates_results
			SELECT courses.id, courses.title
				FROM courses
					INNER JOIN lessons ON courses.id = lessons.course
				WHERE lessons.lesson_date BETWEEN date_start AND date_end;
		--Посчитаем сколько в ней записей в переменную
		SELECT COUNT(*) INTO record_counts; -- результат селекта заносится (INTO) в переменную record_counts
			FROM course_by_dates_results;
		[--Вернём результат
		SELECT *
			FROM course_by_dates_results;]
		
		--Проверим сколько записей удалось выбрать
		IF record_counts = 0 THEN
			--данных нет, вернём предупреждающую таблицу
			SELECT 0 AS id, 'Данных нет' AS title;
		ELSE
			--вернём результат
			SELECT *
				FROM course_by_dates_results;
		END IF;
									
		--Удалим временную таблицу
		DROP TEMPORARY TABLE course_by_dates_results;
	END;
|
DELIMITER ;

-- Вызов этой процедуры
CALL sp_course_dates('2006-09-15', '2006-09-25', @count);
SELECT @count;

--Создание в процедуре локальных переменных
CREATE PROCEDURE sp1 (IN x VARCHAR(5))
	BEGIN 
		DECLARE xname VARCHAR(5) DEFAULT 'bob' -- создали xname = 'bob'(значение по умолчанию)
		DECLARE newname VARCHAR(5);
		DECLARE xid INT;
		SET xid = 5; -- присвоение значения переменной
		
		SELECT xname, id INTO newname, xid --присвоение переменным newname, xid результатов запроса SELECT
			FROM table1 WHERE xname = xname;
		SELECT newname;
	END;	

**********************************************************************************************************
-- Функции в отличие от процедур возвращают одно скалярное значение ретурном.
-- Функции не могут содержать ссылки на таблицы (SELECT ... FROM ...)

DELIMITER |
CREATE FUNCTION test(loc_abc VARCHAR(10)) -- указываются локальные переменные с указанием типа, в отличие от процедур без IN,OUT потому что функция возвращает значение ретурном
	RETURNS (VARCHAR(20)); -- тип данных результата функции
	BEGIN
		[тело функции]
		RETURN CONCAT('Hello ', loc_abc);
	END;
|
DELIMITER ;

-- Вызов функции
SELECT test('мир!'); --выведет табличку со значением в поле test('мир!') - Hello мир!

***********************************************************************************************************

--Управляющие конструкции в хранимых процедурах


--IF
IF [условие] THEN [запрос];
ELSE [запрос];
END IF;


--CASE
CASE [переменная]
	WHEN [значение1 переменной] THEN [выражение];
	WHEN [значение2 переменной] THEN [выражение];
	WHEN [значениеN переменной] THEN [выражение];
	ELSE [выражение];
END CASE;


--LOOP -безусловный цикл (останавливается с помощью LEAVE(аналог BREAK в php))
-- с помощью ITERATE переходит на следующий шаг цикла (аналог CONTINUE в php)
LOOP
	[выражение];	
END LOOP;

--Пример
CREATE PROCEDURE sp_d(p1 INT)
BEGIN
	label1: LOOP --начало цикла с меткой начала label1
		SET p1 = p1 + 1;
		IF p1 < 10 THEN ITERATE label1;
		END IF;
		LEAVE label1;
	END LOOP label1;
	SET @x = p1;
END

	
-- REPEAT - цикл с постусловием. Сначало выполняется выражение а потом проверяется условие. (аналг DO WHILE в php)
-- Цикл прекращает работу если условие выполняется, т.е. работает пока условие ЛОЖНО
REPEAT [выражение];
UNTIL [условие]
END REPEAT;

CREATE PROCEDURE sp_d(p1 INT)
BEGIN
	SET @x = 0;
	REPEAT SET @x = @x + 1;
	UNTIL @x > p1 END REPEAT;
END

SELECT @x; -- выдаст в поле @x значение 1001


-- WHILE - цикл с предусловием, аналог такого же в php
-- Работает пока условие ИСТИННО
WHILE [условие] DO [выражение]
END WHILE

CREATE PROCEDURE sp_d()
BEGIN
	DECLARE v1 INT DEFAULT 5;
	WHILE v1 > 0 DO
		SET v1 = v1 - 1;
	END WHILE;
END

********************************************************
-- ТРИГГЕРЫ - для сохранения целостности связанных таблиц запускаются триггеры (автоматические хранимые процедуры), которые автоматически модифицируют связанные таблицы при попытке модификации данных в одной из них.
-- Все производимые ими модификации рассматриваются как транзакции и в случае обнаружения ошибки происходит откат транзакции
-- Момент запуска триггера определяются ключевыми словами:
BEFORE -- триггер запускается до выполнения связанного с ним события (напр добавления данных)
AFTER -- после события

-- Комплексный пример 

CREATE TABLE test1(
	a1 INT);
CREATE TABLE test2(
	a2 INT NOT NULL AUTO_INCREMENT PRIMARY KEY);
CREATE TABLE test4(
	a4 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	b4 INT DEFAULT 0);
	
--Создаём триггер
DELIMITER |
CREATE TRIGGER testref BEFORE INSERT ON test1 FOR EACH ROW -- триггер будет запускаться перед (BEFORE) каждым добавлением данных в таблицу test1
	BEGIN 
		INSERT INTO test2 SET a2 = NEW.a1;
		DELETE FROM test3 WHERE a3 = NEW.a1;
		UPDATE test4 SET b4 = b4 + 1 WHERE a4 = NEW.a1;
	END;
|
DELIMITER ;

--Вызываем триггер
INSERT INTO test1 VALUES (1), (3), (1), (2), (1)
		














