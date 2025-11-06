-- Core governance database schema
CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  key_slug VARCHAR(50) UNIQUE NOT NULL,
  label VARCHAR(80) NOT NULL
);

CREATE TABLE sectors (
  id INT AUTO_INCREMENT PRIMARY KEY,
  key_slug VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(80) NOT NULL,
  description TEXT NULL,
  contact_email VARCHAR(190) NULL,
  contact_phone VARCHAR(60) NULL,
  color_hex CHAR(7) NULL,
  manager_user_id INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(190) UNIQUE NOT NULL,
  pass_hash VARCHAR(255) NOT NULL,
  role_id INT NOT NULL,
  sector_id INT NULL,
  notification_email VARCHAR(190) NULL,
  suspended_at DATETIME NULL,
  suspended_by INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id),
  FOREIGN KEY (sector_id) REFERENCES sectors(id)
);

CREATE TABLE permissions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  key_slug VARCHAR(64) UNIQUE NOT NULL,
  label VARCHAR(120) NOT NULL,
  description VARCHAR(255) NULL
);

CREATE TABLE role_permissions (
  role_id INT NOT NULL,
  permission_key VARCHAR(64) NOT NULL,
  granted TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (role_id, permission_key),
  FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  FOREIGN KEY (permission_key) REFERENCES permissions(key_slug) ON DELETE CASCADE
);

CREATE TABLE user_permissions (
  user_id INT NOT NULL,
  permission_key VARCHAR(64) NOT NULL,
  granted TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (user_id, permission_key),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (permission_key) REFERENCES permissions(key_slug) ON DELETE CASCADE
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
  INDEX idx_notifications_type (type),
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

CREATE TABLE activity_log (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  ts DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  user_id INT NULL,
  action VARCHAR(64) NOT NULL,
  entity_type VARCHAR(32) NULL,
  entity_id BIGINT NULL,
  meta JSON NULL,
  ip VARBINARY(16) NULL,
  ua VARCHAR(255) NULL,
  INDEX (ts),
  INDEX (user_id),
  INDEX (action)
);

INSERT IGNORE INTO roles (key_slug, label) VALUES
  ('viewer', 'Viewer'),
  ('admin', 'Admin'),
  ('root', 'Root');

INSERT IGNORE INTO sectors (key_slug, name) VALUES
  ('fo', 'FO'),
  ('technical', 'Technical'),
  ('it', 'IT');

INSERT IGNORE INTO permissions (key_slug, label, description) VALUES
  ('view', 'View data', 'View dashboard, tasks, rooms and read-only pages'),
  ('download', 'Download exports', 'Download PDFs, CSVs and other exports'),
  ('edit', 'Edit core data', 'Edit tasks, rooms, and shared resources'),
  ('inventory_manage', 'Manage inventory', 'Create inventory items and record movements'),
  ('manage_users', 'Manage users', 'Create, update, and suspend user accounts'),
  ('manage_sectors', 'Manage sectors', 'Create and update sectors'),
  ('manage_rooms', 'Manage rooms', 'Create and maintain building room directory'),
  ('inventory_transfers', 'Sign inventory transfers', 'Upload signed transfer paperwork and attachments'),
  ('notifications_admin', 'Manage notifications', 'Adjust notification defaults and deliverability');

INSERT IGNORE INTO role_permissions (role_id, permission_key, granted)
SELECT r.id, p.key_slug, 1
FROM roles r
JOIN permissions p ON (
  (r.key_slug = 'viewer'    AND p.key_slug IN ('view','download')) OR
  (r.key_slug = 'admin'     AND p.key_slug IN ('view','download','edit','inventory_manage','manage_rooms','inventory_transfers')) OR
  (r.key_slug = 'root')
);
