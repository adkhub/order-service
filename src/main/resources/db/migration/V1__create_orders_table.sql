-- V1__create_orders_table.sql
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    description VARCHAR(255),
    confirmed BOOLEAN NOT NULL,
    created_at TIMESTAMP,
    shipping_id VARCHAR(255)
);