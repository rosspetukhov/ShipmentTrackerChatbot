-- Insert 10 suppliers
INSERT INTO track.suppliers (supplier_name, contact_email, contact_phone, address)
VALUES
('Acme Corp', 'contact@acme.com', '555-0101', '123 Acme St, Springfield'),
('Globex Inc', 'sales@globex.com', '555-0202', '456 Globex Ave, Metropolis'),
('Soylent Corp', 'info@soylent.com', '555-0303', '789 Soylent Rd, Gotham'),
('Initech', 'support@initech.com', '555-0404', '101 Initech Blvd, Silicon Valley'),
('Umbrella Corp', 'contact@umbrella.com', '555-0505', '202 Umbrella Dr, Raccoon City'),
('Wayne Enterprises', 'bruce@wayneenterprises.com', '555-0606', '1007 Mountain Dr, Gotham'),
('Stark Industries', 'tony@starkindustries.com', '555-0707', '10880 Malibu Point, Malibu'),
('Cyberdyne Systems', 'info@cyberdyne.com', '555-0808', '1 Cyberdyne Way, Los Angeles'),
('Wonka Industries', 'willy@wonka.com', '555-0909', '10 Candy Ln, Chocolate Factory'),
('Tyrell Corp', 'replicant@tyrell.com', '555-1010', '201 Replicant St, Los Angeles');

-- Insert 10 materials
INSERT INTO track.materials (material_name, description)
VALUES
('Steel', 'High quality steel'),
('Plastic', 'Durable plastic material'),
('Copper Wire', 'Conductive copper wiring'),
('Rubber', 'Flexible rubber sheets'),
('Glass', 'Tempered glass panels'),
('Aluminum', 'Lightweight aluminum rods'),
('Silicon Chips', 'Semiconductor silicon chips'),
('Leather', 'Genuine leather hides'),
('Cotton Fabric', 'Soft cotton fabric'),
('Ceramic Tiles', 'Heat-resistant ceramic tiles');

-- Insert 10 shipments, linking each to a supplier (supplier_id from 1 to 10)
INSERT INTO track.shipments (supplier_id, shipment_number, shipment_date, expected_delivery_date, status)
VALUES
(1, 'SHP001', '2025-05-01', '2025-05-10', 'in transit'),
(2, 'SHP002', '2025-05-02', '2025-05-11', 'delivered'),
(3, 'SHP003', '2025-05-03', '2025-05-12', 'in transit'),
(4, 'SHP004', '2025-05-04', '2025-05-13', 'delayed'),
(5, 'SHP005', '2025-05-05', '2025-05-14', 'in transit'),
(6, 'SHP006', '2025-05-06', '2025-05-15', 'delivered'),
(7, 'SHP007', '2025-05-07', '2025-05-16', 'in transit'),
(8, 'SHP008', '2025-05-08', '2025-05-17', 'cancelled'),
(9, 'SHP009', '2025-05-09', '2025-05-18', 'in transit'),
(10, 'SHP010', '2025-05-10', '2025-05-19', 'in transit');

-- Insert 10 shipment items, linking shipments to materials
INSERT INTO track.shipment_items (shipment_id, material_id, quantity, unit_price)
VALUES
(1, 1, 100.00, 25.50),
(2, 2, 200.00, 10.00),
(3, 3, 150.00, 15.75),
(4, 4, 300.00, 8.25),
(5, 5, 250.00, 12.30),
(6, 6, 180.00, 22.10),
(7, 7, 400.00, 50.00),
(8, 8, 350.00, 18.00),
(9, 9, 500.00, 5.75),
(10, 10, 600.00, 7.20);
