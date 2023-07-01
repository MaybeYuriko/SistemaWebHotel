create database VERSION2_HOTEL_LIBERTADOR_REAL
on
(NAME = 'VERSION2_HOTEL_LIBERTADOR_REAL_Data', FILENAME = 'C:\Users\Usuario\Desktop\DatayLogs\VERSION2_HOTEL_LIBERTADOR_REAL_Data.mdf',
SIZE = 150MB, MAXSIZE = 500, FILEGROWTH = 5MB)
LOG ON
(NAME = 'VERSION2_HOTEL_LIBERTADOR_REAL_Log', FILENAME = 'C:\Users\Usuario\Desktop\DatayLogs\VERSION2_HOTEL_LIBERTADOR_REAL_Log.ldf',
SIZE = 50MB, MAXSIZE = 200, FILEGROWTH = 5%)
go

use VERSION2_HOTEL_LIBERTADOR_REAL
go

--- TABLAS
CREATE TABLE Hotel_Empresa(
  idHotel INT IDENTITY (1,1) PRIMARY KEY,
  RUC int,
  direccion varchar(50),
  distrito varchar (50),
  telefono varchar(10)
)

CREATE TABLE cliente(
  idcliente INT IDENTITY (1,1) PRIMARY KEY,
  nombre varchar(100)not null,
  apellido varchar(100)not null,
  dni char (8)not null,
  edad int not null,
  telefono varchar(12)not null, -- +51 991068231
  correo varchar (100)not null,
  observacion varchar (200)not null
)

CREATE TABLE cargo_empleado(
  id_cargo_empleado INT IDENTITY (1,1) PRIMARY KEY,
  nombre_cargo varchar(50)not null,
  salario_emp money not null
)

CREATE TABLE empleado(
  id_empleado INT IDENTITY (1,1) PRIMARY KEY,
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
)

CREATE TABLE tipo_habi(
  id_tipohabi INT IDENTITY (1,1) PRIMARY KEY,
  nombre_tipo varchar (50)not null, -- Duplex, personal, etc.
  costo_habi money not null,
  canti_perso int not null
)

CREATE TABLE servicios_habi(
  id_servicio INT IDENTITY (1,1) PRIMARY KEY,
  descrip_ser varchar (50) not null, --Comida, sauna, karaoke
  costo_ser	money not null
)

CREATE TABLE habitacion(
  num_habitacion  int PRIMARY KEY,
  id_servicio int not null,
  id_tipohabi int not null,
  numero_piso int not null,
  estado varchar(50) not null, -- disponible , reservado, matenimiento , ocupado
  costo_total money not null,

  CONSTRAINT FK_TIPSERVI FOREIGN KEY (id_servicio) REFERENCES servicios_habi(id_servicio),
  CONSTRAINT FK_TIPHABI FOREIGN KEY (id_tipohabi) REFERENCES tipo_habi(id_tipohabi)
)

CREATE TABLE reservacion(
  id_reservacion INT IDENTITY (1,1) PRIMARY KEY,
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
)

CREATE TABLE comprobante_alquiler(
  num_comprobante INT IDENTITY (1,1) PRIMARY KEY,
  id_empleado int not null,
  id_reservacion int not null,
  tipo_comprobante varchar(50) not null, --boleta o factura
  fecha_emision date not null,
  fecha_entrada date not null,
  fecha_salida date not null,
  sub_total money not null,
  IGV money not null,
  total money not null,
  CONSTRAINT FK_IDEMPLEADO FOREIGN KEY (id_empleado) REFERENCES empleado,
  CONSTRAINT FK_RESERVACION FOREIGN KEY (id_reservacion) REFERENCES reservacion
)

CREATE TABLE Detalle_Comprobante (
    idDetalle INT IDENTITY (1,1) PRIMARY KEY,
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
    precio_unidad money  ,
    sub_total money  not null,
    IGV money   not null,
    total money   not null,
    importe money not null,
    CONSTRAINT FK_IDEMPLEADO2 FOREIGN KEY (id_empleado) REFERENCES empleado,
    CONSTRAINT FK_RESERVACION2 FOREIGN KEY (id_reservacion) REFERENCES reservacion,
	CONSTRAINT FK_HOTEL FOREIGN KEY (idHotel) REFERENCES Hotel_Empresa,
	CONSTRAINT FK_NUMCOMPROBANTE FOREIGN KEY (num_comprobante) REFERENCES comprobante_alquiler
)

