-- Creamos database WalmartSales --
CREATE DATABASE IF NOT EXISTS WalmartSales;
-- Creamos tabla sales --
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
-- Al seleccionar todos los atributos como NOT NULL, estamos seleccionando solo datos completos --
-- Visualizamos la tabla --
SELECT
	*
FROM sales;
-- Trabajamos con la tabla para agregar mes y momento del dia (util para analisis) --
-- Desactivamos Modo Seguro --
-- MES --
SET SQL_SAFE_UPDATES = 0;
-- Agregamos columna de month a la tabla sales --
ALTER TABLE sales ADD COLUMN Month INTEGER;
-- Actualizamos el valor en la columna Month -- 
UPDATE sales
SET Month = EXTRACT(MONTH FROM date)
WHERE 1=1;
-- MOMENTO DEL DIA --
-- Agregamos columna de time_range a la tabla sales --
ALTER TABLE sales ADD COLUMN time_range VARCHAR(20);
UPDATE sales
SET time_range = CASE
    WHEN time >= '06:00:00' AND time < '12:00:00' THEN 'Mañana'
    WHEN time >= '12:00:00' AND time < '18:00:00' THEN 'Tarde'
    WHEN time >= '18:00:00' AND time < '24:00:00' THEN 'Noche'
    ELSE 'Madrugada'
END;
-- Activamos Modo Seguro --
SET SQL_SAFE_UPDATES = 1;
-- Visualizamos la tabla --
SELECT
	*
FROM sales;

-- PRODUCTOS (LINEA DE PRODUCTO) --
-- Analisis de Linea de producto --
SELECT product_line AS "Línea de Producto", COUNT(invoice_id) AS "Número de Ventas", AVG(unit_price) AS "Precio Promedio", SUM(quantity) AS "Cantidad Total Vendida [un]"
FROM sales
GROUP BY product_line;
-- Rentabilidad por linea de producto --
SELECT product_line AS "Línea de Producto", SUM(total) AS "Ventas Totales", SUM(gross_income) AS "Ingreso Bruto Total"
FROM sales
GROUP BY product_line;
-- Ventas de Sucursal por Línea de Producto --
SELECT product_line AS "Línea de Producto", branch AS "Sucursal", COUNT(invoice_id) AS "Número de Ventas"
FROM sales
GROUP BY product_line, branch;
-- Ventas Temporales por Línea de Producto --
SELECT product_line AS "Línea de Producto", Month AS "Mes", SUM(quantity) AS "Cantidad Total Vendida [un]"
FROM sales
GROUP BY product_line, Month
ORDER BY product_line, Month;

-- VENTAS --
-- Desempeño de ventas por tienda --
SELECT Branch, City AS 'Ciudad', SUM(`Total`) AS `Ventas totales`
FROM sales
GROUP BY Branch, City;
-- Número de Transacciones y Ticket Promedio por Tienda --
SELECT Branch, COUNT(invoice_id) AS 'Número de Transacciones', AVG(Total) AS 'Ticket Promedio'
FROM sales
GROUP BY Branch;
-- Análisis de la Categoría de Productos por Tienda --
SELECT Branch, product_line AS "Línea de Producto", SUM(quantity) AS "Cantidad Vendida"
FROM sales
GROUP BY Branch, product_line;
-- Análisis de Satisfacción del Cliente por Tienda --
SELECT Branch, AVG(rating) AS 'Calificación Promedio'
FROM sales
GROUP BY Branch;

-- CLIENTES --
-- Segmentación de clientes --
SELECT customer_type AS 'Tipo de cliente', gender AS 'Genero', COUNT(invoice_id) AS 'Numero de ventas', AVG(Total) AS 'Promedio de gasto'
FROM sales
GROUP BY customer_type, gender;
-- Comportamiento de compra --
SELECT customer_type AS 'Tipo de cliente', AVG(quantity) AS 'Promedio cantidad', AVG(total) AS 'Promedio de gasto'
FROM sales
GROUP BY customer_type;
-- Satisfacción y preferencias --
SELECT customer_type AS 'Tipo de cliente', AVG(rating) AS 'Rating promedio'
FROM sales
GROUP BY customer_type;
-- Desglose de Compras por Categoría de Producto y Tipo de Cliente --
SELECT customer_type AS 'Tipo de cliente', gender AS 'Genero', product_line AS 'Línea de Producto', COUNT(invoice_id) AS 'Número de Ventas'
FROM sales
GROUP BY customer_type, gender, product_line;
-- Análisis de Frecuencia de Compras --
SELECT customer_type AS 'Tipo de cliente', gender AS 'Genero', AVG(frequency) AS 'Frecuencia de Compras'
FROM (
    SELECT 
        customer_type, 
        gender, 
        DATEDIFF(MAX(TIMESTAMP(date, time)), MIN(TIMESTAMP(date, time))) / COUNT(DISTINCT invoice_id) AS frequency
    FROM 
        sales
    GROUP BY 
        customer_type, gender
) AS subquery
GROUP BY customer_type, gender;
-- Distribución de Métodos de Pago por Tipo de Cliente --
SELECT customer_type AS 'Tipo de cliente', payment AS 'Método de Pago', COUNT(invoice_id) AS 'Número de Ventas'
FROM sales
GROUP BY customer_type, payment;
-- Análisis del Momento del Día en las Compras --
SELECT customer_type AS 'Tipo de cliente', time_range AS 'Momento del Día', COUNT(invoice_id) AS 'Número de Ventas'
FROM sales
GROUP BY customer_type, time_range;
-- Análisis del Día de la Semana en las Compras --
SELECT customer_type AS 'Tipo de cliente', DAYOFWEEK(date) AS 'Día de la Semana', COUNT(invoice_id) AS 'Número de Ventas'
FROM sales
GROUP BY customer_type, DAYOFWEEK(date);
-- Análisis Detallado de la Satisfacción del Cliente --
SELECT customer_type AS 'Tipo de cliente', gender AS 'Genero', AVG(rating) AS 'Rating Promedio', AVG(total) AS 'Gasto Promedio', product_line AS 'Línea de Producto'
FROM sales
GROUP BY customer_type, gender, product_line;