-- MySQL IT_3400-701 TEAM 1 FINAL PROJECT 2025

-- Step 1: Create the database

-- Create Investco database
CREATE DATABASE IF NOT EXISTS Investco;

-- Use Investco database
USE Investco;

-- Create Security table
CREATE TABLE IF NOT EXISTS Security (
    security_id CHAR(2) PRIMARY KEY,
    security_name VARCHAR(100) NOT NULL,
    security_type VARCHAR(50) NOT NULL
);

-- Create InvestmentCompany table
CREATE TABLE IF NOT EXISTS InvestmentCompany (
    inv_company_id CHAR(3) PRIMARY KEY,
    CONSTRAINT chk_inv_company_id_length CHECK (LENGTH(inv_company_id) = 3),
    inv_company_name VARCHAR(100) NOT NULL UNIQUE,
    ceo_first_name VARCHAR(50) NOT NULL,
    ceo_last_name VARCHAR(50) NOT NULL  -- Fixed: Made consistent naming
);

-- Create MutualFund table
CREATE TABLE IF NOT EXISTS MutualFund (
    mf_id CHAR(2) PRIMARY KEY,
    mf_name VARCHAR(100) NOT NULL,
    mf_incorp_date DATE NOT NULL,
    mf_iccompany_id CHAR(3) NOT NULL,
    FOREIGN KEY (mf_iccompany_id) REFERENCES InvestmentCompany(inv_company_id)
);

-- Create InvColocation table
CREATE TABLE IF NOT EXISTS InvColocation (
    invcolo_company_id CHAR(3) NOT NULL,
    FOREIGN KEY (invcolo_company_id) REFERENCES InvestmentCompany(inv_company_id),
    location VARCHAR(255) NOT NULL,
    PRIMARY KEY (invcolo_company_id, location)  -- Added composite primary key
);

-- Create Contains table
CREATE TABLE IF NOT EXISTS Contains (
    contains_mf_id CHAR(2) NOT NULL,
    contains_security_id CHAR(2) NOT NULL,
    security_amount DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (contains_mf_id, contains_security_id),  -- Added composite primary key
    FOREIGN KEY (contains_mf_id) REFERENCES MutualFund(mf_id),
    FOREIGN KEY (contains_security_id) REFERENCES Security(security_id)
);

-- Step 2: Populate the tables

-- Insert data into Security table
INSERT INTO Security (security_id, security_name, security_type) VALUES
('AE', 'Abh Engineering', 'Stock'),
('BH', 'Blues Health', 'Stock'),
('CM', 'County Municipality', 'Bond'),
('DU', 'Downtown Utility', 'Bond'),
('EM', 'Emmitt Machines', 'Stock');

-- Insert data into InvestmentCompany (Fixed column name)
INSERT INTO InvestmentCompany (inv_company_id, inv_company_name, ceo_first_name, ceo_last_name) VALUES
('ACF', 'Acme Finance', 'Mick', 'Dempsey'),
('ALB', 'Albritton', 'Lena', 'Dollar'),
('TCA', 'Tara Capital', 'Ava', 'Newton');

-- Insert data into MutualFund table
INSERT INTO MutualFund (mf_id, mf_name, mf_incorp_date, mf_iccompany_id) VALUES
('BG', 'Growth Fund', '2006-01-01', 'ACF'),
('JU', 'Jupiter', '2005-01-01', 'ALB'),
('LF', 'Tiger Fund', '2005-01-01', 'TCA'),
('OF', 'Owl Fund', '2006-01-01', 'TCA'),
('SG', 'Steady Growth', '2006-01-01', 'ACF'),
('SA', 'Safe Fund', '2006-01-01', 'ALB');

-- Insert data into InvColocation table
INSERT INTO InvColocation (invcolo_company_id, location) VALUES
('ACF', 'Chicago'),
('ACF', 'Denver'),
('ALB', 'Atlanta'),
('ALB', 'New York City'),
('TCA', 'Houston'),
('TCA', 'New York City');

-- Insert data into Contains table
INSERT INTO Contains (contains_mf_id, contains_security_id, security_amount) VALUES
('BG', 'AE', 500.00),
('BG', 'EM', 300.00),
('JU', 'DU', 1000.00),
('JU', 'EM', 2000.00),
('LF', 'BH', 1000.00),
('LF', 'EM', 1000.00),
('OF', 'CM', 1000.00),
('OF', 'DU', 1000.00),
('SA', 'DU', 2000.00),
('SA', 'EM', 1000.00),
('SG', 'AE', 500.00),
('SG', 'DU', 300.00);

-- QUERIES

-- Q1: Total investments
SELECT 
    SUM(security_amount) AS total_investments
FROM Contains;

-- Q2: CEO of company managing "Jupiter" mutual fund
-- This query correctly finds the investment company that manages/operates Jupiter
SELECT 
    ic.inv_company_name,
    ic.ceo_first_name, 
    ic.ceo_last_name,
    CONCAT(ic.ceo_first_name, ' ', ic.ceo_last_name) AS ceo_full_name
FROM MutualFund mf
JOIN InvestmentCompany ic ON mf.mf_iccompany_id = ic.inv_company_id
WHERE mf.mf_name = 'Jupiter';

-- Q3: Grouped investments by security
SELECT 
    s.security_name,
    s.security_type,
    SUM(c.security_amount) AS total_invested
FROM Contains c
JOIN Security s ON c.contains_security_id = s.security_id
GROUP BY s.security_id, s.security_name, s.security_type  -- Added security_id for proper grouping
ORDER BY total_invested DESC;

-- Additional useful queries:

-- Q4: All mutual funds managed by each investment company
SELECT 
    ic.inv_company_name,
    ic.ceo_first_name,
    ic.ceo_last_name,
    mf.mf_name,
    mf.mf_incorp_date
FROM InvestmentCompany ic
JOIN MutualFund mf ON ic.inv_company_id = mf.mf_iccompany_id
ORDER BY ic.inv_company_name, mf.mf_name;

-- Q5: Securities held by Jupiter mutual fund
SELECT 
    s.security_name,
    s.security_type,
    c.security_amount
FROM MutualFund mf
JOIN Contains c ON mf.mf_id = c.contains_mf_id
JOIN Security s ON c.contains_security_id = s.security_id
WHERE mf.mf_name = 'Jupiter'
ORDER BY c.security_amount DESC;

-- Remove the database if it exists for testing purposes
-- DROP DATABASE IF EXISTS Investco;