CREATE TABLE login (
  usuario varchar primary key,
  password_usu varchar
)

----------------------------------------------------------------
-- FUNCIONES
--1. obtener el historial de pedidos de un cliente: - VAAAAAAAA
CREATE FUNCTION HistoxReserva(@idcliente INT)
RETURNS TABLE
AS
RETURN
    SELECT idcliente, num_habitacion, fecha_reservacion, cantidad_personas
    FROM reservacion
    WHERE idcliente = @idcliente

SELECT * FROM dbo.HistoxReserva(35)

--2. obtener el historial de empleados por su salario - vaaaaaaaaa
CREATE FUNCTION CEmpleadoxSal (@id_cargo_empleado INT)
RETURNS TABLE
AS
RETURN (
    SELECT * FROM cargo_empleado WHERE id_cargo_empleado = @id_cargo_empleado
);

SELECT * FROM dbo.CEmpleadoxSal(12)

--3. funcion para mostrarnos la informacion de los montos totales de las reservas - vaaaaaa
 create function ReservIf (@inforeser varchar(200) )
 returns varchar(200) 
 as
 begin 
  declare @reserv1 varchar (200)
  select @reserv1 = upper (id_reservacion)+' '+upper(total) from comprobante_alquiler
 return @reserv1
 end;

SELECT dbo.ReservIf(39) AS MontoTotalReserva


--4. obtener el historial de fechas de emision y los totales de un comprobante - VAAAA
CREATE FUNCTION TotalxFec(@num_comprobante INT)
RETURNS TABLE
AS
RETURN
    SELECT num_comprobante, fecha_emision, total
    FROM comprobante_alquiler
    WHERE num_comprobante = @num_comprobante

SELECT * FROM dbo.TotalxFec(20)

-- 5. obtener todos los empleados de un turno - VAAAAA MASO
CREATE FUNCTION Empxturno (@id_empleado INT)
RETURNS TABLE
AS
RETURN
    SELECT id_empleado, nombre, apellido
    FROM empleado
    WHERE id_empleado = @id_empleado

SELECT * FROM dbo.Empxturno(45)

--6. retorna los tipos de habitaciones con solo 2 personas - VAAAAAA
CREATE FUNCTION ObtenerxCanTPer()
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM tipo_habi
    WHERE canti_perso = 2
)
SELECT * FROM dbo.ObtenerxCanTPer()

--7. Retorna los datos de los clientes segun un rango de edad - VAAAAAA
CREATE FUNCTION ObClientesxEdad (@edadMinima INT, @edadMaxima INT)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM cliente
    WHERE edad BETWEEN @edadMinima AND @edadMaxima
)
SELECT * FROM dbo.ObClientesxEdad(23, 30)

--8. retornan el numero de habitacion según el año y mes de la reservacion - VAAA MASO
CREATE FUNCTION ob_num_por_anio_mes(@anio INT, @mes INT)
RETURNS INT
AS
BEGIN
    DECLARE @numhab INT;
    SELECT @numhab = num_habitacion FROM reservacion 
	WHERE YEAR(fecha_reservacion) = @anio AND MONTH(fecha_reservacion) = @mes;
    RETURN @numhab;
END;

SELECT dbo.ob_num_por_anio_mes(2023,06) AS id_obtenido;

--9. retorne los datos de todos los clientes segun su observacion - vaaaaaaa
CREATE FUNCTION ObtenerClientesConObservacion ()
RETURNS TABLE
AS
RETURN (
    SELECT idcliente, nombres
    FROM cliente
    WHERE Observacion = 'Cliente Moroso' 
);

SELECT * FROM dbo.ObtenerClientesConObservacion();

--10. retorne las fechas de entrada y salida de los comprobantes segun su tipo - vaaaaaaa
CREATE FUNCTION ObFechasxTipo ()
RETURNS TABLE
AS
RETURN (
    SELECT fecha_entrada, fecha_salida
    FROM comprobante_alquiler
    WHERE tipo_comprobante = 'Factura' 
);

