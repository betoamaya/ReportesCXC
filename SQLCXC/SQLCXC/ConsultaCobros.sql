/*Variables de envio*/
DECLARE @Empresa AS CHAR(3),
        @dInicio AS DATE,
        @dFin AS DATE,
        @Cliente AS VARCHAR(20) = NULL;

/*Datos que llevaran*/
SELECT @Empresa = 'TUN',
       @dInicio = '2018-11-01',
       @dFin = '2018-11-30',
       @Cliente = NULL;

/*Variables de Trabajo*/
DECLARE @Origen AS VARCHAR(50),
        @OrigenId VARCHAR(20),
        @dFechaD AS DATETIME,
        @dFechaA AS DATETIME;

SELECT @dFechaD = CONVERT(VARCHAR, @dInicio, 101) + ' 00:00:00',
       @dFechaA = CONVERT(VARCHAR, @dFin, 101) + ' 23:59:59';

/*Inicia Consulta de Cobros*/
/*
SELECT c.Cliente,
       c2.Nombre,
       c.FechaEmision AS FechaCobro,
       cd.Importe * c.TipoCambio AS Importe,
       c3.FechaEmision AS 'FechaFactura',
       CASE c.Mov
           WHEN 'Nota Credito SIVE' THEN
               '101-010-101'
           WHEN 'Nota Credito Pasajes' THEN
               '101-010-102'
           --     WHEN 'Cobro Gto Comun' THEN '101-015-105'
           WHEN 'Cobro Permisionario' THEN
               '101-015-200'
           WHEN 'Devolucion Venta' THEN
               '101-015-200'

           --    WHEN 'Aplicacion' THEN '101-010-101'
           ELSE
       (
           SELECT c4.Cuenta
           FROM dbo.Concepto AS c4
           WHERE c.Concepto = c4.Concepto
                 AND c4.Modulo = 'CXC'
       )
       END AS Cuenta,
       c.Mov,
       c.MovID,
       cd.Aplica,
       cd.AplicaID,
       '' AS Origen,
       '' AS OrigenID,
       NULL AS OrigenFecha,
       ISNULL(c3.Saldo, 0) AS Saldo
FROM dbo.Cxc AS c
    INNER JOIN dbo.CxcD AS cd
        ON cd.ID = c.ID
           AND cd.Aplica <> 'Prestamo'
    INNER JOIN dbo.MovTipo AS mt
        ON mt.Mov = c.Mov
           AND mt.Modulo = 'CXC'
    INNER JOIN dbo.Cte AS c2
        ON c2.Cliente = c.Cliente
    INNER JOIN dbo.Cxc AS c3
        ON c3.Mov = cd.Aplica
           AND c3.MovID = cd.AplicaID
           AND c3.Empresa = c.Empresa
           AND c3.Estatus NOT IN ( 'CANCELADO', 'SINAFECTAR' )
WHERE c.Empresa = @Empresa
      AND c.Estatus NOT IN ( 'CANCELADO', 'SINAFECTAR' )
      AND c.FechaEmision
      BETWEEN @dFechaD AND @dFechaA
      AND c.Mov NOT IN ( 'Cobro Gto Comun', 'Nota Credito' )
      AND c.Cliente = ISNULL(@Cliente, c.Cliente)
      AND (
              mt.Clave = 'CXC.C'
              AND EXISTS
(
    SELECT 1
    FROM Concepto
    WHERE ISNULL(c.Concepto, '') = Concepto
          AND Modulo = 'CXC'
          AND Cuenta IN ( '101-010-101', '101-010-102', '101-010-202', '101-010-301', '101-010-201', '101-010-203',
                          '101-010-302', '101-010-303', '101-010-401', '101-015-200', '101-015-300', '101-020-200',
                          '101-020-300', '101-010-311', '101-010-312', '101-015-106', '101-015-108'
                        )
)
              OR mt.Clave = 'CXC.NC'
              OR c.Mov = 'Cobro Permisionario'
          )
UNION ALL*/
SELECT *
FROM dbo.Cxc AS c
    INNER JOIN dbo.CxcD AS cd
        ON cd.ID = c.ID
           AND cd.Aplica <> 'Prestamo'
    INNER JOIN dbo.MovTipo AS mt
        ON mt.Mov = c.Mov
           AND mt.Modulo = 'CXC'
           AND mt.Clave = 'CXC.ANC'
    INNER JOIN dbo.Cte AS c2
        ON c2.Cliente = c.Cliente
    INNER JOIN dbo.Cxc AS c3
        ON c3.Mov = cd.Aplica
           AND c3.MovID = cd.AplicaID
           AND c3.Empresa = c.Empresa
           AND c3.Estatus NOT IN ( 'CANCELADO', 'SINAFECTAR' )
WHERE c.Empresa = @Empresa
      AND c.Estatus NOT IN ( 'CANCELADO', 'SINAFECTAR' )
      AND (
              c.Mov IN ( 'Aplicacion', 'Aplicacion Act Fijo' )
              OR EXISTS
(
    SELECT 1
    FROM Concepto
    WHERE ISNULL(c.Concepto, '') = Concepto
          AND Modulo = 'CXC'
          AND Cuenta IN ( '101-010-101', '101-010-102', '101-010-202', '101-010-301', '101-010-201', '101-010-302',
                          '101-010-303', '101-010-401', '101-015-200', '101-010-203', '101-015-300', '101-020-200',
                          '101-020-300', '101-010-311', '101-010-312', '101-015-106', '101-015-108'
                        )
)
          )
      AND c.Mov NOT IN ( 'Aplicacion2' )
      AND c.FechaEmision
      BETWEEN @dFechaD AND @dFechaA
      AND c.Cliente = ISNULL(@Cliente, c.Cliente);
/*
UNION ALL
SELECT c.Cliente,
       c2.Nombre,
       c.FechaEmision AS FechaCobro,
       (c.Importe + c.Impuestos) * c.TipoCambio AS Importe,
       c.FechaEmision AS 'FechaFactura',
       CASE c.Mov
           WHEN 'Nota Credito SIVE' THEN
               '101-010-101'
           ELSE
       (
           SELECT c4.Cuenta
           FROM dbo.Concepto AS c4
           WHERE c.Concepto = c4.Concepto
                 AND c4.Modulo = 'CXC'
       )
       END AS Cuenta,
       c.Mov,
       c.MovID,
       c.Mov AS Aplica,
       c.MovID AS AplicaID,
       '' AS Origen,
       '' AS OrigenID,
       NULL AS OrigenFecha,
       0 AS Saldo
FROM dbo.Cxc AS c
    INNER JOIN dbo.Cte AS c2
        ON c2.Cliente = c.Cliente
WHERE c.Empresa = @Empresa
      AND c.Estatus NOT IN ( 'CANCELADO', 'SINAFECTAR' )
      AND c.FechaEmision
      BETWEEN @dFechaD AND @dFechaA
      AND c.Mov IN ( 'Nota Credito Paqtria', 'Nota Credito SIVE', 'Nota Credito TransIn' )
      AND c.AplicaManual = 0
      AND c.Cliente = ISNULL(@Cliente, c.Cliente);
	  */