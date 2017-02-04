CREATE VIEW cliente AS
SELECT dni,nombre,apellidos,null as apellido2,direccion,email,telefono,fechaNacimiento
	FROM clientes
	UNION
	SELECT dni, nombre, apellido1, apellido2, direccion, null as mail, telefono,fecha_nacimiento
	FROM titular@schema2bd2;

CREATE VIEW cuentacorriente AS
SELECT nCuenta as ccc, fecha as fechacreacion, saldo, idOficina as sucursal_codoficina
	FROM cuentas
	WHERE tipo = 0	
	UNION
	SELECT c.ccc, c.fechacreacion, c.saldo, cc.sucursal_codoficina
	FROM cuenta@schema2bd2 c, cuentacorriente@schema2bd2 cc
	WHERE c.ccc = cc.ccc;

CREATE VIEW cuentaahorro AS
SELECT nCuenta as ccc, fecha as fechacreacion, saldo, interes as tipointeres
	FROM cuentas_ahorro
	WHERE tipo = 1	
	UNION
	SELECT c.ccc, c.fechacreacion, c.saldo, ca.tipointeres
	FROM cuenta@schema2bd2 c, cuentaahorro@schema2bd2 ca
	WHERE c.ccc = ca.ccc;	
	
	
CREATE VIEW sucursal AS
SELECT idOficina, direccion, telefono
	FROM  oficinas
	UNION
	SELECT codoficina, dir, tfno
	FROM  sucursal@schema2bd2
	WHERE codoficina NOT IN(SELECT idOficina
						FROM  oficinas);


CREATE VIEW opefectivo AS
 SELECT origen, nOperacion, NULL as tipoopefectivo, fecha, hora, descripcion, cantidad, idOficina
	FROM operaciones
	WHERE tipoOp = 1 AND tipoOp = 2
	 UNION
	SELECT oe.ccc, oe.numop, oe.tipoopefectivo, o.fechaop, o.horaop, o.descripcionop,
     o.cantidadop, oe.sucursal_codoficina
	FROM  opefectivo@schema2bd2 oe,  operacion@schema2bd2 o
	WHERE oe.ccc = o.ccc AND o.numop = oe.numop;

CREATE VIEW optransferencia AS
SELECT origen, destino, nOperacion, fecha, hora, descripcion, cantidad
	FROM  operaciones
	WHERE tipoOp = 0
	UNION
	SELECT ot.ccc, ot.cuentadestino, ot.numop, o.fechaop, o.horaop, o.descripcionop, o.cantidadop
	FROM  optransferencia@schema2bd2 ot,  operacion@schema2bd2 o
	WHERE ot.ccc = o.ccc AND o.numop = ot.numop;

CREATE VIEW poseers AS
SELECT dni, nCuenta as ccc
	FROM poseer
	UNION
	SELECT cli.dni, c.ccc
	FROM titular@schema2bd2 cli,  cuenta@schema2bd2 c
	WHERE cli.dni = dni AND c.ccc = ccc;

CREATE VIEW codentidades AS
SELECT banco, codigo
	FROM  codentidades@schema2bd2;

CREATE VIEW codpostal AS
 SELECT calle, ciudad, codpostal
	FROM  codpostal@schema2bd2;