SELECT * FROM dbo.ObFechasxTipo();


--11. Retorna los estados de las habitaciones segun un rango de costos - VAAAAAA
CREATE FUNCTION ObEstadoxCosto (@costoMin money, @costoMax money)
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM habitacion
    WHERE costo_total BETWEEN @costoMin AND @costoMax
)
SELECT * FROM dbo.ObEstadoxCosto(100.00, 150.00)


--12. Retorna la cantidad total de los comprobantes realizados 
CREATE FUNCTION CantidadxCompro()
returns int
as
begin
	declare @CantidadxCompro INT;

	SELECT @CantidadxCompro = COUNT (*)
	from comprobante_alquiler;
	return @CantidadxCompro;
end;

--12. Retorna el numero de habitacion registrados segun el servicio 
CREATE FUNCTION numhabxServi (@id_servicio) int
returns table
as
return
(
	select h.num_habitacion,h.estado,h.costo_total
	from dbo.habitacion h
	INNER JOIN dbo.servicios_habi s ON id_servicio = h.id_servicio
	WHERE h.id_servicio = @id_servicio
);
SELECT * FROM numhabxServi ();

--13. Retorna el total de ventas realizadas en el hotel
CREATE FUNCTION totalVentasEmpleado (@id_empleado int)
returns money
as
begin
	DECLARE @totalVentas MONEY;

	select @totalVentas = SUM (c.total)
	FROM dbo.comprobante_alquiler c
	WHERE c.id_empleado = @id_empleado;
	
	return @totalVentas
end;

--14. Retorna el total de ventas realizadas en el hotel
alter function clientesxtipohab (@nombre_tipo (10))
returns int
as
begin
	DECLARE @total int
		select @total = COUNT (nombre_tipo) from tipo_habi where @nombre_tipo=nombre_tipo
	return @total
	end
select * from [dbo].[clientesxtipohab] ('Duplex') 'Cantidad de clientes en la habitación Duplex'


--15. Retorna el total de ventas realizadas en el hotel
alter function clientesxtipohab (@nombre_tipo (10))
returns int
as
begin
	DECLARE @total int
		select @total = COUNT (nombre_tipo) from tipo_habi where @nombre_tipo=nombre_tipo
	return @total
	end
select * from [dbo].[clientesxtipohab] ('Personal') 'Cantidad de clientes en la habitación personal'

--16. Retorna el total de habitaciones ocupadas en el hotel
alter function habxestado (@estado (10))
returns int
as
begin
	DECLARE @total int
		select @total = COUNT (estado) from habitacion where @estado=estado
	return @total
	end
select * from [dbo].[habxestado] ('Ocupado') 'Cantidad de habitaciones ocupadas'

--17. Retorna el total de habitaciones en mantenimiento en el hotel
alter function habxestado (@estado (10))
returns int
as
begin
	DECLARE @total int
		select @total = COUNT (estado) from habitacion where @estado=estado
	return @total
	end
select * from [dbo].[habxestado] ('Mantenimiento') 'Cantidad de habitaciones ocupadas'

--18. Retorna el total de habitaciones reservadas en el hotel
alter function habxestado (@estado (10))
returns int
as
begin
	DECLARE @total int
		select @total = COUNT (estado) from habitacion where @estado=estado
	return @total
	end
select * from [dbo].[habxestado] ('Reservado') 'Cantidad de habitaciones reservadas'

--19. Retorna los datos del empleado segun su estado civil
alter function empleadosxturno (@turno varchar (20))
returns table
as
return
	SELECT e.nombre 'Nombre del Empleado',e.apellido 'Apellidos del Empleado',e.dni 'DNI',
	e.correo 'Correo Electrónico',c.nombre_cargo 'Cargo', c.salario_emp 'Salario'
	FROM empleado e INNER JOIN cargo_empleado c ON e.id_cargo_empleado=c.id_cargo_empleado where @estado =estado

SELECT * FROM empleadosxturno ('Soltero')

