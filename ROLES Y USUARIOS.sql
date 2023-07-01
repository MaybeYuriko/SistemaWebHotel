use VERSION2_HOTEL_LIBERTADOR_REAL

-- Creacion de los usuarios
CREATE LOGIN Administrador WITH PASSWORD = 'Hotel123';
CREATE LOGIN Cliente WITH PASSWORD = 'Hotel124';
CREATE LOGIN Recepcionista WITH PASSWORD = 'Hotel125';
CREATE LOGIN Gerente WITH PASSWORD = 'Hotel126';
CREATE LOGIN Soporte WITH PASSWORD = 'Hotel127';

DROP LOGIN Administrador
DROP LOGIN Cliente 
DROP LOGIN Recepcionista 
DROP LOGIN Gerente 
DROP LOGIN Soporte 

-- Creacion de los roles
CREATE ROLE rol1;
CREATE ROLE rol2;
CREATE ROLE rol3;
CREATE ROLE rol4;
CREATE ROLE rol5;

-- Asignar privilegios a usuarios
GRANT SELECT, INSERT, UPDATE, DELETE ON cargo_empleado TO Administrador;
GRANT SELECT, INSERT ON cliente TO Cliente;
GRANT SELECT ON cargo_empleado TO Recepcionista;
GRANT INSERT, UPDATE ON cargo_empleado TO Gerente;
GRANT SELECT, DELETE ON cargo_empleado TO Soporte;

-- Asignar privilegios a roles
GRANT SELECT, INSERT, UPDATE, DELETE ON cargo_empleado TO rol1;
GRANT SELECT, INSERT ON cliente TO rol2;
GRANT SELECT ON cargo_empleado TO rol3;
GRANT INSERT, UPDATE ON cargo_empleado TO rol4;
GRANT SELECT, DELETE ON cargo_empleado TO rol5;

-- Asignar roles a usuarios




-- Desasignar privilegios a usuarios
REVOKE SELECT, INSERT, UPDATE, DELETE ON cargo_empleado FROM usuario1;
REVOKE SELECT, INSERT ON cliente FROM usuario2;
REVOKE SELECT ON cargo_empleado FROM usuario3;
REVOKE INSERT, UPDATE ON cargo_empleado FROM usuario4;
REVOKE SELECT, DELETE ON cargo_empleado FROM usuario5;

-- Desasignar privilegios a roles
REVOKE SELECT, INSERT, UPDATE, DELETE ON cargo_empleado FROM rol1;
REVOKE SELECT, INSERT ON cliente FROM rol2;
REVOKE SELECT ON cargo_empleado FROM rol3;
REVOKE INSERT, UPDATE ON cargo_empleado FROM rol4;
REVOKE SELECT, DELETE ON cargo_empleado FROM rol5;

-- Desasignar roles a usuarios:
ALTER ROLE rol1 DROP MEMBER Administrador;
ALTER ROLE rol2 DROP MEMBER Cliente;
ALTER ROLE rol3 DROP MEMBER Recepcionista;
ALTER ROLE rol4 DROP MEMBER Gerente;
ALTER ROLE rol5 DROP MEMBER Soporte;

**********************************************************************************************************************

