# --- !Ups

DROP TABLE IF EXISTS recipes;

CREATE TABLE IF NOT EXISTS recipes (
    id SERIAL PRIMARY KEY,
    title varchar(100) NOT NULL,
    making_time varchar(100) NOT NULL,
    serves varchar(100) NOT NULL,
    ingredients varchar(300) NOT NULL,
    cost integer NOT NULL,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Trigger to auto-update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_recipes_updated_at BEFORE UPDATE
    ON recipes FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

INSERT INTO recipes (
    id,
    title,
    making_time,
    serves,
    ingredients,
    cost,
    created_at,
    updated_at
)
VALUES (
    1,
    'Chicken Curry',
    '45 min',
    '4 people',
    'onion, chicken, seasoning',
    1000,
    '2016-01-10 12:10:12',
    '2016-01-10 12:10:12'
);

INSERT INTO recipes (
    id,
    title,
    making_time,
    serves,
    ingredients,
    cost,
    created_at,
    updated_at
)
VALUES (
    2,
    'Rice Omelette',
    '30 min',
    '2 people',
    'onion, egg, seasoning, soy sauce',
    700,
    '2016-01-11 13:10:12',
    '2016-01-11 13:10:12'
);

# --- !Downs

DROP TABLE IF EXISTS recipes;