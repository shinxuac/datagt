/*
	Código obtenido en: https://www.inkeysolutions.com/blogs/sql-server-find-a-specific-value-in-all-tables-of-a-database-using-t-sql/
	Modificado por: Victor Joaquin Morales
*/

-- Seleccionar base de datos
USE NORTHWIND
GO

--Let’s create temp tables that will store the value of tablenames and columnnames in which the specified value is found.
--temp table to store table name and column name from database
CREATE TABLE #tempTableColumn 
(
    Table_Name VARCHAR(100),
    Column_Name VARCHAR(100)
)

--temp table for storing final output
CREATE TABLE #tempTableFinal 
(
    Table_Name VARCHAR(100),
    Column_Name VARCHAR(100),
    SearchedValue NVARCHAR(max) --datatype of the value
)

--Set the value that needs to be searched in the database
DECLARE @SearchValue NVARCHAR(max) = 'rnst'	-- VALOR A BUSCAR

--Set the datatype of the value that needs to be searched in the database
DECLARE @DataType VARCHAR(50) = 'NVARCHAR'

--Set the schema of the tables that needs to be searched in the database
DECLARE @Schema VARCHAR(50) = 'dbo'


--To store all table names and columns having datatype as of searchvalue to be used for looping
INSERT INTO #tempTableColumn 
SELECT 
    CONCAT(COL.Table_Schema,CONCAT('.',QUOTENAME(COL.TABLE_NAME))) AS TABLE_NAME,
    COL.COLUMN_NAME
FROM 
    INFORMATION_SCHEMA.COLUMNS COL
WHERE 
    Data_Type IN (@DataType)
AND COL.Table_Schema = @schema


--Declare variables for storing the output
DECLARE 
    @Table_name VARCHAR(100),
    @Column_name VARCHAR(100);


--Create Cursor for looping through the above table
DECLARE temp_cursor CURSOR FOR
SELECT 
    TABLE_NAME,
    COLUMN_NAME
FROM 
    #tempTableColumn 
 
OPEN temp_cursor 
FETCH NEXT FROM temp_cursor
INTO @Table_name,@Column_name
 
PRINT 'Table_Name Column_Name'


--Declare variable for storing SQL query string
DECLARE @SQL NVARCHAR(max);  

WHILE @@FETCH_STATUS = 0
BEGIN
--Creating SQL Query to check the search value in each table and each column from the temporary table that we created
--Here, we are creating query to search the exact value; use LIKE to find the approximate value
SET @SQL = 'SELECT '''+@Table_Name+''' AS'+'''Table_Name'''+', '''+ @Column_Name+'''AS'+'''Column_Name'''+' ,'+@Column_Name+ ' FROM '+@Table_Name+
' WHERE '+@Column_name + ' like ''%'+@SearchValue+'%'''


PRINT @SQL
INSERT INTO #tempTableFinal
EXECUTE sp_executesql @SQL
 

FETCH NEXT FROM temp_cursor
INTO @table_name,@Column_name 
END

 
SELECT * FROM #tempTableFinal


CLOSE temp_cursor;

DEALLOCATE temp_cursor;

DROP TABLE #tempTableColumn
DROP TABLE #tempTableFinal