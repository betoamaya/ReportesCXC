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
UNION ALL
SELECT c.Cliente,
       c2.Nombre,
       c.FechaEmision AS FechaCobro,
       cd.Importe * c.TipoCambio AS Importe,
       c3.FechaEmision AS FechaFactura,
       CASE --a.Mov
           WHEN c.Mov = 'Aplicacion' THEN
               '101-010-101'
           WHEN c.Mov = 'Aplicacion Act Fijo'
                AND c.Concepto = 'ANTICIPO AF GRAV 15%' THEN
               '101-020-300'
           WHEN c.Mov = 'Aplicacion Act Fijo'
                AND c.Concepto = 'ANTICIPO AF GRAV 10%' THEN
               '101-020-400'
           WHEN c.Mov = 'Aplicacion Act Fijo'
                AND c.Concepto = 'ANTICIPO AF EXENTOS' THEN
               '101-020-200'
           ELSE
       (
           SELECT c5.Cuenta
           FROM dbo.Concepto AS c5
           WHERE c.Concepto = c5.Concepto
                 AND c5.Modulo = 'CXC'
       )
       END AS Cuenta,
       c.Mov,
       c.MovID,
       cd.Aplica,
       cd.AplicaID,
       c4.Mov AS Origen,
       c4.MovID AS OrigenID,
       c4.FechaEmision AS OrigenFecha,
       ISNULL(c3.Saldo, 0) AS Saldo
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
    INNER JOIN dbo.Cxc AS c4
        ON c4.Empresa = c.Empresa
           AND c4.Mov = c.MovAplica
           AND c4.MovID = c.MovAplicaID
           AND c4.Estatus NOT IN ( 'CANCELADO', 'SINAFECTAR' )
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
      AND c.Cliente = ISNULL(@Cliente, c.Cliente)
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
      AND c.Cliente = ISNULL(@Cliente, c.Cliente)
UNION ALL
SELECT v.Cliente,
       c.Nombre,
       v.FechaEmision AS FechaCobro,
       (vd.Cantidad * vd.Precio + vd.Cantidad * vd.Precio * vd.Impuesto1 / 100) AS Importe,
       v.FechaEmision AS 'FechaFactura',
       a2.Cuenta,
       v.Mov,
       v.MovID,
       v.Mov AS Aplica,
       v.MovID AS AplicaID,
       '' AS Origen,
       '' AS OrigenID,
       NULL AS OrigenFecha,
       0 AS Saldo
FROM dbo.Venta AS v
    INNER JOIN dbo.VentaD AS vd
        ON v.ID = vd.ID
    INNER JOIN dbo.Art AS a
        ON vd.Articulo = a.Articulo
    INNER JOIN dbo.Art AS a2
        ON a.Rama = a2.Articulo
           AND a2.Cuenta IN ( '101-010-101', '101-010-102', '101-010-202', '101-010-301', '101-010-201', '101-010-302',
                              '101-010-303', '101-010-401', '101-015-200', '101-010-203', '101-015-300', '101-020-200',
                              '101-020-300', '101-010-311', '101-010-312', '101-015-106', '101-015-108'
                            )
    INNER JOIN dbo.Cte AS c
        ON v.Cliente = c.Cliente
WHERE v.Empresa = @Empresa
      AND v.Estatus = 'CONCLUIDO'
      AND v.FechaEmision
      BETWEEN @dFechaD AND @dFechaA
      AND v.Mov = 'Factura Paquetes'
      AND v.Cliente = ISNULL(@Cliente, v.Cliente)
UNION ALL
SELECT c.Cliente,
       c2.Nombre,
       c.FechaEmision AS FechaCobro,
       c.Importe * c.TipoCambio AS Importe,
       c.FechaEmision AS 'FechaFactura',
       c3.Cuenta AS Cuenta,
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
        ON c.Cliente = c2.Cliente
    INNER JOIN dbo.Concepto AS c3
        ON c.Concepto = c3.Concepto
           AND c3.Modulo = 'CXC'
           AND c3.Cuenta IN ( '101-010-101', '101-010-102', '101-010-202', '101-010-301', '101-010-201', '101-010-302',
                              '101-010-303', '101-010-401', '101-015-200', '101-010-203', '101-015-300', '101-020-200',
                              '101-020-300', '101-010-311', '101-010-312', '101-015-106', '101-015-108'
                            )
WHERE c.Empresa = @Empresa
      AND c.Estatus NOT IN ( 'CANCELADO', 'SINAFECTAR' )
      AND c.FechaEmision
      BETWEEN @dFechaD AND @dFechaA
      AND c.Mov = 'Anticipo'
      AND c.AplicaManual = 0
      AND c.Cliente = ISNULL(@Cliente, c.Cliente)
UNION ALL
SELECT v.Cliente,
       c.Nombre,
       v.FechaEmision AS FechaCobro,
       v.Importe + ISNULL(v.Impuestos, 0) AS Importe,
       v.FechaEmision AS 'FechaFactura',
       '101-015-200',
       v.Mov,
       v.MovID,
       v.Mov AS Aplica,
       v.MovID AS AplicaID,
       '' AS Origen,
       '' AS OrigenID,
       NULL AS OrigenFecha,
       0 AS Saldo
FROM dbo.Venta AS v
    INNER JOIN dbo.Cte AS c
        ON v.Cliente = c.Cliente
WHERE v.Empresa = @Empresa
      AND v.Estatus = 'CONCLUIDO'
      AND v.FechaEmision
      BETWEEN @dFechaD AND @dFechaA
      AND v.Mov = 'Devolucion Venta'
      AND v.Cliente = ISNULL(@Cliente, v.Cliente)
UNION ALL
SELECT c.Contacto AS Cliente,
       c2.Nombre,
       c.FechaEmision AS FechaCobro,
       ISNULL(cd.Haber, 0) AS Importe,
       c.FechaEmision AS 'FechaFactura',
       '101-015-200',
       c.Mov,
       c.MovID,
       c.Mov AS Aplica,
       c.MovID AS AplicaID,
       '' AS Origen,
       '' AS OrigenID,
       NULL AS OrigenFecha,
       0 AS Saldo
FROM dbo.Cont AS c
    INNER JOIN dbo.ContD AS cd
        ON c.ID = cd.ID
           AND cd.Cuenta IN ( '101-010-101', '101-010-102', '101-010-202', '101-010-301', '101-010-201', '101-010-302',
                              '101-010-303', '101-010-401', '101-015-200', '101-010-203', '101-015-300', '101-020-200',
                              '101-020-300', '101-010-311', '101-010-312', '101-015-106', '101-015-108'
                            )
    INNER JOIN dbo.Cte AS c2
        ON c.Contacto = c2.Cliente
WHERE c.Empresa = @Empresa
      AND c.FechaEmision
      BETWEEN @dFechaD AND @dFechaA
      AND c.Mov = 'Diario Manual'
      AND c.Estatus = 'CONCLUIDO'
      AND c.Contacto = ISNULL(@Cliente, c.Contacto)
      AND ISNULL(cd.Haber, 0) <> 0
ORDER BY Cliente ASC;