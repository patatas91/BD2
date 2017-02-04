
CREATE TABLE clientes(
	dni number(8),
	nombre varchar(30) NOT NULL,
	apellidos varchar(60) NOT NULL,
	direccion varchar(80) NOT NULL,
	email varchar(60) DEFAULT NULL,
	telefono number(9) NOT NULL,
	fechaNacimiento date NOT NULl,
	CONSTRAINT pk_cliente PRIMARY KEY(dni)
);

CREATE TABLE oficinas(
	idOficina number(4),
	direccion varchar(80) NOT NULL,
	telefono number(9) NOT NULL,
	CONSTRAINT pk_oficina PRIMARY KEY(idOficina)
);

CREATE TABLE cuentas(
	nCuenta number(20),
	fecha date NOT NULL,
	saldo float DEFAULT 0,
	tipo number(1), -- 0 = cuenta corriente, 1 = cuenta ahorro
	interes float DEFAULT NULL,
	idOficina number(4) DEFAULT NULL,
	CONSTRAINT pk_cuenta PRIMARY KEY(nCuenta),
	CONSTRAINT fk_oficinaDeCuenta FOREIGN KEY(idOficina) REFERENCES oficinas(idOficina)
);

CREATE TABLE operaciones(
	nOperacion number(20),
	fechaHora timestamp NOT NULL,
	cantidad float NOT NULL,
	tipoOp number(1) NOT NULL, -- 0 = tranferencia, 1 = ingreso, 2 = retirada,
	descripcion varchar(200), 
	idOficina number(4),
	origen number(20),
	destino number(20) DEFAULT NULL,
	CONSTRAINT fk_origen	FOREIGN KEY(origen) REFERENCES  cuentas(nCuenta),
	CONSTRAINT fk_destino	FOREIGN KEY(destino) REFERENCES cuentas(nCuenta),
	CONSTRAINT fk_oficina	FOREIGN KEY(idOficina) REFERENCES oficinas(idOficina),
	CONSTRAINT pk_operacion PRIMARY KEY(nOperacion)
);

CREATE TABLE poseer(
	dni number(8),
	nCuenta number(20),
	CONSTRAINT pk_poseer PRIMARY KEY(dni, nCuenta),
	CONSTRAINT fk_cliente FOREIGN KEY (dni) REFERENCES clientes(dni),
	CONSTRAINT fk_cuenta FOREIGN KEY (nCuenta) REFERENCES cuentas(nCuenta)
);

/* Vistas para facilitar las consultas */
CREATE VIEW cuentas_corrientes AS 
SELECT nCuenta, fecha,saldo,idOficina FROM cuentas WHERE tipo = 0;

CREATE VIEW cuentas_ahorro AS 
SELECT nCuenta,fecha,saldo,interes FROM cuentas WHERE tipo = 1;

CREATE VIEW transferencia AS 
SELECT nOperacion,fechaHora,cantidad,descripcion,origen,destino FROM operaciones WHERE tipoOp = 0;

CREATE VIEW retirada AS 
SELECT origen,nOperacion,fechaHora,cantidad,descripcion,idOficina FROM operaciones WHERE tipoOp = 1;

CREATE VIEW ingreso AS 
SELECT origen,nOperacion,fechaHora,cantidad,descripcion,idOficina FROM operaciones WHERE tipoOp = 2;


CREATE TRIGGER actualizar_saldo
AFTER INSERT ON operaciones
FOR EACH ROW
DECLARE
PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
	/* Si es una transferencia(op==0) */
	IF: NEW.tipoOp = 0 THEN
	/* Actualiza saldo de las cuentas origen y destino al llevar a cabo la transferencia*/
	UPDATE cuentas SET saldo = saldo - :NEW.cantidad WHERE nCuenta = :NEW.origen;
	UPDATE cuentas SET saldo = saldo + :NEW.cantidad WHERE nCuenta = :NEW.destino;

	/* Si se trata de un ingreso*/
	ELSIF :NEW.tipoOp = 1 THEN
	UPDATE cuentas SET saldo = saldo + :NEW.cantidad WHERE nCuenta = :NEW.origen ;
	END IF;

	/* Si se trata de una retirada */

	ELSIF :NEW.tipoOp = 2 THEN
	UPDATE cuenta SET saldo = saldo - :NEW.cantidad WHERE nCuenta = :NEW.origen;

	END IF;

	COMMIT;


END;

/
