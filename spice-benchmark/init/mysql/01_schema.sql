CREATE TABLE IF NOT EXISTS customer_profiles (
  customer_id INT PRIMARY KEY,
  segment VARCHAR(32) NOT NULL,
  loyalty_points INT NOT NULL
);

CREATE TABLE IF NOT EXISTS payments (
  payment_id INT PRIMARY KEY,
  customer_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  method VARCHAR(32) NOT NULL,
  payment_date DATE NOT NULL
);

INSERT IGNORE INTO customer_profiles (customer_id, segment, loyalty_points) VALUES
  (1, 'enterprise', 1200),
  (2, 'mid_market', 800),
  (3, 'startup', 450),
  (4, 'public', 300);

INSERT IGNORE INTO payments (payment_id, customer_id, amount, method, payment_date) VALUES
  (5001, 1, 250.00, 'card', '2025-01-10'),
  (5002, 1, 125.00, 'wire', '2025-01-11'),
  (5003, 2, 300.00, 'card', '2025-01-12'),
  (5004, 2, 200.00, 'wire', '2025-01-12'),
  (5005, 3, 320.00, 'card', '2025-01-13');
