
-- Создание таблиц
CREATE TABLE different_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR UNIQUE
);

CREATE TABLE entries (
    id SERIAL PRIMARY KEY,
    type_id INT REFERENCES different_types(id),
    data JSONB
);

-- Функция для добавления нового типа
CREATE OR REPLACE FUNCTION add_type(type_name VARCHAR) RETURNS VOID AS $$
BEGIN
    INSERT INTO different_types (name) VALUES (type_name);
END;
$$ LANGUAGE plpgsql;

-- Функция для добавления записи в справочник
CREATE OR REPLACE FUNCTION add_entry(type_name VARCHAR, entry_data JSONB) RETURNS VOID AS $$
DECLARE
    type_id INT;
BEGIN
    -- Получаем ID типа
    SELECT id INTO type_id FROM different_types WHERE name = type_name;
    
    -- Если тип не существует, добавляем новый
    IF NOT FOUND THEN
        INSERT INTO different_types (name) VALUES (type_name) RETURNING id INTO type_id;
    END IF;
    
    -- Добавляем запись
    INSERT INTO entries (type_id, data) VALUES (type_id, entry_data);
END;
$$ LANGUAGE plpgsql;


-- Добавляем тип "employees" и записи для него
SELECT add_type('employees');
SELECT add_entry('employees', '{"name": "Kevin Mitnic", "age": 59, "position": "Developer"}');
SELECT add_entry('employees', '{"name": "pepe frog", "age": 25, "position": "Junior meme developer"}');

-- Добавляем тип "departments" и записи для него
SELECT add_type('departments');
SELECT add_entry('departments', '{"name": "HR", "location": "там где нас нет"}');
SELECT add_entry('departments', '{"name": "IT", "location": "remote"}');

-- для просмотра jsonb можно использовать представление
CREATE OR REPLACE VIEW entry_data_view AS
SELECT 
    id AS entry_id,
    type_id,
    data->>'name' AS name,
    (data->>'age')::int AS age,
    data->>'position' AS position
FROM 
    entries;
