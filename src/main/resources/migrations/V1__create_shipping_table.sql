-- V1__create_shipping_table.sql
CREATE TABLE shipping (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    address VARCHAR(255),
    status VARCHAR(100),
    shipped_at TIMESTAMP,
    order_id UUID
);
