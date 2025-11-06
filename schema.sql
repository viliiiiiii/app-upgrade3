CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','user') NOT NULL DEFAULT 'admin',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE buildings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE rooms (
  id INT AUTO_INCREMENT PRIMARY KEY,
  building_id INT NOT NULL,
  room_number VARCHAR(50) NOT NULL,
  label VARCHAR(190) NULL,
  sector_id INT NULL,
  floor_label VARCHAR(50) NULL,
  capacity INT NULL,
  notes TEXT NULL,
  UNIQUE KEY(building_id, room_number),
  FOREIGN KEY (building_id) REFERENCES buildings(id) ON DELETE CASCADE
);

CREATE TABLE tasks (
  id INT AUTO_INCREMENT PRIMARY KEY,
  building_id INT NOT NULL,
  room_id INT NOT NULL,
  title VARCHAR(190) NOT NULL,
  description TEXT NULL,
  priority ENUM('', 'low','low/mid','mid','mid/high','high') NOT NULL DEFAULT '',
  assigned_to VARCHAR(190) NULL,
  status ENUM('open','in_progress','done') NOT NULL DEFAULT 'open',
  due_date DATE NULL,
  created_by INT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (building_id) REFERENCES buildings(id) ON DELETE RESTRICT,
  FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE RESTRICT
);

CREATE TABLE task_photos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  task_id INT NOT NULL,
  s3_key VARCHAR(255) NOT NULL,
  url VARCHAR(500) NOT NULL,
  position TINYINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY(task_id, position),
  FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
);

CREATE TABLE notifications (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  actor_user_id INT NULL,
  type VARCHAR(64) NOT NULL,
  entity_type VARCHAR(64) NULL,
  entity_id BIGINT NULL,
  title VARCHAR(190) NULL,
  body TEXT NULL,
  data JSON NULL,
  url VARCHAR(255) NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  read_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_notifications_user (user_id, id),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE notification_devices (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  kind VARCHAR(32) NOT NULL,
  endpoint VARCHAR(255) NOT NULL,
  user_agent VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_used_at DATETIME NULL,
  UNIQUE KEY uniq_notification_device (user_id, kind, endpoint),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE notification_type_prefs (
  user_id INT NOT NULL,
  notif_type VARCHAR(64) NOT NULL,
  allow_web TINYINT(1) NOT NULL DEFAULT 1,
  allow_email TINYINT(1) NOT NULL DEFAULT 0,
  allow_push TINYINT(1) NOT NULL DEFAULT 0,
  mute_until DATETIME NULL,
  PRIMARY KEY (user_id, notif_type),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE notification_subscriptions (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  entity_type VARCHAR(64) NULL,
  entity_id BIGINT NULL,
  event VARCHAR(64) NOT NULL,
  channels VARCHAR(50) NOT NULL DEFAULT 'web',
  is_enabled TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uniq_notif_subscription (user_id, entity_type, entity_id, event),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

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
  INDEX idx_movements_item_ts (item_id, ts)
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
  INDEX idx_movement_files (movement_id, uploaded_at)
);
