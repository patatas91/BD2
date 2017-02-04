CREATE SCHEMA schema1;
SET SCHEMA schema1;

CREATE TYPE cliente_udt AS(
    dni numeric(8),
    nombre varchar(30),
    apellidos varchar(60),
    direccion varchar(80),
    email varchar(80),
    telefono numeric(9),
    fechNacimiento date)
REF USING INT MODE DB2SQL;

CREATE TABLE cliente of schema1.cliente_udt(
	REF IS oid USER GENERATED,
	dni WITH OPTIONS NOT NULL,
	nombre WITH OPTIONS NOT NULL,
	apellidos WITH OPTIONS NOT NULL,
	direccion WITH OPTIONS NOT NULL,
	telefono WITH OPTIONS NOT NULL,
	fechNacimiento WITH OPTIONS NOT NULL,
	CONSTRAINT pk_cliente PRIMARY KEY(dni));

CREATE SEQUENCE clienteOid AS REF(schema1.cliente_udt;

CREATE TRIGGER Gen_cliente_oid
	NO CASCADE
	BEFORE INSERT ON cliente
	REFERENCING NEW AS new
	FOR EACH ROW
	MODE DB2SQL
	SET new.oid = NEXT VALUE FOR clienteOid;

CREATE TYPE oficina_udt AS(
    codigo numeric(4),
    direccion varchar(80),
    telefono numeric(9))
REF USING INT MODE DB2SQL;

CREATE TABLE schema1.oficina OF schema1.oficina_udt(
	REF IS oid USER GENERATED,
	codigo WITH OPTIONS NOT NULL,
	direccion WITH OPTIONS NOT NULL,
	telefono WITH OPTIONS NOT NULL,
	CONSTRAINT pk_oficina PRIMARY KEY(codigo));

CREATE SEQUENCE oficinaOid AS REF(schema1.oficina_udt);

CREATE TRIGGER Gen_oficina_oid
	NO CASCADE
	BEFORE INSERT ON oficina
	REFERENCING NEW AS new
	FOR EACH ROW
	MODE DB2SQL
	SET new.oid = NEXT VALUE FOR oficinaOid;


CREATE TYPE cuenta_udt AS(
   	nCuenta numeric(20),
  	fecha date,
	saldo real,
  	tipo numeric(1),
	interes numeric(3,3),
	codigo numeric(4))
REF USING INT MODE DB2SQL;

CREATE TABLE schema1.cuenta OF schema1.cuenta_udt(
	REF IS oid USER GENERATED,
	nCuenta WITH OPTIONS NOT NULL,
	fecha WITH OPTIONS NOT NULL DEFAULT CURRENT_DATE,
	saldo WITH OPTIONS DEFAULT 0,
    	CONSTRAINT pk_cuenta PRIMARY KEY(nCuenta),
	CONSTRAINT fk_cc_oficina FOREIGN KEY (codigo) REFERENCES oficina(codigo),
	CONSTRAINT interes_check CHECK(interes IS NULL OR interes>0 OR interes <=100),
	CONSTRAINT tipoCuenta_check CHECK(tipo IS NOT NULL AND ((tipo=0 AND codigo IS NOT NULL AND interes IS NULL) OR (tipo=1 AND interes IS NOT NULL AND codigo IS NULL))));

CREATE SEQUENCE cuentaOid AS REF(schema1.cuenta_udt);

CREATE TRIGGER Gen_cuenta_oid
	NO CASCADE
	BEFORE INSERT ON cuenta
	REFERENCING NEW AS new
	FOR EACH ROW
	MODE DB2SQL
	SET new.oid = NEXT VALUE FOR cuentaOid;


CREATE TYPE operacion_udt AS(
	nCuenta_origen numeric(20),
	num_operacion numeric(6),
	fecha date,
	descripcion varchar(250),
	cantidad real,
	tipo numeric(1),
	nCuenta_dst numeric(20),
	codigo numeric(4))
REF USING INT MODE DB2SQL;

CREATE SEQUENCE numOperacion_seq AS INT 
   START WITH 1 
   INCREMENT BY 1 
   MINVALUE 1 
   NO MAXVALUE 
   NO CYCLE 
   NO CACHE 
   ORDER;

CREATE TABLE schema1.operacion OF schema1.operacion_udt(
	REF IS oid USER GENERATED,
	nCuenta_origen WITH OPTIONS NOT NULL,
	num_operacion WITH OPTIONS NOT NULL, 	
	fecha WITH OPTIONS NOT NULL DEFAULT CURRENT_DATE,
	cantidad WITH OPTIONS NOT NULL,
	CONSTRAINT pk_operacion PRIMARY KEY(nCuenta_origen, num_operacion),
	CONSTRAINT fk_nCuenta_origen FOREIGN KEY(nCuenta_origen) REFERENCES schema1.cuenta(nCuenta),
	CONSTRAINT fk_codigo_op FOREIGN KEY(codigo) REFERENCES schema1.oficina(codigo),
	CONSTRAINT fk_nCuenta_dst FOREIGN KEY(nCuenta_dst) REFERENCES schema1.cuenta(nCuenta),
	CONSTRAINT cantidad_check CHECK(cantidad>0),
	CONSTRAINT tipo_op_check CHECK(tipo IS NOT NULL AND ((tipo=0 AND codigo IS NOT NULL AND nCuenta_dst IS NULL) OR (tipo=1 AND nCuenta_dst IS NOT NULL AND codigo IS NULL))));

CREATE TRIGGER operacion_autoseq 
	NO CASCADE 
	BEFORE INSERT ON operacion 
	REFERENCING NEW AS new_operacion 
	FOR EACH ROW MODE DB2SQL 
	SET new_operacion.num_operacion = NEXT VALUE FOR numOperacion_seq;

CREATE SEQUENCE operacionOid AS REF(schema1.operacion_udt);

CREATE TRIGGER Gen_operacion_oid
	NO CASCADE
	BEFORE INSERT ON operacion
	REFERENCING NEW AS new
	FOR EACH ROW
	MODE DB2SQL
	SET new.oid = NEXT VALUE FOR operacionOid;



CREATE TYPE poseer_udt AS(
	cliente numeric(8),
	nCuenta numeric(20))
REF USING INT MODE DB2SQL;

CREATE TABLE poseer OF schema1.poseer_udt(
	REF IS oid USER GENERATED,
	cliente WITH OPTIONS NOT NULL,
	nCuenta WITH OPTIONS NOT NULL,
	CONSTRAINT pk_poseer PRIMARY KEY(cliente,nCuenta),
	CONSTRAINT fk_cliente_poseer FOREIGN KEY(cliente) REFERENCES cliente(dni),
	CONSTRAINT fk_cuenta_poseer FOREIGN KEY(nCuenta) REFERENCES cuenta(nCuenta));

CREATE SEQUENCE poseerOid AS REF(schema1.poseer_udt);

CREATE TRIGGER Gen_poseer_oid
	NO CASCADE
	BEFORE INSERT ON poseer
	REFERENCING NEW AS new
	FOR EACH ROW
	MODE DB2SQL
	SET new.oid = NEXT VALUE FOR poseerOid;
