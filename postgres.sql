[Monday 3:59 PM] Binh IT. Nguyen Thanh
CREATE TABLE IF NOT EXISTS hungpq7 (
    user_id serial PRIMARY KEY,
    username VARCHAR ( 50 ) UNIQUE NOT NULL,
    password VARCHAR ( 50 ) NOT NULL,
    email VARCHAR ( 255 ) UNIQUE NOT NULL
);
insert into hungpq7 values (1, 'hungpq','hungpede','hungpq7@techcombank.com.vn');