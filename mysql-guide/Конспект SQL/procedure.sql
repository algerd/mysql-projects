-- �������� ��������� - ��� ���������� ������ ���������� � ���� ���������, �������� � �.�. ���������� ������������ include � php, �� � �������� ���������� � () ��� � function. � ������� �� SQL VIEW ������ �� ���� ������ � ������� ������ �� ������������ ���������� �����������.
-- ��� ������ ���� ����������� ��������, � �� ������, ������������ � �������� ���� ������������ � php ������ MySQLI � �������� ����� ����.
-- �� ����� ���������� ��������� ���, ����� ��� ����� ������ 1 ��������� �������

--���������� �������� ��������� - ��� ��������� �� ������� ����������� ������� � ������� �������� � ���� ������ �������.

--�������� ��������� � ����� ������������ ���������� (������ �� �������������)
DELIMITER |     -- ������ ���� | ���������� ������� (������ ��� ��������, ��� php �� ���� ��� � �� ���� ;)
DROP PROCEDURE IF EXISTS sp_sample_1 |
CREATE PROCEDURE sp_sample_1()
	BEGIN
		SELECT '������ ��������������' AS ' ';    -- 1-� ��������� - ������ ��� �������� ����������� ������ php MySQL - ������
		SELECT name FROM teachers ORDER BY name;  -- 2-� ���������
	END;
|
DELIMITER ; -- ���������� ���� ; ���������� �������

--����� ���������
CALL sp_sample_1();



-- ������������ �������� ��������� � �������� ���������� � ���������� 1-�� ���������� �������
DELIMITER | 
DROP PROCEDURE IF EXISTS sp_course_by_date |
CREATE PROCEDURE sp_course_by_date(IN teacher_id INT, IN course_date DATE) -- ������� �������(IN) ���������� (��������� ����������) � ������������ ��������� ���� (���������� �������� ��������). ���������� ��� ���� ��������� ������ (���� loc_ ����� ����� loc_teacher_id) � �������� ����� ���������� ��� ��������� ����������.
BEGIN 
	SELECT courses.id, course.title
		FROM courses
			INNER JOIN lessons.lesson_date = course_date
		WHERE lessons.lesson_date = course_date
		AND lessons.teacher = teacher_id;
END;
|
DELIMITER ;

-- ����� ���� ���������
CALL sp_course_by_date(1, '2006-09-15');



--�������� ��������� � 1-� �������� �����������-�������� � 2-� � �������� ���������� record_count(���� ���������)
--����� � ������� ������� ���� � ��������� ���������� �������
DELIMITER |
DROP PROCEDURE IF EXISTS sp_course_dates |
CREATE PROCEDURE sp_course_dates
	(IN date_start DATE, IN date_END, OUT record_count INT)
	BEGIN
		--�������� ��������� ������� � ������������ �������
		CREATE TEMPORARY TABLE course_by_dates_results
			SELECT courses.id, courses.title
				FROM courses
					INNER JOIN lessons ON courses.id = lessons.course
				WHERE lessons.lesson_date BETWEEN date_start AND date_end;
		--��������� ������� � ��� ������� � ����������
		SELECT COUNT(*) INTO record_counts; -- ��������� ������� ��������� (INTO) � ���������� record_counts
			FROM course_by_dates_results;
		[--����� ���������
		SELECT *
			FROM course_by_dates_results;]
		
		--�������� ������� ������� ������� �������
		IF record_counts = 0 THEN
			--������ ���, ����� ��������������� �������
			SELECT 0 AS id, '������ ���' AS title;
		ELSE
			--����� ���������
			SELECT *
				FROM course_by_dates_results;
		END IF;
									
		--������ ��������� �������
		DROP TEMPORARY TABLE course_by_dates_results;
	END;
|
DELIMITER ;

-- ����� ���� ���������
CALL sp_course_dates('2006-09-15', '2006-09-25', @count);
SELECT @count;

--�������� � ��������� ��������� ����������
CREATE PROCEDURE sp1 (IN x VARCHAR(5))
	BEGIN 
		DECLARE xname VARCHAR(5) DEFAULT 'bob' -- ������� xname = 'bob'(�������� �� ���������)
		DECLARE newname VARCHAR(5);
		DECLARE xid INT;
		SET xid = 5; -- ���������� �������� ����������
		
		SELECT xname, id INTO newname, xid --���������� ���������� newname, xid ����������� ������� SELECT
			FROM table1 WHERE xname = xname;
		SELECT newname;
	END;	

