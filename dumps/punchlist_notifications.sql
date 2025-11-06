-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: punchlist
-- ------------------------------------------------------
-- Server version	8.0.43-0ubuntu0.24.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `actor_user_id` int DEFAULT NULL,
  `type` varchar(64) NOT NULL,
  `entity_type` varchar(32) DEFAULT NULL,
  `entity_id` bigint unsigned DEFAULT NULL,
  `title` varchar(200) DEFAULT NULL,
  `body` text,
  `data` json DEFAULT NULL,
  `url` varchar(512) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `read_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_created` (`user_id`,`created_at`),
  KEY `idx_user_unread` (`user_id`,`is_read`,`created_at`),
  KEY `idx_entity` (`entity_type`,`entity_id`,`type`),
  KEY `fk_notif_actor` (`actor_user_id`),
  KEY `idx_notif_user_read` (`user_id`,`is_read`,`id`),
  CONSTRAINT `fk_notif_actor` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_notif_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,1,NULL,'note.shared',NULL,NULL,'Test notification','Hello from test.php at 2025-10-30 18:57:51',NULL,NULL,1,'2025-10-30 17:58:28','2025-10-30 18:57:51'),(4,1,2,'note.shared',NULL,NULL,'A note was shared with you','“test567” 2025-11-02 — shared by ermin@abrm.com','{\"by\": \"ermin@abrm.com\", \"note_id\": 8, \"actor_core_user_id\": 6}','/notes/view.php?id=8',1,'2025-11-02 22:18:28','2025-11-02 22:17:16'),(5,1,2,'note.shared',NULL,NULL,'A note was shared with you','“elvir notification” 2025-11-03 — shared by ermin@abrm.com','{\"by\": \"ermin@abrm.com\", \"note_id\": 9, \"actor_core_user_id\": 6}','/notes/view.php?id=9',1,'2025-11-02 23:10:53','2025-11-02 23:10:37'),(6,2,1,'note.comment',NULL,NULL,'New reply on “elvir notification”','Test','{\"note_id\": 9, \"comment_id\": 5}','/notes/view.php?id=9#comment-5',0,NULL,'2025-11-03 01:10:22'),(7,1,2,'note.shared',NULL,NULL,'A note was shared with you','“hhahahaa” 2025-11-03 — shared by ermin@abrm.com','{\"by\": \"ermin@abrm.com\", \"note_id\": 10, \"actor_core_user_id\": 6}','/notes/view.php?id=10',1,'2025-11-03 10:16:20','2025-11-03 10:11:49'),(8,2,1,'note.comment',NULL,NULL,'New reply on “hhahahaa”','tetstt','{\"note_id\": 10, \"comment_id\": 6}','/notes/view.php?id=10#comment-6',0,NULL,'2025-11-03 10:12:38'),(9,2,1,'note.shared',NULL,NULL,'A note was shared with you','“test ermin sharing” 2025-11-03 — shared by elvir@abrm.com','{\"by\": \"elvir@abrm.com\", \"note_id\": 11}','/notes/view.php?id=11',0,NULL,'2025-11-03 10:15:51'),(10,2,1,'note.shared',NULL,NULL,'A note was shared with you','“tetettststst” 2025-11-03 — shared by elvir@abrm.com','{\"by\": \"elvir@abrm.com\", \"note_id\": 12}','/notes/view.php?id=12',0,NULL,'2025-11-03 10:39:15'),(11,8,1,'note.shared',NULL,NULL,'A note was shared with you','“tetettststst” 2025-11-03 — shared by elvir@abrm.com','{\"by\": \"elvir@abrm.com\", \"note_id\": 12}','/notes/view.php?id=12',1,'2025-11-03 10:40:14','2025-11-03 10:39:15');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-04  9:26:55
