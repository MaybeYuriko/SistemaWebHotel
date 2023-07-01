create database VERSION2_HOTEL_LIBERTADOR_REAL;
use VERSION2_HOTEL_LIBERTADOR_REAL;

--- TABLAS
CREATE TABLE Hotel_Empresa(
  idHotel INT AUTO_INCREMENT PRIMARY KEY,
  RUC int,
  direccion varchar(50),
  distrito varchar (50),
  telefono varchar(10)
);

CREATE TABLE cliente(
  idcliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre varchar(100)not null,
  apellido varchar(100)not null,
  dni char (8)not null,
  edad int not null,
  telefono varchar(12)not null,
  correo varchar (100)not null,
  observacion varchar (200)not null
);


CREATE TABLE cargo_empleado(
  id_cargo_empleado INT AUTO_INCREMENT PRIMARY KEY,
  nombre_cargo varchar(50)not null,
  salario_emp decimal(10,2) not null
);

CREATE TABLE empleado(
  id_empleado INT AUTO_INCREMENT PRIMARY KEY,
  id_cargo_empleado int not null,
  nombre varchar (50)not null,
  apellido varchar(50)not null,
  dni varchar(8)not null,
  edad int not null,
  telefono varchar(12)not null,
  correo varchar (100)not null,
  estado varchar (25)not null, -- casado, soltero, viudo, divorciado
  turno varchar (25)not null,
  CONSTRAINT FK_CAARGO_EMP FOREIGN KEY (id_cargo_empleado) REFERENCES cargo_empleado(id_cargo_empleado)
);

CREATE TABLE tipo_habi(
  id_tipohabi INT AUTO_INCREMENT PRIMARY KEY,
  nombre_tipo varchar (50)not null, -- Duplex, personal, etc.
  costo_habi decimal(10,2) not null,
  canti_perso int not null
);

CREATE TABLE servicios_habi(
  id_servicio INT AUTO_INCREMENT PRIMARY KEY,
  descrip_ser varchar (50) not null, -- Comida, sauna, karaoke
  costo_ser	decimal(10,2) not null
);

CREATE TABLE habitacion(
  num_habitacion  INT AUTO_INCREMENT PRIMARY KEY,
  id_servicio int not null,
  id_tipohabi int not null,
  numero_piso int not null,
  estado varchar(50) not null, -- disponible , reservado, matenimiento , ocupado
  costo_total decimal(10,2) not null,

  CONSTRAINT FK_TIPSERVI FOREIGN KEY (id_servicio) REFERENCES servicios_habi(id_servicio),
  CONSTRAINT FK_TIPHABI FOREIGN KEY (id_tipohabi) REFERENCES tipo_habi(id_tipohabi)
);

CREATE TABLE reservacion(
  id_reservacion INT AUTO_INCREMENT PRIMARY KEY,
  id_empleado int not null, 
  idcliente int not null,
  num_habitacion int not null,
  id_servicio int not null,
  id_tipohabi int not null,
  fecha_reservacion date not null,
  cantidad_personas int not null,
  CONSTRAINT FK_IDCLIENTE FOREIGN KEY (idcliente) REFERENCES cliente(idcliente),
  CONSTRAINT FK_NUMHABITACION FOREIGN KEY (num_habitacion) REFERENCES habitacion(num_habitacion),
  CONSTRAINT FK_IDEMPLEADO5 FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado),
  CONSTRAINT FK_IDTIPOHABI FOREIGN KEY (id_tipohabi) REFERENCES tipo_habi(id_tipohabi),
  CONSTRAINT FK_IDSERVICIO FOREIGN KEY (id_servicio) REFERENCES servicios_habi(id_servicio)
);