-----------------------/*Sp con transacciones*/--------------------------
-- Para la tabla Clientes - INSERTAR
CREATE PROCEDURE InsertarCliente
(
    @nombre varchar(100),
    @apellido varchar(100),
    @dni char(8),
    @edad int,
    @telefono varchar(12),
    @correo varchar(100),
    @observacion varchar(200)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Insertar datos en la tabla cliente
        INSERT INTO cliente (nombre, apellido, dni, edad, telefono, correo, observacion)
        VALUES (@nombre, @apellido, @dni, @edad, @telefono, @correo, @observacion);

        COMMIT;
    END TRY
    BEGIN CATCH
        -- En caso de error, deshacer la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK;

        -- Propagar el error
        THROW;
    END CATCH;
END

-- Ejecutamos
EXEC InsertarCliente 'John', 'Doe', '12345678', 30, '+51 991068231', 'john.doe@example.com', 'Observaciones del cliente';


--Para la tabla Cargo Empleado - ACTUALIZAR
CREATE PROCEDURE ActualizarCargoEmpleado
(
    @id_cargo_empleado INT,
    @nombre_cargo varchar(50),
    @salario_emp money
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar datos en la tabla cargo_empleado
        UPDATE cargo_empleado
        SET nombre_cargo = @nombre_cargo, salario_emp = @salario_emp
        WHERE id_cargo_empleado = @id_cargo_empleado;

        COMMIT;
    END TRY
    BEGIN CATCH
        -- En caso de error, deshacer la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK;

        -- Propagar el error
        THROW;
    END CATCH;
END

-- Para ejecutar
EXEC ActualizarCargoEmpleado @id_cargo_empleado = 1, @nombre_cargo = 'Supervisor', @salario_emp = 4500.00;

--Para la tabla Empleado - UPDATE
CREATE PROCEDURE ActualizarEmpleado
(
    @id_empleado INT,
    @id_cargo_empleado INT,
    @nombre varchar(50),
    @apellido varchar(50),
    @dni varchar(8),
    @edad int,
    @telefono varchar(12),
    @correo varchar(100),
    @estado varchar(25),
    @turno varchar(25)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar datos en la tabla empleado
        UPDATE empleado
        SET id_cargo_empleado = @id_cargo_empleado,
            nombre = @nombre,
            apellido = @apellido,
            dni = @dni,
            edad = @edad,
            telefono = @telefono,
            correo = @correo,
            estado = @estado,
            turno = @turno
        WHERE id_empleado = @id_empleado;

        COMMIT;
    END TRY
    BEGIN CATCH
        -- En caso de error, deshacer la transacción
        IF @@TRANCOUNT > 0
            ROLLBACK;

        -- Propagar el error
        THROW;
    END CATCH;
END

--Ejecutar
EXEC ActualizarEmpleado
    @id_empleado = 1,
    @id_cargo_empleado = 2,
    @nombre = 'Juan',
    @apellido = 'Pérez',
    @dni = '12345678',
    @edad = 30,
    @telefono = '987654321',
    @correo = 'juan@example.com',
    @estado = 'soltero',
    @turno = 'mañana';

--Para la tabla Cargo Tipo Habitacion
CREATE PROCEDURE ActualizarTipoHabitacion
(
    @id_tipohabi INT,
    @nombre_tipo varchar(50),
    @costo_habi money,
    @canti_perso int
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error INT;
    SET @error = 0;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el tipo de habitación exista
        IF NOT EXISTS (SELECT 1 FROM tipo_habi WHERE id_tipohabi = @id_tipohabi)
        BEGIN
            SET @error = 1; -- Código de error para tipo de habitación no encontrado
            GOTO ErrorHandling;
        END

        -- Actualizar datos en la tabla tipo_habi
        UPDATE tipo_habi
        SET nombre_tipo = @nombre_tipo,
            costo_habi = @costo_habi,
            canti_perso = @canti_perso
        WHERE id_tipohabi = @id_tipohabi;

        COMMIT;
        RETURN 0; -- Actualización exitosa
    END TRY
    BEGIN CATCH
        SET @error = ERROR_NUMBER();
        
        ErrorHandling:
        IF @@TRANCOUNT > 0
            ROLLBACK;

        RETURN @error; -- Devolver el código de error en caso de falla
    END CATCH;
END
--Ejecucion
DECLARE @result INT;

EXEC @result = ActualizarTipoHabitacion
    @id_tipohabi = 1,
    @nombre_tipo = 'Suite',
    @costo_habi = 200.00,
    @canti_perso = 2;

IF @result = 0
    PRINT 'La actualización se realizó correctamente.';
ELSE IF @result = 1
    PRINT 'Tipo de habitación no encontrado.';
ELSE
    PRINT 'Error desconocido al actualizar el tipo de habitación.';

--Para la tabla Cargo Servicios Habitacion
CREATE PROCEDURE EliminarServicioHabitacion
(
    @id_servicio INT
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @error INT;
    SET @error = 0;

    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que el servicio exista
        IF NOT EXISTS (SELECT 1 FROM servicios_habi WHERE id_servicio = @id_servicio)
        BEGIN
            SET @error = 1; -- Código de error para servicio no encontrado
            GOTO ErrorHandling;
        END

        -- Eliminar el servicio de la tabla servicios_habi
        DELETE FROM servicios_habi WHERE id_servicio = @id_servicio;

        COMMIT;
        RETURN 0; -- Eliminación exitosa
    END TRY
    BEGIN CATCH
        SET @error = ERROR_NUMBER();
        
        ErrorHandling:
        IF @@TRANCOUNT > 0
            ROLLBACK;

        RETURN @error; -- Devolver el código de error en caso de falla
    END CATCH;
END
--Ejecucion
DECLARE @result INT;

EXEC @result = EliminarServicioHabitacion
    @id_servicio = 1;

IF @result = 0
    PRINT 'La eliminación se realizó correctamente.';
ELSE IF @result = 1
    PRINT 'Servicio no encontrado.';
ELSE
    PRINT 'Error desconocido al eliminar el servicio.';

--Para la tabla Cargo Habitacion

--Para la tabla Cargo Reservacion

--Para la tabla Cargo Comprobante_Alquiler

--Para la tabla Cargo Detalle_Comprobante



