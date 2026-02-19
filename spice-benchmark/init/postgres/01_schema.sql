CREATE TABLE IF NOT EXISTS customers (
  customer_id INT PRIMARY KEY,
  customer_name TEXT NOT NULL,
  country TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
  order_id INT PRIMARY KEY,
  customer_id INT NOT NULL REFERENCES customers(customer_id),
  total_amount NUMERIC(12,2) NOT NULL,
  order_date DATE NOT NULL
);

INSERT INTO customers (customer_id, customer_name, country) VALUES
  (1, 'Acme Corp', 'US'),
  (2, 'Globex', 'ES'),
  (3, 'Initech', 'US'),
  (4, 'Umbrella', 'MX')
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO orders (order_id, customer_id, total_amount, order_date) VALUES
  (1001, 1, 250.00, '2025-01-10'),
  (1002, 1, 125.00, '2025-01-11'),
  (1003, 2, 500.00, '2025-01-12'),
  (1004, 3, 320.00, '2025-01-13'),
  (1005, 4, 90.00, '2025-01-14')
ON CONFLICT (order_id) DO NOTHING;
