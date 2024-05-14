CREATE TABLE public.cats (
	id_cat uuid NULL DEFAULT uuid_generate_v4(),
	"name" int8 NOT NULL GENERATED ALWAYS AS IDENTITY
);

CREATE OR REPLACE FUNCTION insert_cats_data(mb_volume integer) RETURNS void AS $$
DECLARE
    total_bytes bigint;
    cat_size bigint;
    cats_to_insert integer;
    i integer := 0;
BEGIN
    -- Вычисляем общий объем данных в байтах
    total_bytes := mb_volume * 1048576; -- 1024 * 1024 = 1048576
    
    -- Вычисляем размер записи в таблице cats
    SELECT pg_column_size('cats') INTO cat_size;
    -- Вычисляем количество записей, которые нужно вставить
    cats_to_insert := total_bytes / cat_size;

        -- Вставляем записи в цикле
        WHILE i < cats_to_insert LOOP
            -- Вставляем запись
            INSERT INTO public.cats DEFAULT VALUES;
            i := i + 1;
        END LOOP;
        
        -- Выводим количество вставленных строк
        RAISE NOTICE 'Вставлено % строк в таблицу', i;
END;
$$ LANGUAGE plpgsql;

 
SELECT insert_cats_data (1); 

select * from cats