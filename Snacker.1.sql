use master
go

drop database if exists Snacker
go

create database Snacker
go 

use Snacker
go

CREATE TABLE Areas (
    id int  identity(1,1),
    name varchar(80)NOT NULL CHECK (name LIKE '%[a-zA-Z ]'),
    description varchar(200)NOT NULL CHECK (description LIKE '%[^a-zA-Z0-9]%'),
    status char(1) default 'A' CHECK (status IN ('A', 'I')),
    CONSTRAINT Areas_pk PRIMARY KEY  (id)
)
go

CREATE TABLE Customer (
    id int  identity(1,1),
    name varchar(60)NOT NULL CHECK (name LIKE '%[a-zA-Z ]'),
    address varchar(90) NOT NULL CHECK (address LIKE '%[^a-zA-Z0-9]%'),
    phone char(9) CHECK (phone LIKE '%[9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'),
    status char(1) default 'A' CHECK (status IN ('A', 'I')),
	birthdayDate date,
	document varchar(3) NOT NULL CHECK(document IN ('DNI', 'CE')), -- '1' => DNI, '2' => CE
    documentNumber varchar(12) NOT NULL,
    CONSTRAINT Customer_pk PRIMARY KEY  (id),
	 CONSTRAINT CK_Customer_number_document 
        CHECK (
            (document = 'DNI' AND LEN(documentNumber) = 8 AND documentNumber LIKE '%[0-9]%') OR
            (document = 'CE' AND LEN(documentNumber) = 12 AND documentNumber LIKE '%[0-9]%')
        )
)
go

