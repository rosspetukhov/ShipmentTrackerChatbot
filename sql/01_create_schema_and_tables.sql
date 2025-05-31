-- Create schema 'track' if it doesn't exist
IF NOT EXISTS (
    SELECT * FROM sys.schemas WHERE name = 'track'
)
BEGIN
    EXEC('CREATE SCHEMA track');
END
GO

-- Drop tables if they exist (child tables first)
IF OBJECT_ID('track.shipment_items', 'U') IS NOT NULL
    DROP TABLE track.shipment_items;

IF OBJECT_ID('track.shipments', 'U') IS NOT NULL
    DROP TABLE track.shipments;

IF OBJECT_ID('track.materials', 'U') IS NOT NULL
    DROP TABLE track.materials;

IF OBJECT_ID('track.suppliers', 'U') IS NOT NULL
    DROP TABLE track.suppliers;

-- Create tables in the 'track' schema

CREATE TABLE track.suppliers (
    supplier_id INT PRIMARY KEY IDENTITY(1,1),
    supplier_name VARCHAR(255) NOT NULL,
    contact_email VARCHAR(255),
    contact_phone VARCHAR(50),
    address NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    record_status VARCHAR(20) DEFAULT 'created'
);

CREATE TABLE track.materials (
    material_id INT PRIMARY KEY IDENTITY(1,1),
    material_name VARCHAR(255) NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    record_status VARCHAR(20) DEFAULT 'created'
);

CREATE TABLE track.shipments (
    shipment_id INT PRIMARY KEY IDENTITY(1,1),
    supplier_id INT NOT NULL,
    shipment_number VARCHAR(100) UNIQUE NOT NULL,
    shipment_date DATE NOT NULL,
    expected_delivery_date DATE,
    status VARCHAR(50) DEFAULT 'in transit',
    created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    record_status VARCHAR(20) DEFAULT 'created',
    CONSTRAINT FK_Shipments_Suppliers FOREIGN KEY (supplier_id) REFERENCES track.suppliers(supplier_id)
);

CREATE TABLE track.shipment_items (
    shipment_item_id INT PRIMARY KEY IDENTITY(1,1),
    shipment_id INT NOT NULL,
    material_id INT NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit_price DECIMAL(10,2),
    created_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    updated_at DATETIME2 DEFAULT SYSUTCDATETIME(),
    record_status VARCHAR(20) DEFAULT 'created',
    CONSTRAINT FK_ShipmentItems_Shipments FOREIGN KEY (shipment_id) REFERENCES track.shipments(shipment_id),
    CONSTRAINT FK_ShipmentItems_Materials FOREIGN KEY (material_id) REFERENCES track.materials(material_id)
);