--20.RETORNAR LOS DATOS DE LAS RESERVACIONES SEGUN LA CANTIDAD DE PERSONAS
alter function reservsxcant (@cant_personas INT)
returns table
as
return
	SELECT r.num_habitacion 'N° DE HABITACION',r.fecha_reservacion 'FECHA RESERVACION',ca.fecha_salida 'FECHA SALIDAD',r.cantidad_personas 'CANTIDAD DE PERSONAS'
	,ca.total 'TOTAL COSTO'
	FROM reservacion r INNER JOIN comprobante_alquiler ca ON r.id_reservacion=ca.id_reservacion where @cant_personas =cantidad_personas

SELECT * FROM reservsxcant ('')

----------------------------------
--SP DE MANTENIMIENTOSS
----------------------------------

--SP PARA MANTENIMIENTO DE HOTEL EMPRESA
create proc usp_Man_Hotel_Empresa
@idH INT,
@RUC int,
@direccion varchar(50),
@distrito varchar (50),
@telefono varchar(10),
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT Hotel_Empresa values (@RUC,@direccion,@distrito,@telefono)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM Hotel_Empresa where idHotel=@idH
		END
	if @opcion=3
		BEGIN
	UPDATE Hotel_Empresa set RUC=@RUC, direccion= @direccion, distrito=@distrito, telefono=@telefono where idHotel=@idH
		END

exec usp_Man_Hotel_Empresa --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE CLIENTE
create proc usp_Man_cliente
@idC INT,
@nombre varchar(100),
@apellido varchar(100),
@dni char (8),
@edad int,
@telefono varchar(12), 
@correo varchar (100),
@observacion varchar (200),
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT cliente values (@nombre,@apellido,@dni,@edad,@telefono,@correo,@observacion)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM cliente where idcliente=@idC
		END
	if @opcion=3
		BEGIN
	UPDATE cliente set nombre=@nombre, apellido= @apellido, dni=@dni, edad=@edad,telefono=@telefono,correo=@correo,observacion=@observacion where idcliente=@idC
		END

exec usp_Man_cliente --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE CARGO EMPLEADO
create proc usp_Man_cargo_empleado
@idCE INT,
@nombre_cargo varchar(50),
@salario_emp money,
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT cargo_empleado values (@nombre_cargo,@salario_emp)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM cargo_empleado where id_cargo_empleado=@idCE
		END
	if @opcion=3
		BEGIN
	UPDATE cargo_empleado set nombre_cargo=@nombre_cargo, salario_emp= @salario_emp where id_cargo_empleado=@idCE
		END

exec usp_Man_cargo_empleado --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE EMPLEADO
create proc usp_Man_empleado
@idE INT,
@nombre varchar(100),
@apellido varchar(100),
@dni char (8),
@edad int,
@telefono varchar(12), 
@correo varchar (100),
@estado varchar (25),
@turno varchar (25),
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT empleado values (@nombre,@apellido,@dni,@edad,@telefono,@correo,@estado,@turno)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM empleado where idempleado=@idE
		END
	if @opcion=3
		BEGIN
	UPDATE empleado set nombre=@nombre, apellido= @apellido, dni=@dni, edad=@edad,telefono=@telefono,correo=@correo,estado=@estado,turno=@turno where idempleado=@idE
		END

exec usp_Man_empleado --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE TIPO HABITACION
create proc usp_Man_tipo_habi
@idTH INT,
@nombre_tipo varchar (50),
@costo_habi money ,
@canti_perso int,
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT tipo_habi values (@nombre_tipo,@costo_habi,@canti_perso)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM tipo_habi where id_tipohabi=@idTH
		END
	if @opcion=3
		BEGIN
	UPDATE tipo_habi set nombre_tipo=@nombre_tipo, costo_habi= @costo_habi,canti_perso=@canti_perso where id_tipohabi=@idTH
		END

exec usp_Man_tipo_habi --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE SERVICIOS HABITACION
create proc usp_Man_servicios_habi
@idSH INT,
@descrip_ser varchar (50) , 
@costo_ser	money ,
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT servicios_habi values (@descrip_ser,@costo_ser)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM servicios_habi where id_servicio=@idSH
		END
	if @opcion=3
		BEGIN
	UPDATE servicios_habi set descrip_ser=@descrip_ser, costo_ser= @costo_ser where id_servicio=@idSH
		END

