CREATE VIEW trabajadores AS(
	SELECT * FROM empleado UNION SELECT * FROM dblink('dbname=transporte1', 'SELECT dni,nombre,apellidos,direccion,telefono,poblacion from empleado') AS (dni decimal(8), nombre varchar(50), apellidos varchar(100), direccion varchar(250),telefono numeric(9), poblacion varchar(40));
	UNION SELECT * FROM dblink('dbname=transporte1',
	'SELECT dni,nombre,apellidos,direccion,telefono,poblacion from empleado') 
	AS tmp_trabajador(dni decimal(8), nombre varchar(50), apellidos varchar(100), direccion varchar(250),
	telefono numeric(9),fechaNacimiento date)
);
-- Camiones tipoTransporte = 3
CREATE VIEW flotaCamiones AS(
	SELECT matricula,modeloCamion FROM transporte WHERE tipoTransporte = 3 
	UNION SELECT * FROM dblink('dbname=transporte1', 
	'SELECT matricula,modelo from camion') 
	AS  tmp_camion(matricula varchar(7) , modelo varchar(80))
);

-- Aviones tipoTransporte = 1
CREATE VIEW aviones AS (
	SELECT idTransporte,matricula,pesoMaximo,modeloAvion FROM transporte WHERE tipoTransporte = 1
);

-- Barcos tipoTransporte = 2
CREATE VIEW barcos AS (
	SELECT idTransporte,matricula,pesoMaximo,modeloBarco FROM transporte WHERE tipoTransporte = 2
);


CREATE VIEW pedidos AS(
	SELECT codigoPedido,remite,descripcion,destinatario,direccion FROM pedido 
	UNION SELECT * FROM dblink('dbname=transporte1', 
	'SELECT codigo,origen,descripcion,destinatario,direccion from pedido') 
	AS tmp_pedido(codigoPedido decimal(8), remite varchar(20), descripcion varchar(50), destinatario varchar(20), direccion varchar(50))
);

--tipo desdino = 1 nacional
CREATE VIEW destinosNacionales AS(
	SELECT codigoDestino,provincia FROM destino WHERE tipoDestino = 1
	UNION SELECT * FROM dblink ('dbname=transporte1',
		'SELECT codigoProvincia,nombre FROM provincia ')
	AS tmp_destinoInternacional(codigosProvincias decimal(8), provincia varchar(50))
);

-- tipo destino = 1 internacional

CREATE VIEW destinosInternacionales AS(
	SELECT pais,provincia,poblacion from destino WHERE tipoDestino = 0
);