**********************************************************************************************************
-- ������� � ������� �� �������� ���������� ���� ��������� �������� ��������.
-- ������� �� ����� ��������� ������ �� ������� (SELECT ... FROM ...)

DELIMITER |
CREATE FUNCTION test(loc_abc VARCHAR(10)) -- ����������� ��������� ���������� � ��������� ����, � ������� �� �������� ��� IN,OUT ������ ��� ������� ���������� �������� ��������
	RETURNS (VARCHAR(20)); -- ��� ������ ���������� �������
	BEGIN
		[���� �������]
		RETURN CONCAT('Hello ', loc_abc);
	END;
|
DELIMITER ;

-- ����� �������
SELECT test('���!'); --������� �������� �� ��������� � ���� test('���!') - Hello ���!

***********************************************************************************************************

--����������� ����������� � �������� ����������


--IF
IF [�������] THEN [������];
ELSE [������];
END IF;


--CASE
CASE [����������]
	WHEN [��������1 ����������] THEN [���������];
	WHEN [��������2 ����������] THEN [���������];
	WHEN [��������N ����������] THEN [���������];
	ELSE [���������];
END CASE;


--LOOP -����������� ���� (��������������� � ������� LEAVE(������ BREAK � php))
-- � ������� ITERATE ��������� �� ��������� ��� ����� (������ CONTINUE � php)
LOOP
	[���������];	
END LOOP;

--������
CREATE PROCEDURE sp_d(p1 INT)
BEGIN
	label1: LOOP --������ ����� � ������ ������ label1
		SET p1 = p1 + 1;
		IF p1 < 10 THEN ITERATE label1;
		END IF;
		LEAVE label1;
	END LOOP label1;
	SET @x = p1;
END

	
-- REPEAT - ���� � ������������. ������� ����������� ��������� � ����� ����������� �������. (����� DO WHILE � php)
-- ���� ���������� ������ ���� ������� �����������, �.�. �������� ���� ������� �����
REPEAT [���������];
UNTIL [�������]
END REPEAT;

CREATE PROCEDURE sp_d(p1 INT)
BEGIN
	SET @x = 0;
	REPEAT SET @x = @x + 1;
	UNTIL @x > p1 END REPEAT;
END

SELECT @x; -- ������ � ���� @x �������� 1001


-- WHILE - ���� � ������������, ������ ������ �� � php
-- �������� ���� ������� �������
WHILE [�������] DO [���������]
END WHILE

CREATE PROCEDURE sp_d()
BEGIN
	DECLARE v1 INT DEFAULT 5;
	WHILE v1 > 0 DO
		SET v1 = v1 - 1;
	END WHILE;
END

********************************************************
-- �������� - ��� ���������� ����������� ��������� ������ ����������� �������� (�������������� �������� ���������), ������� ������������� ������������ ��������� ������� ��� ������� ����������� ������ � ����� �� ���.
-- ��� ������������ ��� ����������� ��������������� ��� ���������� � � ������ ����������� ������ ���������� ����� ����������
-- ������ ������� �������� ������������ ��������� �������:
BEFORE -- ������� ����������� �� ���������� ���������� � ��� ������� (���� ���������� ������)
AFTER -- ����� �������

-- ����������� ������ 

CREATE TABLE test1(
	a1 INT);
CREATE TABLE test2(
	a2 INT NOT NULL AUTO_INCREMENT PRIMARY KEY);
CREATE TABLE test4(
	a4 INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	b4 INT DEFAULT 0);
	
--������ �������
DELIMITER |
CREATE TRIGGER testref BEFORE INSERT ON test1 FOR EACH ROW -- ������� ����� ����������� ����� (BEFORE) ������ ����������� ������ � ������� test1
	BEGIN 
		INSERT INTO test2 SET a2 = NEW.a1;
		DELETE FROM test3 WHERE a3 = NEW.a1;
		UPDATE test4 SET b4 = b4 + 1 WHERE a4 = NEW.a1;
	END;
|
DELIMITER ;

--�������� �������
INSERT INTO test1 VALUES (1), (3), (1), (2), (1)
		