exec usp_Man_servicios_habi --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE  HABITACION
create proc usp_Man_habitacion
@numH INT,
@numero_piso int ,
@estado varchar(50) , 
@costo_total money ,
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT habitacion values (@numero_piso,@estado,@costo_total)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM habitacion where num_habitacion=@numH
		END
	if @opcion=3
		BEGIN
	UPDATE habitacion set numero_piso=@numero_piso, estado= @estado,costo_total=@costo_total where num_habitacion=@numH
		END

exec usp_Man_habitacion --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE RESERVACION
create proc usp_Man_reservacion
@idR INT,
@numero_piso int ,
@fecha_reservacion date not null,
@cantidad_personas int not null,
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT reservacion values (@numero_piso,@fecha_reservacion,@cantidad_personas)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM reservacion where id_reservacion=@idR
		END
	if @opcion=3
		BEGIN
	UPDATE reservacion set numero_piso=@numero_piso, fecha_reservacion= @fecha_reservacion,cantidad_personas=@cantidad_personas where id_reservacion=@idR
		END

exec usp_Man_reservacion --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE comprobantealquiler
create proc usp_Man_comprobante_alquiler
@num_compro INT,
@tipo_comprobante varchar(50) not null, 
@fecha_emision date not null,
@fecha_entrada date not null,
@fecha_salida date not null,
@sub_total money not null,
@IGV money not null,
@total money not null,
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT comprobante_alquiler values (@tipo_comprobante,@fecha_emision,@fecha_entrada,@fecha_salida,@sub_total,@IGV,@total)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM comprobante_alquiler where num_comprobante=@num_compro
		END
	if @opcion=3
		BEGIN
	UPDATE comprobante_alquiler set tipo_comprobante=@tipo_comprobante, fecha_emision= @fecha_emision, fecha_entrada=@fecha_entrada
	, fecha_salida=@fecha_salida,sub_total=@sub_total,IGV=@IGV,total=@total where num_comprobante=@num_compro
		END

exec usp_Man_comprobante_alquiler --valores de datos '','','','',''

--SP PARA MANTENIMIENTO DE Detalle Comprobante
create proc usp_Man_Detalle_Comprobante
@idD INT,
@num_comprobante int ,
@fecha_emision datetime ,
@fecha_entrada date ,
@fecha_salida date,
@cantidad int,
@Observacion varchar(100),
@precio_unidad money,
@sub_total money,
@IGV money ,
@total money,
@importe money ,
@opcion int
as
	if @opcion=1
		BEGIN
	INSERT Detalle_Comprobante values (@num_comprobante,@fecha_emision,@fecha_entrada,@fecha_salida,@cantidad,@Observacion,@precio_unidad,@sub_total,@IGV,@total,@importe)
		END
	else
		if @opcion=2
		BEGIN
	DELETE FROM Detalle_Comprobante where idDetalle=@idD
		END
	if @opcion=3
		BEGIN
	UPDATE Detalle_Comprobante set num_comprobante=@num_comprobante, fecha_emision= @fecha_emision, fecha_entrada=@fecha_entrada
	, fecha_salida=@fecha_salida,cantidad=@cantidad,Observacion=@Observacion,precio_unidad=@precio_unidad
	,sub_total=@sub_total,IGV=@IGV,total=@total, importe=@importe where idDetalle=@idD
		END

exec usp_Man_Detalle_Comprobante --valores de datos '','','','',''

----------------------------------------------------------------

/*SP con parámetros de tipo OUTPUT*/
--tabla cliente PARAMETROS DE SALIDA 
CREATE PROCEDURE usp_obtener_cliente
  @idcliente INT,
  @nombre varchar(100) OUTPUT,
  @apellido varchar(100) OUTPUT,
  @dni char(8) OUTPUT,
  @edad int OUTPUT,
  @telefono varchar(12) OUTPUT,
  @correo varchar(100) OUTPUT,
  @observacion varchar(200) OUTPUT
AS
BEGIN
  SELECT @nombre = nombre,
         @apellido = apellido,
         @dni = dni,
         @edad = edad,
         @telefono = telefono,
         @correo = correo,
         @observacion = observacion
  FROM cliente
  WHERE idcliente = @idcliente;
