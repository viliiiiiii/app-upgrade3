CREATE TABLE inventory_items (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(100) UNIQUE,
  name VARCHAR(200) NOT NULL,
  sector_id INT NULL,
  quantity INT NOT NULL DEFAULT 0,
  location VARCHAR(120) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE inventory_movements (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_id BIGINT NOT NULL,
  direction ENUM('in','out') NOT NULL,
  amount INT NOT NULL,
  reason VARCHAR(200) NULL,
  user_id INT NULL,
  source_sector_id INT NULL,
  target_sector_id INT NULL,
  source_location VARCHAR(120) NULL,
  target_location VARCHAR(120) NULL,
  requires_signature TINYINT(1) NOT NULL DEFAULT 1,
  transfer_status ENUM('pending','signed') NOT NULL DEFAULT 'pending',
  transfer_form_key VARCHAR(255) NULL,
  transfer_form_url TEXT NULL,
  notes TEXT NULL,
  ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (item_id) REFERENCES inventory_items(id),
  INDEX (item_id, ts)
);

CREATE TABLE inventory_movement_files (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  movement_id BIGINT NOT NULL,
  file_key VARCHAR(255) NOT NULL,
  file_url TEXT NOT NULL,
  mime VARCHAR(120) NULL,
  label VARCHAR(120) NULL,
  kind ENUM('signature','photo','other') NOT NULL DEFAULT 'signature',
  uploaded_by INT NULL,
  uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (movement_id) REFERENCES inventory_movements(id) ON DELETE CASCADE,
  INDEX (movement_id, uploaded_at)
);