CREATE TABLE comprobante_alquiler(
  num_comprobante INT AUTO_INCREMENT PRIMARY KEY,
  id_empleado int not null,
  id_reservacion int not null,
  tipo_comprobante varchar(50) not null, -- boleta o factura
  fecha_emision date not null,
  sub_total decimal(10,2) not null,
  IGV decimal(10,2) not null,
  total decimal(10,2) not null
);

  ALTER TABLE comprobante_alquiler ADD CONSTRAINT fk_Empleados_2 FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);
  ALTER TABLE comprobante_alquiler ADD CONSTRAINT FK_RESERVACION2 FOREIGN KEY (id_reservacion) REFERENCES reservacion(id_reservacion);
  
CREATE TABLE Detalle_Comprobante (
    idDetalle INT AUTO_INCREMENT PRIMARY KEY,
	idHotel int not null,
    num_comprobante int not null,
    id_empleado int not null,
    id_reservacion int not null,
    tipo_comprobante varchar(50) not null,
    fecha_emision datetime not null,
    fecha_entrada date not null,
    fecha_salida date not null,
    cantidad int,
    Observacion varchar(100),
    precio_unidad decimal(10,2)  ,
    sub_total decimal(10,2)  not null,
    IGV decimal(10,2)   not null,
    total decimal(10,2)   not null,
    importe decimal(10,2) not null
);

    ALTER TABLE Detalle_Comprobante ADD CONSTRAINT FK_IDEMPLEADO_3 FOREIGN KEY (id_empleado) REFERENCES empleado(id_empleado);
    ALTER TABLE Detalle_Comprobante ADD CONSTRAINT FK_RESERVACION_2 FOREIGN KEY (id_reservacion) REFERENCES reservacion(id_reservacion);
	ALTER TABLE Detalle_Comprobante ADD CONSTRAINT FK_HOTEL_PK FOREIGN KEY (idHotel) REFERENCES Hotel_Empresa(idHotel);
	ALTER TABLE Detalle_Comprobante ADD CONSTRAINT FK_NUMCOMPROBANTE_3 FOREIGN KEY (num_comprobante) REFERENCES comprobante_alquiler(num_comprobante);

                                                            /*PROCEDIMIENTOS ALMACENADOS*/
-- INDICES

-- TRIGGERS 


-- CURSORES CON PROCEDURES
/*Tabla Cliente*/
-- Crear el procedimiento almacenado para insertar un cliente
DELIMITER //
CREATE PROCEDURE insertar_cliente(
  IN p_nombre varchar(100),
  IN p_apellido varchar(100),
  IN p_dni char(8),
  IN p_edad int,
  IN p_telefono varchar(12),
  IN p_correo varchar(100),
  IN p_observacion varchar(200)
)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_idcliente INT;
  DECLARE cur_nombre varchar(100);
  DECLARE cur_apellido varchar(100);
  DECLARE cur_dni char(8);
  DECLARE cur_edad int;
  DECLARE cur_telefono varchar(12);
  DECLARE cur_correo varchar(100);
  DECLARE cur_observacion varchar(200);
  
  -- Definir el cursor
  DECLARE cursor_cliente CURSOR FOR
    SELECT idcliente, nombre, apellido, dni, edad, telefono, correo, observacion
    FROM cliente;
    
  -- Abrir el cursor
  OPEN cursor_cliente;
  
  -- Recorrer el cursor
  read_loop: LOOP
    -- Obtener los valores del cursor
    FETCH cursor_cliente INTO cur_idcliente, cur_nombre, cur_apellido, cur_dni, cur_edad, cur_telefono, cur_correo, cur_observacion;
    
    -- Verificar si el cursor está vacío
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    -- Comparar los valores del cursor con los parámetros de entrada
    IF cur_nombre = p_nombre AND cur_apellido = p_apellido AND cur_dni = p_dni THEN
      -- Si se encuentra un cliente con los mismos datos, no se realiza la inserción
      CLOSE cursor_cliente;
      RETURN;
    END IF;
  END LOOP;
  
  -- Insertar el nuevo cliente
  INSERT INTO cliente(nombre, apellido, dni, edad, telefono, correo, observacion)
  VALUES (p_nombre, p_apellido, p_dni, p_edad, p_telefono, p_correo, p_observacion);
  
  -- Cerrar el cursor
  CLOSE cursor_cliente;