END;

	DECLARE @nombre_cliente varchar(100), @apellido_cliente varchar(100),
        @dni_cliente char(8), @edad_cliente int, @telefono_cliente varchar(12), 
        @correo_cliente varchar(100), @observacion_cliente varchar(200);

	EXEC usp_obtener_cliente @idcliente = 1, @nombre = @nombre_cliente OUTPUT, 
		 @apellido = @apellido_cliente OUTPUT, @dni = @dni_cliente OUTPUT,
		 @edad = @edad_cliente OUTPUT, @telefono = @telefono_cliente OUTPUT, 
			@correo = @correo_cliente OUTPUT, @observacion = @observacion_cliente OUTPUT;

PRINT @nombre_cliente;
PRINT @apellido_cliente;
PRINT @dni_cliente;
PRINT @edad_cliente;
PRINT @telefono_cliente;
PRINT @correo_cliente;
PRINT @observacion_cliente;


--tabla EMPLEADO PARAMETROS DE SALIDA 
CREATE PROCEDURE usp_obtener_empleado
  @id_empleado INT,
  @nombre varchar(50) OUTPUT,
  @apellido varchar(50) OUTPUT,
  @dni varchar(8) OUTPUT,
  @edad int OUTPUT,
  @telefono varchar(12) OUTPUT,
  @correo varchar(100) OUTPUT,
  @estado varchar(25) OUTPUT,
  @turno varchar(25) OUTPUT
AS
BEGIN
  SELECT @nombre = nombre,
         @apellido = apellido,
         @dni = dni,
         @edad = edad,
         @telefono = telefono,
         @correo = correo,
         @estado = estado,
         @turno = turno
  FROM empleado
  WHERE id_empleado = @id_empleado;
END;

DECLARE @nombre_empleado varchar(50), @apellido_empleado varchar(50),
        @dni_empleado varchar(8), @edad_empleado int, @telefono_empleado varchar(12), 
        @correo_empleado varchar(100), @estado_empleado varchar(25), @turno_empleado varchar(25);

EXEC usp_obtener_empleado @id_empleado = 1, @nombre = @nombre_empleado OUTPUT, 
        @apellido = @apellido_empleado OUTPUT, @dni = @dni_empleado OUTPUT,
        @edad = @edad_empleado OUTPUT, @telefono = @telefono_empleado OUTPUT, 
        @correo = @correo_empleado OUTPUT, @estado = @estado_empleado OUTPUT, 
        @turno = @turno_empleado OUTPUT;

PRINT @nombre_empleado;
PRINT @apellido_empleado;
PRINT @dni_empleado;
PRINT @edad_empleado;
PRINT @telefono_empleado;
PRINT @correo_empleado;
PRINT @estado_empleado;
PRINT @turno_empleado;


--tabla HABITACION PARAMETROS DE SALIDA 
CREATE PROCEDURE usp_obtener_habitacion
  @num_habitacion int,
  @id_servicio int OUTPUT,
  @id_tipohabi int OUTPUT,
  @numero_piso int OUTPUT,
  @estado varchar(50) OUTPUT,
  @costo_total money OUTPUT
AS
BEGIN
  SELECT @id_servicio = id_servicio,
         @id_tipohabi = id_tipohabi,
         @numero_piso = numero_piso,
         @estado = estado,
         @costo_total = costo_total
  FROM habitacion
  WHERE num_habitacion = @num_habitacion;
END;

DECLARE @id_servicio_habitacion int, @id_tipohabi_habitacion int,
        @numero_piso_habitacion int, @estado_habitacion varchar(50), @costo_total_habitacion money;

EXEC usp_obtener_habitacion @num_habitacion = 1, @id_servicio = @id_servicio_habitacion OUTPUT,
        @id_tipohabi = @id_tipohabi_habitacion OUTPUT, @numero_piso = @numero_piso_habitacion OUTPUT,
        @estado = @estado_habitacion OUTPUT, @costo_total = @costo_total_habitacion OUTPUT;

PRINT @id_servicio_habitacion;
PRINT @id_tipohabi_habitacion;
PRINT @numero_piso_habitacion;
PRINT @estado_habitacion;
PRINT @costo_total_habitacion;