CREATE TABLE Employee (
    id int identity(1,1),
    name varchar(50) NOT NULL CHECK (name LIKE '%[a-zA-Z ]'),
    lastName varchar(80) NOT NULL CHECK (lastName LIKE '%[a-zA-Z ]'),
    type_document varchar(3) NOT NULL CHECK(type_document IN ('DNI', 'CE')), 
    number_document varchar(12) NOT NULL,
    cell_phone char(9) NOT NULL CHECK (cell_phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    status char(1) DEFAULT 'A' CHECK (status IN ('A', 'I')),
    CONSTRAINT Employee_pk PRIMARY KEY (id),
    CONSTRAINT CK_Employee_number_document 
        CHECK (
            (type_document = 'DNI' AND LEN(number_document) = 8 AND number_document LIKE '%[0-9]%') OR
            (type_document = 'CE' AND LEN(number_document) = 12 AND number_document LIKE '%[0-9]%')
        )
)
go


CREATE TABLE Product (
    id int  identity(1,1),
    name varchar(60)NOT NULL CHECK (name LIKE '%[a-zA-Z ]'),
    description varchar(80) NOT NULL CHECK (description LIKE '%[^a-zA-Z0-9]%'),
    unit_price decimal(8,2) NOT NULL CHECK (unit_price >= 0.00),
    available_stock int NOT NULL CHECK (available_stock >= 0),
    CONSTRAINT Product_pk PRIMARY KEY  (id)
)
go

CREATE TABLE Supplier (
    id int  identity(1,1),
    name varchar(60) NOT NULL CHECK (name LIKE '%[a-zA-Z ]') ,
    address varchar(90)  NOT NULL CHECK (address LIKE '%[^a-zA-Z0-9]%'),
    phone char(9) CHECK(phone LIKE '%[9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'),
    CONSTRAINT Supplier_pk PRIMARY KEY  (id)
)
go

CREATE TABLE Purchase (
    id int  identity(1,1),
    Supplier_id int NOT NULL CHECK (Supplier_id >= 0),
    date datetime default GETDATE(),
    CONSTRAINT Purchase_pk PRIMARY KEY  (id)
)
go

CREATE TABLE RawMaterial (
    id int  identity(1,1),
    name varchar(80) NOT NULL CHECK (name LIKE '%[a-zA-Z ]') ,
    price decimal(8,2) NOT NULL CHECK (price >= 0.00),
    CONSTRAINT RawMaterial_pk PRIMARY KEY  (id)
)
go


CREATE TABLE PurchaseDetail (
    id int  identity(1,1),
    quantity int  NOT NULL CHECK (quantity >= 0),
    Purchase_id int NOT NULL CHECK (Purchase_id >= 0),
    RawMaterial_id int NOT NULL CHECK (RawMaterial_id >= 0),
    unit_price decimal(8,2)NOT NULL  CHECK (unit_price >= 0),
    CONSTRAINT PurchaseDetail_pk PRIMARY KEY  (id)
)
go

CREATE TABLE RawMaterialHistory (
    id int  identity(1,1),
    Employee_id int  NOT NULL CHECK (Employee_id >= 0),
    Areas_id int  NOT NULL CHECK (Areas_id >= 0),
    Purchase_id int  NOT NULL CHECK (Purchase_id >= 0),
    RawMaterial_id int  NOT NULL CHECK (RawMaterial_id >= 0),
    status char(1) default 'A' CHECK (status IN ('A', 'I')),
    CONSTRAINT RawMaterialHistory_pk PRIMARY KEY  (id)
)
go

CREATE TABLE Sale (
    id int  identity(1,1) ,
    date datetime default GETDATE(),
    CONSTRAINT Sale_pk PRIMARY KEY  (id)
)
go

CREATE TABLE SaleDetail (
    id int  identity(1,1),
    Sale_id int NOT NULL CHECK (Sale_id >= 0),
    Product_id int  NOT NULL CHECK (Product_id >= 0),
    quantity int NOT NULL CHECK (quantity >= 0) ,
    unit_price decimal(8,2) NOT NULL CHECK (unit_price >= 0.00),
	Employee_id int  NOT NULL CHECK (Employee_id >= 0),
    Customer_id int  NOT NULL CHECK (Customer_id >= 0),
    CONSTRAINT SaleDetail_pk PRIMARY KEY  (id)
)
go

CREATE TABLE Record (
    id int  identity(1,1),
    Employee_id int NOT NULL CHECK (Employee_id >= 0),
    Product_id int  NOT NULL CHECK (Product_id >= 0),
    Sale_id int  NOT NULL CHECK (Sale_id >= 0),
    amount int  NOT NULL CHECK (amount >= 0),
    date datetime default GETDATE() ,
    sale_detail int  NOT NULL CHECK (sale_detail >= 0) ,
    status char(1) default 'A' CHECK (status IN ('A', 'I')),
    CONSTRAINT Record_pk PRIMARY KEY  (id)
)
go


ALTER TABLE PurchaseDetail ADD CONSTRAINT PurchaseDetail_Purchase
    FOREIGN KEY (Purchase_id)
    REFERENCES Purchase (id);

ALTER TABLE PurchaseDetail ADD CONSTRAINT PurchaseDetail_RawMaterial
    FOREIGN KEY (RawMaterial_id)
    REFERENCES RawMaterial (id);

ALTER TABLE Purchase ADD CONSTRAINT Purchase_Supplier
    FOREIGN KEY (Supplier_id)
    REFERENCES Supplier (id);

ALTER TABLE RawMaterialHistory ADD CONSTRAINT RawMaterialHistory_Areas
    FOREIGN KEY (Areas_id)
    REFERENCES Areas (id);

ALTER TABLE RawMaterialHistory ADD CONSTRAINT RawMaterialHistory_Employee
    FOREIGN KEY (Employee_id)
    REFERENCES Employee (id);

ALTER TABLE RawMaterialHistory ADD CONSTRAINT RawMaterialHistory_Purchase
    FOREIGN KEY (Purchase_id)
    REFERENCES Purchase (id);

ALTER TABLE RawMaterialHistory ADD CONSTRAINT RawMaterialHistory_RawMaterial
    FOREIGN KEY (RawMaterial_id)
    REFERENCES RawMaterial (id);

ALTER TABLE Record ADD CONSTRAINT Record_Employee
    FOREIGN KEY (Employee_id)
    REFERENCES Employee (id);

ALTER TABLE Record ADD CONSTRAINT Record_Product
    FOREIGN KEY (Product_id)
    REFERENCES Product (id);

ALTER TABLE Record ADD CONSTRAINT Record_Sale
    FOREIGN KEY (Sale_id)
    REFERENCES Sale (id);

ALTER TABLE SaleDetail ADD CONSTRAINT SaleDetail_Product
    FOREIGN KEY (Product_id)
    REFERENCES Product (id);

ALTER TABLE SaleDetail ADD CONSTRAINT SaleDetail_Sale
    FOREIGN KEY (Sale_id)
    REFERENCES Sale (id);

ALTER TABLE SaleDetail ADD CONSTRAINT Sale_Customer
    FOREIGN KEY (Customer_id)
    REFERENCES Customer (id);

ALTER TABLE SaleDetail ADD CONSTRAINT Sale_Employee
    FOREIGN KEY (Employee_id)
    REFERENCES Employee (id);