END //
DELIMITER ;

-- Crear el procedimiento almacenado para eliminar un cliente
DELIMITER //
CREATE PROCEDURE eliminar_cliente(
  IN p_idcliente INT
)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_idcliente INT;
  
  -- Definir el cursor
  DECLARE cursor_cliente CURSOR FOR
    SELECT idcliente
    FROM cliente;
    
  -- Abrir el cursor
  OPEN cursor_cliente;
  
  -- Recorrer el cursor
  read_loop: LOOP
    -- Obtener los valores del cursor
    FETCH cursor_cliente INTO cur_idcliente;
    
    -- Verificar si el cursor está vacío
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    -- Comparar el valor del cursor con el parámetro de entrada
    IF cur_idcliente = p_idcliente THEN
      -- Si se encuentra el cliente, se elimina
      DELETE FROM cliente WHERE idcliente = cur_idcliente;
      CLOSE cursor_cliente;
      RETURN;
    END IF;
  END LOOP;
  
  -- Cerrar el cursor
  CLOSE cursor_cliente;
END //
DELIMITER ;

-- Crear el procedimiento almacenado para actualizar un cliente
DELIMITER //
CREATE PROCEDURE actualizar_cliente(
  IN p_idcliente INT,
  IN p_nombre varchar(100),
  IN p_apellido varchar(100),
  IN p_dni char(8),
  IN p_edad int,
  IN p_telefono varchar(12),
  IN p_correo varchar(100),
  IN p_observacion varchar(200)
)
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE cur_idcliente INT;
  DECLARE cur_nombre varchar(100);
  DECLARE cur_apellido varchar(100);
  DECLARE cur_dni char(8);
  DECLARE cur_edad int;
  DECLARE cur_telefono varchar(12);
  DECLARE cur_correo varchar(100);
  DECLARE cur_observacion varchar(200);
  
  -- Definir el cursor
  DECLARE cursor_cliente CURSOR FOR
    SELECT idcliente, nombre, apellido, dni, edad, telefono, correo, observacion
    FROM cliente;
    
  -- Abrir el cursor
  OPEN cursor_cliente;
  
  -- Recorrer el cursor
  read_loop: LOOP
    -- Obtener los valores del cursor
    FETCH cursor_cliente INTO cur_idcliente, cur_nombre, cur_apellido, cur_dni, cur_edad, cur_telefono, cur_correo, cur_observacion;
    
    -- Verificar si el cursor está vacío
    IF done THEN
      LEAVE read_loop;
    END IF;
    
    -- Comparar el valor del cursor con el parámetro de entrada
    IF cur_idcliente = p_idcliente THEN
      -- Si se encuentra el cliente, se actualiza
      UPDATE cliente
      SET nombre = p_nombre, apellido = p_apellido, dni = p_dni, edad = p_edad,
          telefono = p_telefono, correo = p_correo, observacion = p_observacion
      WHERE idcliente = cur_idcliente;
      CLOSE cursor_cliente;
      RETURN;
    END IF;
  END LOOP;
  
  -- Cerrar el cursor
  CLOSE cursor_cliente;
END //
DELIMITER ;

/*Tabla Cargo_Empleado*/

/*Tabla Empleado*/

/*Tabla Servicios_habi*/

/*Tabla Tipo_habi*/

/*Tabla Habitacion*/

/*Tabla Reservacion*/

/*Tabla Comproabnte_alquiler*/

/*Tabla Detalle_comprobante*/

/*Tabla Hotel_Empresa*/


-- FUNCIONES

-- VISTAS

                                                             /*SEGURIDAD Y AUDITORIA*/
 
-- ROLES/USUARIOS Y PRIVILEGIOS

-- Asignar valores a los parámetros de archivos físicos MDF y LDF

-- SP de mantenimiento de tablas de su proyecto 

-- SP con parámetros de tipo OUTPUT

-- SP con parámetros con valor por default

-- Ejecución de SP con parámetros por posición y por nombre 

-- SP con uso de transacciones.