--tabla reservacion PARAMETROS DE SALIDA 
CREATE PROCEDURE usp_obtener_reservacion
  @id_reservacion int,
  @id_empleado int OUTPUT,
  @idcliente int OUTPUT,
  @num_habitacion int OUTPUT,
  @id_servicio int OUTPUT,
  @id_tipohabi int OUTPUT,
  @fecha_reservacion date OUTPUT,
  @cantidad_personas int OUTPUT
AS
BEGIN
  SELECT @id_empleado = id_empleado,
         @idcliente = idcliente,
         @num_habitacion = num_habitacion,
         @id_servicio = id_servicio,
         @id_tipohabi = id_tipohabi,
         @fecha_reservacion = fecha_reservacion,
         @cantidad_personas = cantidad_personas
  FROM reservacion
  WHERE id_reservacion = @id_reservacion;
END;

DECLARE @id_empleado_reservacion int, @idcliente_reservacion int,
        @num_habitacion_reservacion int, @id_servicio_reservacion int,
        @id_tipohabi_reservacion int, @fecha_reservacion_reservacion date,
        @cantidad_personas_reservacion int;

EXEC usp_obtener_reservacion @id_reservacion = 1, @id_empleado = @id_empleado_reservacion OUTPUT,
        @idcliente = @idcliente_reservacion OUTPUT, @num_habitacion = @num_habitacion_reservacion OUTPUT,
        @id_servicio = @id_servicio_reservacion OUTPUT, @id_tipohabi = @id_tipohabi_reservacion OUTPUT,
        @fecha_reservacion = @fecha_reservacion_reservacion OUTPUT,
        @cantidad_personas = @cantidad_personas_reservacion OUTPUT;

PRINT @id_empleado_reservacion;
PRINT @idcliente_reservacion;
PRINT @num_habitacion_reservacion;
PRINT @id_servicio_reservacion;
PRINT @id_tipohabi_reservacion;
PRINT @fecha_reservacion_reservacion;
PRINT @cantidad_personas_reservacion;



/***************************************************************************************************/
/***************************************************************************************************/
/***************************************************************************************************/

/*SP con parámetros con valor por default*/
--creando el SP con algunos parámetros con valores por DEFAULT
--PARA LA TABLA EMPLEADO
CREATE PROCEDURE usp_mant_empleado
  @id_empleado INT,
  @id_cargo_empleado INT = NULL,
  @nombre varchar(50) = NULL,
  @apellido varchar(50) = NULL,
  @dni varchar(8) = NULL,
  @edad int = NULL,
  @telefono varchar(12) = NULL,
  @correo varchar(100) = NULL,
  @estado varchar(25) = NULL,
  @turno varchar(25) = NULL,
  @opcion int = NULL
AS
BEGIN
  IF @opcion = 1
  BEGIN
    SET IDENTITY_INSERT empleado ON;
    INSERT INTO empleado (id_empleado, id_cargo_empleado, nombre, apellido, dni, edad, telefono, correo, estado, turno)
    VALUES (@id_empleado, @id_cargo_empleado, @nombre, @apellido, @dni, @edad, @telefono, @correo, @estado, @turno);
    SET IDENTITY_INSERT empleado OFF;
  END
  ELSE IF @opcion = 2
  BEGIN
    DELETE FROM empleado WHERE id_empleado = @id_empleado;
  END
  ELSE IF @opcion = 3
  BEGIN
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
  END;
END;
	
select * from empleado
exec usp_mant_empleado @id_empleado=1,@opcion=1

--creando el SP con algunos parámetros con valores por DEFAULT
--PARA LA TABLA HABITACION
CREATE PROCEDURE usp_mant_habitacion
  @num_habitacion int,
  @id_servicio int = null,
  @id_tipohabi int = null,
  @numero_piso int = null,
  @estado varchar(50) = null,
  @costo_total money = null,
  @opcion int = null
AS

