-- Заполнение данными

CREATE TABLE IF NOT EXISTS employees (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    salary INTEGER
);

INSERT INTO employees (name, salary)
VALUES 
    ('John Doe', 3500),
    ('Jane Smith', 5000),
    ('Alice Johnson', 2500),
    ('Bob Brown', 4000),
    ('Charlie White', 6000);

GRANT ALL PRIVILEGES ON TABLE employees TO jobe_user;