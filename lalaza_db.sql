-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 22, 2025 at 02:59 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `lalaza_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `address`
--

CREATE TABLE `address` (
  `address_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `additional_info` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `address`
--

INSERT INTO `address` (`address_id`, `user_id`, `address`, `additional_info`) VALUES
(1, 1, 'Apartment 22, Cityview', 'Near Mall'),
(2, 2, 'No.10 Jalan Mega, KL', 'Opposite Market');

-- --------------------------------------------------------

--
-- Table structure for table `cart`
--

CREATE TABLE `cart` (
  `cart_id` int(11) NOT NULL,
  `purchase_id` int(11) DEFAULT NULL,
  `item_id` int(11) DEFAULT NULL,
  `qty` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `cart`
--

INSERT INTO `cart` (`cart_id`, `purchase_id`, `item_id`, `qty`) VALUES
(1, 1, 1, 1),
(2, 1, 2, 1);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `category_title` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `category_title`) VALUES
(1, 'Electronics'),
(2, 'Books'),
(3, 'Audio');

-- --------------------------------------------------------

--
-- Table structure for table `items`
--

CREATE TABLE `items` (
  `item_id` int(11) NOT NULL,
  `title` varchar(100) DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `weight` decimal(5,2) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `quantity_available` int(11) DEFAULT NULL,
  `shipping_fee` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `items`
--

INSERT INTO `items` (`item_id`, `title`, `summary`, `weight`, `category_id`, `unit_price`, `quantity_available`, `shipping_fee`) VALUES
(1, 'Tablet', 'Android tablet', 0.60, 1, 899.99, 80, 15.00),
(2, 'Novel', 'Mystery thriller', 0.30, 2, 49.99, 150, 5.00);

-- --------------------------------------------------------

--
-- Table structure for table `promocodes`
--

CREATE TABLE `promocodes` (
  `promo_code` varchar(20) NOT NULL,
  `promo_id` int(11) DEFAULT NULL,
  `minimum_purchase` decimal(10,2) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `redeemed` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promocodes`
--

INSERT INTO `promocodes` (`promo_code`, `promo_id`, `minimum_purchase`, `start_date`, `end_date`, `redeemed`) VALUES
('FLAT20', 2, 100.00, '2025-06-15', '2025-07-15', 0),
('SUMMER10', 1, 500.00, '2025-06-01', '2025-06-30', 1);

-- --------------------------------------------------------

--
-- Table structure for table `promotions`
--

CREATE TABLE `promotions` (
  `promo_id` int(11) NOT NULL,
  `promo_name` varchar(100) DEFAULT NULL,
  `discount_type` varchar(50) DEFAULT NULL,
  `discount_value` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `promotions`
--

INSERT INTO `promotions` (`promo_id`, `promo_name`, `discount_type`, `discount_value`) VALUES
(1, 'Summer Sale', 'percentage', 10.00),
(2, 'Flat Discount', 'fixed', 20.00);

-- --------------------------------------------------------

--
-- Table structure for table `purchases`
--

CREATE TABLE `purchases` (
  `purchase_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `purchase_timestamp` datetime DEFAULT NULL,
  `subtotal` decimal(10,2) DEFAULT NULL,
  `delivery_charge` decimal(10,2) DEFAULT NULL,
  `promo_code` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `purchases`
--

INSERT INTO `purchases` (`purchase_id`, `user_id`, `purchase_timestamp`, `subtotal`, `delivery_charge`, `promo_code`) VALUES
(1, 1, '2025-06-20 14:35:00', 949.98, 20.00, 'SUMMER10');

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `txn_id` int(11) NOT NULL,
  `purchase_ref` int(11) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `txn_date` date DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`txn_id`, `purchase_ref`, `payment_method`, `txn_date`, `amount`) VALUES
(1, 1, 'Paypal', '2025-06-20', 969.98);

-- --------------------------------------------------------

--
-- Table structure for table `userpromotions`
--

CREATE TABLE `userpromotions` (
  `user_id` int(11) NOT NULL,
  `promo_id` int(11) NOT NULL,
  `promo_code` varchar(20) DEFAULT NULL,
  `redeemed` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `userpromotions`
--

INSERT INTO `userpromotions` (`user_id`, `promo_id`, `promo_code`, `redeemed`) VALUES
(1, 1, 'SUMMER10', 1),
(2, 2, 'FLAT20', 0);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `email_address` varchar(100) DEFAULT NULL,
  `mobile` varchar(15) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `name`, `email_address`, `mobile`, `address`) VALUES
(1, 'Fatima Noor', 'fatima@example.com', '0133344556', 'Apartment 22, Cityview'),
(2, 'Ali Hassan', 'ali.hassan@example.com', '0171122334', 'No.10 Jalan Mega, KL');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `address`
--
ALTER TABLE `address`
  ADD PRIMARY KEY (`address_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `cart`
--
ALTER TABLE `cart`
  ADD PRIMARY KEY (`cart_id`),
  ADD KEY `purchase_id` (`purchase_id`),
  ADD KEY `item_id` (`item_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`item_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `promocodes`
--
ALTER TABLE `promocodes`
  ADD PRIMARY KEY (`promo_code`),
  ADD KEY `promo_id` (`promo_id`);

--
-- Indexes for table `promotions`
--
ALTER TABLE `promotions`
  ADD PRIMARY KEY (`promo_id`);

--
-- Indexes for table `purchases`
--
ALTER TABLE `purchases`
  ADD PRIMARY KEY (`purchase_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `promo_code` (`promo_code`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`txn_id`),
  ADD KEY `purchase_ref` (`purchase_ref`);

--
-- Indexes for table `userpromotions`
--
ALTER TABLE `userpromotions`
  ADD PRIMARY KEY (`user_id`,`promo_id`),
  ADD KEY `promo_id` (`promo_id`),
  ADD KEY `promo_code` (`promo_code`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `address`
--
ALTER TABLE `address`
  ADD CONSTRAINT `address_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`);

--
-- Constraints for table `cart`
--
ALTER TABLE `cart`
  ADD CONSTRAINT `cart_ibfk_1` FOREIGN KEY (`purchase_id`) REFERENCES `purchases` (`purchase_id`),
  ADD CONSTRAINT `cart_ibfk_2` FOREIGN KEY (`item_id`) REFERENCES `items` (`item_id`);

--
-- Constraints for table `items`
--
ALTER TABLE `items`
  ADD CONSTRAINT `items_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`);

--
-- Constraints for table `promocodes`
--
ALTER TABLE `promocodes`
  ADD CONSTRAINT `promocodes_ibfk_1` FOREIGN KEY (`promo_id`) REFERENCES `promotions` (`promo_id`);

--
-- Constraints for table `purchases`
--
ALTER TABLE `purchases`
  ADD CONSTRAINT `purchases_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `purchases_ibfk_2` FOREIGN KEY (`promo_code`) REFERENCES `promocodes` (`promo_code`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`purchase_ref`) REFERENCES `purchases` (`purchase_id`);

--
-- Constraints for table `userpromotions`
--
ALTER TABLE `userpromotions`
  ADD CONSTRAINT `userpromotions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  ADD CONSTRAINT `userpromotions_ibfk_2` FOREIGN KEY (`promo_id`) REFERENCES `promotions` (`promo_id`),
  ADD CONSTRAINT `userpromotions_ibfk_3` FOREIGN KEY (`promo_code`) REFERENCES `promocodes` (`promo_code`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
