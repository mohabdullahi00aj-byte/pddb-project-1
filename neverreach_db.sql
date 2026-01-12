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
-- Database: `neverreach_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `delivery_assignments`
--

CREATE TABLE `delivery_assignments` (
  `assignment_id` int(11) NOT NULL,
  `driver_id` int(11) DEFAULT NULL,
  `package_id` int(11) DEFAULT NULL,
  `assigned_date` date DEFAULT NULL,
  `delivery_status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `delivery_assignments`
--

INSERT INTO `delivery_assignments` (`assignment_id`, `driver_id`, `package_id`, `assigned_date`, `delivery_status`) VALUES
(1, 1, 1, '2025-06-22', 'Dispatched'),
(2, 1, 2, '2025-06-22', 'In Transit');

-- --------------------------------------------------------

--
-- Table structure for table `delivery_tracking`
--

CREATE TABLE `delivery_tracking` (
  `tracking_id` int(11) NOT NULL,
  `package_id` int(11) DEFAULT NULL,
  `status_update_time` datetime DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `status_note` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `delivery_tracking`
--

INSERT INTO `delivery_tracking` (`tracking_id`, `package_id`, `status_update_time`, `location`, `status_note`) VALUES
(1, 1, '2025-06-22 09:30:00', 'Rest Stop A', 'Package checked and scanned'),
(2, 2, '2025-06-22 10:45:00', 'Checkpoint B', 'On-time delivery status');

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `employee_id` int(11) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `position` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `phone_number` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`employee_id`, `name`, `position`, `email`, `phone_number`) VALUES
(1, 'Amira Yusuf', 'Driver', 'amira@delivery.com', '0123456789'),
(2, 'John Lee', 'Manager', 'john@delivery.com', '0198877665');

-- --------------------------------------------------------

--
-- Table structure for table `packages`
--

CREATE TABLE `packages` (
  `package_id` int(11) NOT NULL,
  `shipment_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `weight` decimal(6,2) DEFAULT NULL,
  `dimensions` varchar(50) DEFAULT NULL,
  `fragile_flag` tinyint(1) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `packages`
--

INSERT INTO `packages` (`package_id`, `shipment_id`, `order_id`, `weight`, `dimensions`, `fragile_flag`) VALUES
(1, 1, 101, 4.50, '40x30x20', 1),
(2, 1, 102, 2.00, '30x20x10', 0);

-- --------------------------------------------------------

--
-- Table structure for table `shipments`
--

CREATE TABLE `shipments` (
  `shipment_id` int(11) NOT NULL,
  `origin_warehouse_id` int(11) DEFAULT NULL,
  `destination_warehouse_id` int(11) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `departure_time` datetime DEFAULT NULL,
  `arrival_time` datetime DEFAULT NULL,
  `status` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `shipments`
--

INSERT INTO `shipments` (`shipment_id`, `origin_warehouse_id`, `destination_warehouse_id`, `address`, `departure_time`, `arrival_time`, `status`) VALUES
(1, 1, 2, '123 Delivery Street, Penang', '2025-06-22 08:00:00', '2025-06-22 18:00:00', 'In Transit');

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `vehicle_id` int(11) NOT NULL,
  `license_plate` varchar(20) DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `assigned_driver_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`vehicle_id`, `license_plate`, `type`, `capacity`, `assigned_driver_id`) VALUES
(1, 'VAN1234', 'Van', 500, 1),
(2, 'TRK5678', 'Truck', 1000, 1);

-- --------------------------------------------------------

--
-- Table structure for table `warehouses`
--

CREATE TABLE `warehouses` (
  `warehouse_id` int(11) NOT NULL,
  `location` varchar(100) DEFAULT NULL,
  `capacity` int(11) DEFAULT NULL,
  `manager_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `warehouses`
--

INSERT INTO `warehouses` (`warehouse_id`, `location`, `capacity`, `manager_id`) VALUES
(1, 'Kuala Lumpur Hub', 1000, 2),
(2, 'Penang Depot', 800, 2);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `delivery_assignments`
--
ALTER TABLE `delivery_assignments`
  ADD PRIMARY KEY (`assignment_id`),
  ADD KEY `driver_id` (`driver_id`),
  ADD KEY `package_id` (`package_id`);

--
-- Indexes for table `delivery_tracking`
--
ALTER TABLE `delivery_tracking`
  ADD PRIMARY KEY (`tracking_id`),
  ADD KEY `package_id` (`package_id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`employee_id`);

--
-- Indexes for table `packages`
--
ALTER TABLE `packages`
  ADD PRIMARY KEY (`package_id`),
  ADD KEY `shipment_id` (`shipment_id`);

--
-- Indexes for table `shipments`
--
ALTER TABLE `shipments`
  ADD PRIMARY KEY (`shipment_id`),
  ADD KEY `origin_warehouse_id` (`origin_warehouse_id`),
  ADD KEY `destination_warehouse_id` (`destination_warehouse_id`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`vehicle_id`),
  ADD KEY `assigned_driver_id` (`assigned_driver_id`);

--
-- Indexes for table `warehouses`
--
ALTER TABLE `warehouses`
  ADD PRIMARY KEY (`warehouse_id`),
  ADD KEY `manager_id` (`manager_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `delivery_assignments`
--
ALTER TABLE `delivery_assignments`
  ADD CONSTRAINT `delivery_assignments_ibfk_1` FOREIGN KEY (`driver_id`) REFERENCES `employees` (`employee_id`),
  ADD CONSTRAINT `delivery_assignments_ibfk_2` FOREIGN KEY (`package_id`) REFERENCES `packages` (`package_id`);

--
-- Constraints for table `delivery_tracking`
--
ALTER TABLE `delivery_tracking`
  ADD CONSTRAINT `delivery_tracking_ibfk_1` FOREIGN KEY (`package_id`) REFERENCES `packages` (`package_id`);

--
-- Constraints for table `packages`
--
ALTER TABLE `packages`
  ADD CONSTRAINT `packages_ibfk_1` FOREIGN KEY (`shipment_id`) REFERENCES `shipments` (`shipment_id`);

--
-- Constraints for table `shipments`
--
ALTER TABLE `shipments`
  ADD CONSTRAINT `shipments_ibfk_1` FOREIGN KEY (`origin_warehouse_id`) REFERENCES `warehouses` (`warehouse_id`),
  ADD CONSTRAINT `shipments_ibfk_2` FOREIGN KEY (`destination_warehouse_id`) REFERENCES `warehouses` (`warehouse_id`);

--
-- Constraints for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD CONSTRAINT `vehicles_ibfk_1` FOREIGN KEY (`assigned_driver_id`) REFERENCES `employees` (`employee_id`);

--
-- Constraints for table `warehouses`
--
ALTER TABLE `warehouses`
  ADD CONSTRAINT `warehouses_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `employees` (`employee_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