BEGIN
  IF @opcion = 1
  BEGIN
    INSERT INTO habitacion (num_habitacion, id_servicio, id_tipohabi, numero_piso, estado, costo_total)
    VALUES (@num_habitacion, @id_servicio, @id_tipohabi, @numero_piso, @estado, @costo_total);
  END


	 ELSE IF @opcion = 2
	 BEGIN
		 DELETE FROM habitacion WHERE num_habitacion = @num_habitacion;
	 END

		ELSE IF @opcion = 3
		BEGIN
    UPDATE habitacion
    SET id_servicio = @id_servicio,
        id_tipohabi = @id_tipohabi,
        numero_piso = @numero_piso,
        estado = @estado,
        costo_total = @costo_total
    WHERE id_servicio = @id_servicio;
  END;
END;

select * from habitacion
exec usp_mant_habitacion @num_habitacion=1,@opcion=1

--creando el SP con algunos parámetros con valores por DEFAULT
--PARA LA TABLA CLIENTE
CREATE PROCEDURE usp_mant_cliente
  @idcliente INT,
  @nombre varchar = null,
  @apellido varchar = null,
  @dni char = null,
  @edad int = null,
  @telefono varchar(12) = null,
  @correo varchar(100) = null,
  @observacion varchar(200) = null,
  @opcion int = null
AS


BEGIN
 
 
	IF @opcion = 1
		BEGIN
			 SET IDENTITY_INSERT cliente ON;
			 INSERT INTO cliente (idcliente, nombre, apellido, dni, edad, telefono, correo, observacion)
			 VALUES (@idcliente, @nombre, @apellido, @dni, @edad, @telefono, @correo, @observacion);
    SET IDENTITY_INSERT cliente OFF;
  END

	ELSE IF @opcion = 2
		BEGIN
			 DELETE FROM cliente WHERE idcliente = @idcliente;
	END
 
	ELSE IF @opcion = 3
		 BEGIN

    UPDATE cliente
    SET nombre = @nombre,
        apellido = @apellido,
        dni = @dni,
        edad = @edad,
        telefono = @telefono,
        correo = @correo,
        observacion = @observacion
    WHERE nombre = @nombre;
  END;
END;

select * from cliente
exec usp_mant_cliente @idcliente=1,@opcion=1

----------------------------------------------------------------

-- SP EJECUCION POR POSICION

-- usp_InsertarHotelEmpresa
EXEC usp_InsertarHotelEmpresa 123456789, 'Calle Principal 123', 'Lima', '1234567890';

-- usp_InsertarCliente
EXEC usp_InsertarCliente 'John', 'Doe', '12345678', 30, '991068231', 'john.doe@example.com', 'Observación del cliente';

--usp_InsertarCargoEmpleado
EXEC usp_InsertarCargoEmpleado 'Gerente', 5000.00;

--usp_InsertarEmpleado
EXEC usp_InsertarEmpleado 1, 'Juan', 'Pérez', '12345678', 25, '987654321', 'juan.perez@example.com', 'Soltero', 'Turno mañana';

--usp_InsertarTipoHabi
EXEC usp_InsertarTipoHabi 'Duplex', 200.00, 2;

-- SP EJECUCION POR NOMBRE

--usp_InsertarHotelEmpresa
EXEC usp_InsertarHotelEmpresa @RUC = 987654321, @direccion = 'Calle Secundaria 456', @distrito = 'Lima', @telefono = '0987654321';

--usp_InsertarCliente
EXEC usp_InsertarCliente @nombre = 'Jane', @apellido = 'Smith', @dni = '87654321', @edad = 28, @telefono = '912345678', @correo = 'jane.smith@example.com', @observacion = 'Observación de la cliente';

--usp_InsertarCargoEmpleado
EXEC usp_InsertarCargoEmpleado @nombre_cargo = 'Recepcionista', @salario_emp = 3000.00;

--usp_InsertarEmpleado
EXEC usp_InsertarEmpleado @id_cargo_empleado = 2, @nombre = 'Pedro', @apellido = 'Gómez', @dni = '65432109', @edad = 32, @telefono = '945678321', @correo = 'pedro.gomez@example.com', @estado = 'Soltero', @turno = 'Turno tarde';

--usp_InsertarTipoHabi
EXEC usp_InsertarTipoHabi @nombre_tipo = 'Personal', @costo_habi = 150.00, @canti_perso = 1;


----------------------------------------------------------------

